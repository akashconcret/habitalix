public class DMLHandler {  
    public static String mapRentAndTransaction(string mappingJSONForRentAndTransaction) {
        System.debug('mappingJSONForRentAndTransaction::'+mappingJSONForRentAndTransaction);
          //Set<Id> setOfAccountingId = new Set<Id>();
        Map<String, Object> mapForRentIdAndTransactions = (Map<String, Object>)JSON.deserializeUntyped(mappingJSONForRentAndTransaction);
        List<HBX_Accounting__c> lstOfAcoounting = new List<HBX_Accounting__c>();
        String rentIdValue = '';
        for(string rentId :mapForRentIdAndTransactions.keySet()){
            rentIdValue = rentId;
            string serilizedListOfTransactions = JSON.serialize(mapForRentIdAndTransactions.get(rentId));
            List<Object> lstObj = (List<Object> ) JSON.deserializeUntyped(serilizedListOfTransactions);
            for(object transactionasObject :lstObj){
                Map<String, Object> mapForTransactionFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(transactionasObject));
                HBX_Accounting__c accounting = new HBX_Accounting__c();
                accounting.HBX_BankTransaction__c = string.valueof(mapForTransactionFields.get('Id'));
                accounting.HBX_Rent__c = rentId;
                accounting.HBX_PaidAmount__c = Decimal.valueof(String.valueof(mapForTransactionFields.get('Amount')));
                accounting.HBX_IsAutomaticMatch__c = false;
                lstOfAcoounting.add(accounting);
            }
        }
        try {
            //insert lstOfAcoounting;
            Set<Id> accountingIdCreatedSuccessfully = updateMatchFailResonOnBankTransaction(lstOfAcoounting);
            updateRentTimeStamp(accountingIdCreatedSuccessfully);
            return accountingIdCreatedSuccessfully.size()+' Transaction has been linked with Rent Name :  '+[select Name from HBX_Rent__c where Id =:rentIdValue].Name;
        }catch(Exception ee) {
                return 'Something went wrong';
        }
    } 
    
    public static Set<Id> updateMatchFailResonOnBankTransaction(List<HBX_Accounting__c> listOfAccounting){
        Set<Id> setOfAccountingId = new Set<Id>();
        Map<id,string> mapOfError = new Map<id,string>();
        Database.SaveResult[] saveResultListAcc = Database.insert(listOfAccounting, false); 
        integer count = -1;
        for (Database.SaveResult sr : saveResultListAcc) {
            count++;
            if (sr.isSuccess()) {
                setOfAccountingId.add(sr.getId());
            }
            else {             
                for(Database.Error err : sr.getErrors()) {
                    mapOfError.put(listOfAccounting[count].HBX_BankTransaction__c,err.getMessage());
                }
            }
        }
        system.debug('mapOfError :: '+mapOfError);
        List<HBX_BankTransaction__c> lstBankTransaction = [Select id,HBX_MatchFailReason__c from HBX_BankTransaction__c where id IN: mapOfError.keyset()];
        for(HBX_BankTransaction__c bankTransaction : lstBankTransaction){
            bankTransaction.HBX_MatchFailReason__c = mapOfError.get(bankTransaction.Id);
        }
        if(lstBankTransaction.size()>0){
            try{
                update lstBankTransaction;
            }catch(Exception ee){
                
            }
        }
        if(setOfAccountingId.size()>0){
            updateStatusOnBankTransaction(listOfAccounting);
        }
        return setOfAccountingId;
    }
    
    
    public static void updateRentTimeStamp(Set<Id> setOfAccountingId) {
        Map<Id, DateTime> mapOfCreatedDateWithRentId =  new Map<Id, DateTime>();
        Set<Id> rentIdOfAutomaticMatchUpdate = new Set<Id>();
        for(HBX_Accounting__c objOfAccounting : [SELECT id, CreatedDate, HBX_IsAutomaticMatch__c, HBX_Rent__c from HBX_Accounting__c where Id IN : setOfAccountingId]){
            mapOfCreatedDateWithRentId.put(objOfAccounting.HBX_Rent__c,  objOfAccounting.CreatedDate);
            if(objOfAccounting.HBX_IsAutomaticMatch__c) {
                rentIdOfAutomaticMatchUpdate.add(objOfAccounting.HBX_Rent__c);               
            }
        }
        List<HBX_Rent__c> listOfRents = new List<HBX_Rent__c>();
        for(HBX_Rent__c objRent : [SELECT id, HBX_LastAutomaticMatchDate__c from HBX_Rent__c where id IN : mapOfCreatedDateWithRentId.keySet()]) {
            if(rentIdOfAutomaticMatchUpdate.contains(objRent.Id)) {
                objRent.HBX_LastAutomaticMatchDate__c = mapOfCreatedDateWithRentId.get(objRent.Id);
                listOfRents.add(objRent);
            }else {
                objRent.HBX_LastManualMatchDate__c =  mapOfCreatedDateWithRentId.get(objRent.Id); 
                listOfRents.add(objRent);
            }
        } 
        try{
            if(listOfRents.size()>0){
                update listOfRents;
            }
        } catch(Exception ex) {
            System.debug('ShowPropertyRentsController class at line no 216::'+ ex.getMessage());
        }
    }  
    
    // retrieve total paid amount under a rent in current month.
     public static Map<Id,Decimal> retrievePaidRentAmountForRentInCurrentMonth(List<HBX_Rent__c> lstRents){
         List<Id> RentIds = new List<Id>();
         Map<Id,Decimal> mapOfRentPaidAmount = new Map<Id,Decimal>();
         for(HBX_Rent__c rent : lstRents){
             RentIds.add(rent.Id);
         }
         system.debug('RentIds : '+RentIds);
         for(AggregateResult accounting : [select HBX_Rent__c,calendar_year(CreatedDate),calendar_month(CreatedDate),SUM (HBX_PaidAmount__c) allAmount from HBX_Accounting__c GROUP BY HBX_Rent__c,calendar_year(CreatedDate),calendar_month(CreatedDate) HAVING HBX_Rent__c =:RentIds AND calendar_month(CreatedDate) =:System.today().month() AND calendar_year(CreatedDate)=:System.today().year()]){
             
             if(accounting.get('allAmount') != null){
                 mapOfRentPaidAmount.put((Id) accounting.get('HBX_Rent__c'),(Decimal) accounting.get('allAmount'));
             }else{
                 mapOfRentPaidAmount.put((Id) accounting.get('HBX_Rent__c'),0);
             }
         }
         return mapOfRentPaidAmount;
     }
    
    // public static void updateStatusOnBankTransaction(Set<Id> setOfAccountingId) {
    
      /*  Set<Id> setOfTransactionId = new Set<Id>();
        List<HBX_BankTransaction__c> listOfBankTransaction = new List<HBX_BankTransaction__c>();
        for(HBX_Accounting__c objOfAccounting : [SELECT Id,HBX_BankTransaction__c FROM HBX_Accounting__c where Id =: setOfAccountingId]){
            setOfTransactionId.add(objOfAccounting.HBX_BankTransaction__c);
        }
        for(HBX_BankTransaction__c objOfBankTransaction : [SELECT Id, HBX_Status__c FROM HBX_BankTransaction__c where Id =: setOfTransactionId]) {
            objOfBankTransaction.HBX_Status__c = 'Matched';
            listOfBankTransaction.add(objOfBankTransaction);
        }
        try{
            update listOfBankTransaction;
        }catch(DmlException ex){
            System.debug('DmlHandler class method updateStatusOnBankTransaction:: '+ex.getMessage());
        }*/
        
        public static void updateStatusOnBankTransaction(List<HBX_Accounting__c> listOfAccounting) {
            Set<Id> setOfTransactionId = new Set<Id>();
            List<HBX_BankTransaction__c> listOfBankTransaction = new List<HBX_BankTransaction__c>();
            for(HBX_Accounting__c objAccounting : listOfAccounting) {
                if(objAccounting.Id!=null){
                    setOfTransactionId.add(objAccounting.HBX_BankTransaction__c);
                }
            }
            for(HBX_BankTransaction__c objOfBankTransaction : [SELECT Id, HBX_Status__c FROM HBX_BankTransaction__c where Id =: setOfTransactionId]) {
                objOfBankTransaction.HBX_Status__c = 'Matched';
                listOfBankTransaction.add(objOfBankTransaction);
            }
            try{
                update listOfBankTransaction;
            }catch(DmlException ex){
                System.debug('DmlHandler class method updateStatusOnBankTransaction:: '+ex.getMessage());
            }
        }
}