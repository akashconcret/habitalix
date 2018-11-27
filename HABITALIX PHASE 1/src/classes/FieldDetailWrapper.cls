public class FieldDetailWrapper{
    @AuraEnabled public String field;
    @AuraEnabled public string label;
    @AuraEnabled public string dataType;
    public FieldDetailWrapper(String field, String label,String dataType) {
        this.field = field;
        this.label = label;
        this.dataType = dataType;
    }
}