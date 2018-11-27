public class PaymentMatchingCriteriaControllerWrapper {
    @AuraEnabled
    public List<fieldDetailWrapper> rentFields;
    @AuraEnabled
    public List<fieldDetailWrapper> transactionFields;
    @AuraEnabled
    public String savedFilters;
    public PaymentMatchingCriteriaControllerWrapper(List<fieldDetailWrapper> rentFields,List<fieldDetailWrapper> transactionFields,String savedFilters){
        this.rentFields = rentFields;
        this.transactionFields = transactionFields;
        this.savedFilters = savedFilters;
    }
    //  public class RentsRecords {
    //     @AuraEnabled public String fields;
    //     @AuraEnabled public string label;
        
    //     public RentsRecords(String fields, String label) {
    //         this.fields = fields;
    //         this.label = label;
    //     }
    // }
}