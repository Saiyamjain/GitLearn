trigger VoiceCallTrigger on VoiceCall (before insert) {
    fflib_SObjectDomain.triggerHandler(VoiceCallDomain.class);
}