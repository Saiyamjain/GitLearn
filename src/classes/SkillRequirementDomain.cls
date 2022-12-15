public class SkillRequirementDomain extends ApplicationDomain {

    Map<Id, PendingServiceRouting> psrByIdMap = new Map<Id, PendingServiceRouting>();
    Map<String, String> skillIdAndLevelMap = new Map<String, String>();
    Map<String, Decimal> remainingCapacity = new Map<String, Decimal>();

    static List<Decimal> listOfSkillLevels = new List<Decimal>{5.00,3.00,1.00};

    static Id serviceChannelIdForTranscript = ServiceChannelSelector.newInstance().selectByRelatedEntity(LiveChatTranscript.SObjectType.getDescribe().name).Id;
    
    public static SkillRequirementDomain newInstance(List<SkillRequirement> recordList) {
        return (SkillRequirementDomain) Application.Domain.newInstance(recordList);
    }

    public SkillRequirementDomain(List<SkillRequirement> sObjectList) {
        super(sObjectList);
    }

    public override void onBeforeInsert() {
        processSkillRequirements();
    }

    public override void onAfterInsert() {
        captureSkillInfoOnTranscript();
        pushPendingServiceRoutingToRouting();
    }

    private void processSkillRequirements() { 
        Set<Id> relatedPendingServiceRoutingsIds = new Set<Id>();
        List<SkillRequirement> skillRequirementsList = (List<SkillRequirement>) this.records;
        for (SkillRequirement skillReq : skillRequirementsList) {
            relatedPendingServiceRoutingsIds.add(skillReq.RelatedRecordId);
        }

        psrByIdMap = new Map<Id, PendingServiceRouting>(PendingServiceRoutingSelector.newInstance().selectById(relatedPendingServiceRoutingsIds));
        Set<Id> onlineAgentsIds = new Set<Id>();
        List<UserServicePresence> onlineAgents = UserServicePresenceSelector.newInstance().selectOnlineAgents();
        for (UserServicePresence up : onlineAgents) {
            onlineAgentsIds.add(up.UserId);
        }
        //initialize remainingCapacity map (user, user total capacity)
        for (UserServicePresence usp : onlineAgents) {
            remainingCapacity.put(usp.UserId, usp.ConfiguredCapacity);
        }

        //after this for loop, remainingCapacity map will be Map<user, user remaining capacity>
        //each row of AgentWork where the UserId is an online agent determines a work assignemnt assigned to the user/agent, so deducting all the AgentWork.CapacityWeight from the initial capacity of the user, we obtain the remaining capacity for each user
        Set<Id> agentsWithVoiceAgentWorkAssigned = new Set<Id>();
        for (AgentWork aw : AgentWorkSelector.newInstance().selectOpenedAssignedWork(onlineAgentsIds)) {   
            if (aw.ServiceChannel.DeveloperName == 'sfdc_phone') {
                remainingCapacity.put(aw.UserId, 0);
                agentsWithVoiceAgentWorkAssigned.add(aw.UserId);
            } else if (!agentsWithVoiceAgentWorkAssigned.contains(aw.UserId)) {
                remainingCapacity.put(aw.UserId, remainingCapacity.get(aw.UserId) - aw.CapacityWeight);
            }
        }

        for(ServiceResourceSkill srs : ServiceResourceSkillSelector.newInstance().selectByAgentsIds(onlineAgentsIds)) {
            if(skillIdAndLevelMap.containsKey(srs.ServiceResource.RelatedRecordId)) {
                skillIdAndLevelMap.put(srs.ServiceResource.RelatedRecordId, skillIdAndLevelMap.get(srs.ServiceResource.RelatedRecordId) + '#' + String.valueOf(srs.SkillId) + String.valueOf(srs.SkillLevel));
            } else {
                skillIdAndLevelMap.put(srs.ServiceResource.RelatedRecordId, String.valueOf(srs.SkillId) + String.valueOf(srs.SkillLevel));
            }
        }

        for (SkillRequirement skillReq : skillRequirementsList) {
            skillReq.SkillLevel = calculateHighestAvailableSkillLevel(skillReq);
        }
    }

    private Decimal calculateHighestAvailableSkillLevel(SkillRequirement skillReq) {
        Decimal requiredCapacity = psrByIdMap.get(skillReq.RelatedRecordId).CapacityWeight;
        for (Decimal skillLevel : listOfSkillLevels) {
            String skillIdAndLevel = String.valueOf(skillReq.SkillId) + String.valueOf(skillLevel);
            //for each online agent
            for(String userId : skillIdAndLevelMap.keySet()){
                //for each combination of SkillId+SkillLevel of the agent
                for(String userSkillIdAndValue : skillIdAndLevelMap.get(userId).split('#')){
                    //if we find an agent with the required combination of SkillId+SkillLevel AND the user has enough capacity (ad example 1 if a chat has to be assigned), then we set on the SkillRequirement the highest SkillLevel as possible
                    if(userSkillIdAndValue == skillIdAndLevel && remainingCapacity.get(userId) - requiredCapacity >= 0){
                        return skillLevel;
                    }
                }
            }
        }
        return 1.00;
    }

    private void pushPendingServiceRoutingToRouting() {
        Set<Id> relatedPendingServiceRoutingsIds = new Set<Id>();
        List<SkillRequirement> skillRequirementsList = (List<SkillRequirement>) this.records;
        for (SkillRequirement skillReq : skillRequirementsList) {
            relatedPendingServiceRoutingsIds.add(skillReq.RelatedRecordId);
        }

        List<PendingServiceRouting> psrList = PendingServiceRoutingSelector.newInstance().selectById(relatedPendingServiceRoutingsIds);

        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] { PendingServiceRouting.SObjectType });
        PendingServiceRoutingDomain pendingServiceRoutingDomain = (PendingServiceRoutingDomain)Application.Domain.newInstance( psrList );
        pendingServiceRoutingDomain.pushToRouting(uow);
        uow.commitWork();
    }

    private void captureSkillInfoOnTranscript() {
        Map<Id,List<SkillRequirement>> skillRequirementToLiveChatTranscriptIdMap = new Map<Id,List<SkillRequirement>>();
        Map<Id,List<SkillRequirement>> skillRequirementToPsrIdMap = new Map<Id,List<SkillRequirement>>();
        List<SkillRequirement> skillRequirementsList = (List<SkillRequirement>) this.records;
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] { LiveChatTranscript.SObjectType });

        for (SkillRequirement skillReq : skillRequirementsList) {
            if(!skillRequirementToLiveChatTranscriptIdMap.containsKey(skillReq.RelatedRecordId)) {
                skillRequirementToPsrIdMap.put(skillReq.RelatedRecordId, new List<SkillRequirement>());
            }
            skillRequirementToPsrIdMap.get(skillReq.RelatedRecordId).add(skillReq);
        }

        for(PendingServiceRouting psr : PendingServiceRoutingSelector.newInstance().selectById(skillRequirementToPsrIdMap.keySet())) {
            if(psr.ServiceChannelId == serviceChannelIdForTranscript) {
                if(!skillRequirementToLiveChatTranscriptIdMap.containsKey(psr.WorkItemId)) {
                    skillRequirementToLiveChatTranscriptIdMap.put(psr.WorkItemId, new List<SkillRequirement>());
                }
                skillRequirementToLiveChatTranscriptIdMap.get(psr.WorkItemId).addAll(skillRequirementToPsrIdMap.get(psr.Id));
            }
        }
        
        for(LiveChatTranscript relatedTranscript : LiveChatTranscriptSelector.newInstance().selectById(skillRequirementToLiveChatTranscriptIdMap.keySet())) {
            List<SkillRequirement> listOfSkillReqs = skillRequirementToLiveChatTranscriptIdMap.get(relatedTranscript.Id);
            String skillListStr = '';
            for (SkillRequirement skillReq: listOfSkillReqs) {
                if (listOfSkillReqs.indexOf(skillReq) == (Integer.valueOf(listOfSkillReqs.size()) -1)) {
                    skillListStr += skillReq.Skill.DeveloperName;
                } else {
                    skillListStr += skillReq.Skill.DeveloperName + ', ';
                }
            }
            relatedTranscript.Skills__c = skillListStr;
            uow.registerDirty(relatedTranscript);
        }
        uow.commitWork();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new SkillRequirementDomain(sObjectList);
        }
    }
}