public class RentDetailsWrapper{
    @AuraEnabled
    public HBX_Rent__c rent;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Decimal remainingAmount;
    @AuraEnabled
    public Boolean otherPortfolioRecordsToShow;
    @AuraEnabled
    public List<HBX_BankTransaction__c> listOfBankTransactions;
    
    public RentDetailsWrapper(HBX_Rent__c rent,String accountName,List<HBX_BankTransaction__c> listOfBankTransactions,Decimal remainingAmount,Boolean otherPortfolioRecordsToShow){//Boolean otherPortfolioRecordsToShow
        this.rent = rent;
        this.accountName = accountName;
        this.listOfBankTransactions = listOfBankTransactions;
        this.remainingAmount = remainingAmount;
        this.otherPortfolioRecordsToShow = otherPortfolioRecordsToShow;
    }
}