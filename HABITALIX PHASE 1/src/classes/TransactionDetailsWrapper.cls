public class TransactionDetailsWrapper{
    @AuraEnabled
    public HBX_BankTransaction__c transactionRecord;
    @AuraEnabled
    public Decimal payableAmountToDisplay;
    @AuraEnabled
    public Decimal payableAmountToEdit;
    
    
    public TransactionDetailsWrapper(HBX_BankTransaction__c transactionRecord,Decimal payableAmountToDisplay,Decimal payableAmountToEdit){
        this.transactionRecord = transactionRecord;
        this.payableAmountToDisplay = payableAmountToDisplay;
        this.payableAmountToEdit = payableAmountToEdit;
    }
}