public class BalanceSheetControllerWrapper {
    @AuraEnabled
    public HBX_Rent__c rent;
    @AuraEnabled
    public Decimal rentTotalAmount;
    @AuraEnabled
    public Decimal totalPaidAmount;
    public BalanceSheetControllerWrapper(HBX_Rent__c rent,Decimal rentTotalAmount,Decimal totalPaidAmount){
        this.rent = rent;
        this.rentTotalAmount = rentTotalAmount;
        this.totalPaidAmount = totalPaidAmount;
    }
}