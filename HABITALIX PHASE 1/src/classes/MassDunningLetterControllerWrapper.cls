public class MassDunningLetterControllerWrapper {
    
    @AuraEnabled 
    public String rentName;
    @AuraEnabled 
    public String rentId;
    @AuraEnabled 
    public Decimal AmountExpectedRent;
    @AuraEnabled 
    public Decimal creditCurrentMonth;
    @AuraEnabled 
    public Date duedate;
    @AuraEnabled
    public DateTime lastManualMAtchDate;
    @AuraEnabled
    public DateTime lastAutoMAtchDate;
    @AuraEnabled
    public Id contractId;
    @AuraEnabled
    public Decimal remainingAmount;
    @AuraEnabled
    public String dunningStatus;
    @AuraEnabled
    public String balanceListId;
    @AuraEnabled
    public DateTime lastDunningDate;
    @AuraEnabled
    public String buildingId;
    @AuraEnabled
    public String buildingName;
    
    public MassDunningLetterControllerWrapper(String rentName,String rentId,Decimal AmountExpectedRent,Date duedate,DateTime lastManualMAtchDate,DateTime lastAutoMAtchDate,Id contractId,Decimal remainingAmount,Decimal creditCurrentMonth,String dunningStatus,String balanceListId,DateTime lastDunningDate,String buildingId,String buildingName){
        this.rentId = rentId;
        this.rentName = rentName;
        this.AmountExpectedRent = AmountExpectedRent;
        this.duedate = duedate;
        this.lastManualMAtchDate = lastManualMAtchDate;
        this.lastAutoMAtchDate = lastAutoMAtchDate;
        this.contractId = contractId;
        this.remainingAmount = remainingAmount;
        this.creditCurrentMonth = creditCurrentMonth;
        this.dunningStatus = dunningStatus;
        this.balanceListId = balanceListId;
        this.lastDunningDate = lastDunningDate;
        this.buildingId = buildingId;
        this.buildingName = buildingName;
    }
}