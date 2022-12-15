public with sharing class LightningResult {
    public static LightningResult instance;
    @AuraEnabled
    public Object result { get; set; }
    @AuraEnabled
    public Exception error { get; set; }
    @AuraEnabled
    public LightningMsg msg { get; set; }
    @AuraEnabled
    public Boolean success = true;
    @AuraEnabled
    public String message;


    public static LightningResult setResult(Object obj) {
        getInstance().result = obj;
        return getInstance();
    }

    public static LightningResult setError(Exception ex) {
        getInstance().error = ex;
        return getInstance();
    }

    public static LightningResult addMsg(String title, String msg, MsgVariant variant, MsgMode mode) {
        getInstance().msg = new LightningMsg(title, msg, variant, mode);
        return getInstance();
    }

    public static LightningResult addSuccessMsg(String msg) {
        getInstance().success = true;
        return addMsg(Label.Success, msg, MsgVariant.SUCCESS, null);
    }

    public static LightningResult addSuccessMsgIfNoErrorMsg(String msg) {
        if (getInstance().msg == null) {
            addSuccessMsg(msg);
        }
        return getInstance();
    }

    public static LightningResult addErrorMsgIfNoErrorMsg(String msg) {
        if (getInstance().msg == null) {
            addErrorMsg(msg);
        }
        return getInstance();
    }

    public static LightningResult addErrorMsg(String msg) {
        getInstance().success = false;
        return addMsg(Label.Error, msg, MsgVariant.ERROR, MsgMode.STICKY);
    }

    public static LightningResult getInstance() {
        if (instance == null) {
            instance = new LightningResult();
        }
        return instance;
    }

    public class LightningMsg {
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String msg { get; set; }
        @AuraEnabled
        public String variant { get; set; }
        @AuraEnabled
        public String mode { get; set; }

        public LightningMsg(String title, String msg, MsgVariant variant, MsgMode mode) {
            this.title = title;
            this.msg = msg;
            this.variant = variant?.name();
            this.mode = mode?.name();
        }
    }

    public enum MsgVariant {INFO, SUCCESS, WARNING, ERROR}
    public enum MsgMode {DISSMISABLE, PESTER, STICKY}

    public static Map<String, String> prepareComboboxOption(String value, String label) {
        return new Map<String, String> {
            'value' => value,
            'label' => label
        };
    }

    public class ComboboxOption {
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String label { get; set; }

        public ComboboxOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}