public class SavedFiltersWrapper {
    @AuraEnabled public String transactionField;
    @AuraEnabled public String operator;
    @AuraEnabled public String rentField;
    @AuraEnabled public String filterLogic;
    
    public SavedFiltersWrapper(String transactionField,string operator,String rentField,String filterLogic){
        this.transactionField = transactionField;
        this.operator = operator;
        this.rentField = rentField;
        this.filterLogic = filterLogic;
    }
}