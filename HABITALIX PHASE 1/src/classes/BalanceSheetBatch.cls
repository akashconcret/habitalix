global class BalanceSheetBatch implements Database.Batchable<sObject>{
    
    global BalanceSheetBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = setQuery();
        Integer month = system.today().month();
        return Database.getQueryLocator('SELECT id,HBX_Contract__c,HBX_GrossRentAmount__c,Name,HBX_Contract__r.HBX_Building__c,HBX_Contract__r.HBX_PaymentDeadlineDay__c from HBX_Rent__c where HBX_IsActive__c = true');
        //return Database.getQueryLocator('SELECT id,Rent__c, HBX_Rent__r.Name, HBX_Rent__r.HBX_GrossRentAmount__c, Bank_Transaction__c,HBX_PaidAmount__c  FROM HBX_Accounting__c where CALENDAR_MONTH(CreatedDate) =:month');
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        Date dt = system.today();
        HBX_Rent__c rent = (HBX_Rent__c) scope[0];
        List<HBX_Accounting__c> lstAcounting = [SELECT id,HBX_Rent__c,HBX_Rent__r.Name, HBX_Rent__r.HBX_GrossRentAmount__c,HBX_PaidAmount__c,HBX_BalanceList__r.HBX_ContractNumber__r.HBX_Building__c  FROM HBX_Accounting__c where CALENDAR_MONTH(CreatedDate) =:dt.month() AND CALENDAR_YEAR(CreatedDate) =:dt.year() AND HBX_Rent__c=:rent.Id];
        
        system.debug('lstAcountingCurrent Month :: '+lstAcounting);
        Boolean accountingFoundForCurrentMonth = false;
        Decimal LastMonthCredit = 0.00;
        String lastMonthStatus = '';
        Boolean creatingBalanceListFirstTime = true;
        DateTime lastDunningDateTime ;
        Date paymentTarget;
        
        String externalId = rent.HBX_Contract__c+rent.Name+String.valueof(system.today().month())+String.valueof(system.today().year());
        List<HBX_BalanceList__c> relatedBalanceList = [select id,HBX_NextDunningStage__c,HBX_PaymentTarget__c,HBX_LastDunningDate__c from HBX_BalanceList__c where HBX_ExternalId__c = :externalId];
        if(relatedBalanceList.size()>0){
            creatingBalanceListFirstTime = false;
        }
        
        if(lstAcounting.size()==0){
        }else{
            accountingFoundForCurrentMonth = true;
        }
       // List<HBX_Accounting__c> lstAcountingLastMonth = [SELECT id,HBX_Rent__c,HBX_BalanceList__c,HBX_BalanceList__r.HBX_CreditTotal__c,HBX_BalanceList__r.HBX_NextDunningStage__c,HBX_BalanceList__r.HBX_LastDunningDate__c,HBX_BalanceList__r.HBX_PaymentTarget__c  FROM HBX_Accounting__c where CALENDAR_MONTH(CreatedDate) =:dt.addMonths(-1).month() AND CALENDAR_YEAR(CreatedDate) =:dt.addMonths(-1).year() AND HBX_Rent__c=:rent.Id];
        List<HBX_BalanceList__c> lstAcountingLastMonth = [SELECT id,HBX_CreditTotal__c,HBX_NextDunningStage__c,HBX_LastDunningDate__c,HBX_PaymentTarget__c  FROM HBX_BalanceList__c where CALENDAR_MONTH(CreatedDate) =:dt.addMonths(-1).month() AND CALENDAR_YEAR(CreatedDate) =:dt.addMonths(-1).year() AND Name=:rent.Name AND HBX_ContractNumber__c=:rent.HBX_Contract__c];
        system.debug('lstAcountingLastMonth :: '+lstAcountingLastMonth);
        
        if(!(lstAcountingLastMonth.size()==0)){
            LastMonthCredit = lstAcountingLastMonth[0].HBX_CreditTotal__c;
            lastMonthStatus = lstAcountingLastMonth[0].HBX_NextDunningStage__c=='Paid'?'':lstAcountingLastMonth[0].HBX_NextDunningStage__c;
            lastDunningDateTime = lstAcountingLastMonth[0].HBX_LastDunningDate__c;
            paymentTarget = lstAcountingLastMonth[0].HBX_PaymentTarget__c;
        }
        system.debug('rentName :: '+rent.Name+'LastMonthCredit : '+LastMonthCredit+' lastMonthStatus '+lastMonthStatus+' lastDunningDateTime: '+lastDunningDateTime+' paymentTarget: '+paymentTarget);
        BalanceSheetController.getAcountingRecords(lstAcounting,LastMonthCredit,accountingFoundForCurrentMonth,rent,lastMonthStatus,lastDunningDateTime,creatingBalanceListFirstTime,paymentTarget);//
    }
    
    global void finish(Database.BatchableContext BC){
        //Lock Previous Month Balance List.
        Integer days = Date.daysInMonth(system.Today().month(),system.Today().year());
        if(system.Today().day() == days || Test.isRunningTest()){
            BalanceSheetController.lockPreviousMonthdBalanceList();
        }
    }
}