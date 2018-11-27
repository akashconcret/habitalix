global class CreateAccountingBatch implements Database.Batchable<sObject>{

    global CreateAccountingBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Integer month = system.today().month();
        Integer year = system.today().year();
        String query = setQuery();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        List<HBX_BankTransaction__c> bankTransactionLst = (List<HBX_BankTransaction__c>) scope;
        AutoMapTransactionWithRentController.matchTransactionForRent(bankTransactionLst);
    }
    
    global void finish(Database.BatchableContext BC){
        //Database.executeBatch(new BalanceSheetBatch(),1);
    }
    global static string setQuery(){
        Integer day = system.today().day();
        Date endDate;
        Date initDate ;
        if(day == 5){
            endDate = Date.newInstance(system.today().year(), system.today().month(), system.today().day());
            initDate = Date.newInstance(endDate.year(), endDate.addMonths(-1).month(), 25);
        }else if(day == 15){
            endDate = Date.newInstance(system.today().year(), system.today().month(), system.today().day());
            initDate = Date.newInstance(endDate.year(), endDate.month(), 05);
        }else if(day == 25){
            endDate = Date.newInstance(system.today().year(), system.today().month(), system.today().day());
            initDate = Date.newInstance(endDate.year(), endDate.month(), 15);
        }
        
        // String query = 'select id,HBX_IBAN__c,HBX_Amount__c from HBX_BankTransaction__c where CreatedDate >=: initDate AND CreatedDate <=: endDate';
        // Integer month = system.today().month();
        Map<String,SObject> mapMatchingCriteria = HBX_PaymentMatchingCriteria__c.getAll();
        String query = 'select id,HBX_IBAN__c,HBX_Amount__c';
        for(String transactionField : mapMatchingCriteria.keySet()){
            if(transactionField != 'HBX_IBAN__c' && transactionField != 'HBX_Amount__c'){
                query+=','+transactionField;
            }
        }
        // query += 'select id,HBX_IBAN__c,HBX_Amount__c,(select id,HBX_BankTransaction__c from Accountings__r where HBX_BankTransaction__c!=null limit 200) from HBX_BankTransaction__c where CALENDAR_MONTH(CreatedDate) =: month AND CALENDAR_YEAR(CreatedDate)=:year';
        
        query +=',(select id,HBX_BankTransaction__c from Accountings__r where HBX_BankTransaction__c!=null limit 200) from HBX_BankTransaction__c where CALENDAR_MONTH(CreatedDate) =: month AND CALENDAR_YEAR(CreatedDate)=:year';
        return query;
    }
}