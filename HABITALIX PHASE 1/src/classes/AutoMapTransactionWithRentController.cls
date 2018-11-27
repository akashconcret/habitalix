public class AutoMapTransactionWithRentController {
    public AutoMapTransactionWithRentController(){
        
    }
    
     /**
    * @description matches the rent with transaction based on IBAN no. 
    * @param bankTransaction Its a particular HBX_BankTransaction__c record. this mehtod will be called from batch's execute method.
    */

    public static void matchTransactionForRent(List<HBX_BankTransaction__c> bankTransaction){
        Map<Id,String> mapAccountWithIBAN = matchIBANOnAccount(bankTransaction);
        system.debug('mapAccountWithIBAN  :: '+mapAccountWithIBAN);
        String rentId;
        if(!mapAccountWithIBAN.isEmpty()){
            Map<Id,Id> mapAccountWithContractId  = matchAccountWithContract(mapAccountWithIBAN.keyset());
            If(!mapAccountWithContractId.isEmpty()){
                // String contractId = mapAccountWithContractId.get(accId);
                Map<Id,List<HBX_Rent__c>> mapRentContractId = matchRentWithContract(mapAccountWithContractId.keySet(),bankTransaction[0]);
                if(!mapRentContractId.isEmpty()){
                    // rentId = mapRentContractId.get(contractId);
                    Map<Id,List<HBX_Rent__c>> rentPerAccount = setRentsPerAccount(mapAccountWithContractId,mapRentContractId);
                    system.debug('rentPerAccount  :: '+rentPerAccount);
                    getMatchingRentAndTransaction(rentPerAccount,bankTransaction,mapAccountWithIBAN);
                }
            }
        }
    }
    
     /**
    * @description sets  rent per account.
    * @param mapAccountWithContractId map holds <contactId,AccId>.
    * @Param mapRentContractId map holds list of rents per contract.
    */
    
    public static Map<Id,List<HBX_Rent__c>> setRentsPerAccount(Map<Id,Id> mapAccountWithContractId,Map<Id,List<HBX_Rent__c>> mapRentContractId){
        Map<Id,List<HBX_Rent__c>> rentPerAccount = new Map<Id,List<HBX_Rent__c>>();
        for(Id contractId : mapAccountWithContractId.keyset()){
            if(mapAccountWithContractId.containsKey(contractId) && mapRentContractId.containsKey(contractId)){
                rentPerAccount.put(mapAccountWithContractId.get(contractId),mapRentContractId.get(contractId));
            }
        }
        return rentPerAccount;
    }
    
     /**
    * @description gets matching rent and transactions.
    * @param rentPerAccount all rents per account (based on IBAN)
    * @param bankTransaction all bank transaction records sent from batch. 
    * @param  mapAccountWithIBAN map for account and its IBAN.
    */
    
    public static void getMatchingRentAndTransaction(Map<Id,List<HBX_Rent__c>> rentPerAccount, List<HBX_BankTransaction__c> bankTransaction,Map<Id,String> mapAccountWithIBAN){
        List<HBX_Accounting__c> lstAccounting = new List<HBX_Accounting__c>();
        Map<String,List<HBX_BankTransaction__c>> mapOfTransactionAndItsIBAN = new Map<String,List<HBX_BankTransaction__c>>();
        for(HBX_BankTransaction__c bt :bankTransaction){
            if(mapOfTransactionAndItsIBAN.containsKey(bt.HBX_IBAN__c)){
                mapOfTransactionAndItsIBAN.get(bt.HBX_IBAN__c).add(bt);
            }else{
                mapOfTransactionAndItsIBAN.put(bt.HBX_IBAN__c,new List<HBX_BankTransaction__c>{bt});
            }
        }
        system.debug('mapOfTransactionAndItsIBAN :: '+mapOfTransactionAndItsIBAN);
        for(Id accId : rentPerAccount.keyset()){
            String accIban = mapAccountWithIBAN.get(accId);
            List<HBX_BankTransaction__c> lstTransaction = mapOfTransactionAndItsIBAN.get(accIban);
            List<HBX_Rent__c> lstRentsPerAccount =  rentPerAccount.get(accId);
            
            system.debug('lstTransaction :: '+lstTransaction);
            system.debug('lstRentsPerAccount :: '+lstRentsPerAccount);
            
            createAccountingRecordForRentAndTransaction(lstAccounting,lstTransaction,lstRentsPerAccount);
        }
        
        if(lstAccounting.size()>0){
            try{
                DMLHandler.updateRentTimeStamp(DMLHandler.updateMatchFailResonOnBankTransaction(lstAccounting));
            }catch(Exception ex){
                System.debug('AutoMapTransactionWithRentController class line no 79::'+ ex.getMessage());
            }   
        }  
    }
    
     /**
    * @description inserting matching rent and transaction.
    * @param lstAccounting list of Accounting object to be created.
    * @param lstTransaction  transactions matched with rent.
    * @param lstRentsPerAccount rents related to the transaction.
    */
    public static void createAccountingRecordForRentAndTransaction(List<HBX_Accounting__c> lstAccounting,List<HBX_BankTransaction__c> lstTransaction,List<HBX_Rent__c> lstRentsPerAccount){
        for(HBX_BankTransaction__c bankTransaction :lstTransaction){
            // Sobject transactionRecord = bankTransaction;
            for(HBX_Rent__c rent : lstRentsPerAccount){
                // Sobject rentRecord = rent;
                if(bankTransaction.Accountings__r.size()==0 ){ //&& rent.HBX_GrossRentAmount__c == bankTransaction.HBX_Amount__c
                    HBX_Accounting__c accounting = new HBX_Accounting__c();
                    accounting.HBX_BankTransaction__c = bankTransaction.Id;
                    accounting.HBX_Rent__c = rent.Id;
                    accounting.HBX_PaidAmount__c = rent.HBX_GrossRentAmount__c;
                    accounting.HBX_IsAutomaticMatch__c = true;
                    lstAccounting.add(accounting);
                }
            }
        }
    }
    
    public static String getOperator(String operatorName){
        if(operatorName.equalsIgnoreCase('equals')){
            return '=';
        }else if(operatorName.equalsIgnoreCase('not equals to')){
            return '!=';
        }
        else if(operatorName.equalsIgnoreCase('less than')){
            return '<';
        }
        else if(operatorName.equalsIgnoreCase('greater than')){
            return '>';
        }
        else if(operatorName.equalsIgnoreCase('contains')){
            return 'like';
        }
        else if(operatorName.equalsIgnoreCase('greater than equal to')){
            return '>=';
        }else if(operatorName.equalsIgnoreCase('less than equal to')){
            return '<=';
        }
        
        return null;
    }
    
    public static String mapRentTransactionFieldsPerCriteria(HBX_BankTransaction__c bankTransaction){
        //Map<Integer,RentTransactionFieldsPerCriteriaWrapper> mapFilterCriteriaPerSequence = new Map<Integer,RentTransactionFieldsPerCriteriaWrapper>();
        Map<String,SObject> mapMatchingCriteria = HBX_PaymentMatchingCriteria__c.getAll();
        Integer count = 0;
        String matchingLogic ='';
        Boolean matchingLogicAvailable = true;
        List<DateTime> transactionFieldDateTimeValue = new List<DateTime>();
        List<Date> transactionFieldDateValue = new List<Date>();
        
        Sobject transactionRecord = bankTransaction;
        
        for(String transactionField : mapMatchingCriteria.keyset()){
            count++;
            if(matchingLogic==''){
                matchingLogic = String.valueof(mapMatchingCriteria.get(transactionField).get('HBX_FilterLogic__c'));
                matchingLogic = matchingLogic==null?'':matchingLogic;
                system.debug('matchingLogic :: '+matchingLogic);
                if(String.isBlank(matchingLogic)){
                    matchingLogicAvailable = false;
                }else{
                    matchingLogicAvailable = true;
                }
            }
            String transactionFieldValue = String.valueof(mapMatchingCriteria.get(transactionField).get('Name'));
            String operator = getOperator(String.valueof(mapMatchingCriteria.get(transactionField).get('HBX_Operator__c')));
            String rentField = String.valueof(mapMatchingCriteria.get(transactionField).get('HBX_RentField__c'));
            String dataType = String.valueof(mapMatchingCriteria.get(transactionField).get('HBX_DataType__c'));
            
            system.debug(transactionFieldValue+' '+operator+' '+rentField);
            
            if(matchingLogicAvailable && matchingLogic!='' && matchingLogic!=null){
                if(operator.equalsIgnoreCase('like')){
                    matchingLogic = matchingLogic.subString(0,matchingLogic.lastIndexOf(String.valueof(count)))+' '+matchingLogic.subString(matchingLogic.lastIndexOf(String.valueof(count)),matchingLogic.length()).replace(String.valueof(count),rentField+' '+operator+' %'+transactionRecord.get(transactionFieldValue)!=null?String.valueof(transactionRecord.get(transactionFieldValue)):null+'%');
                }else if(dataType!=null && dataType.equalsIgnoreCase('string')){
                    matchingLogic = matchingLogic.subString(0,matchingLogic.lastIndexOf(String.valueof(count)))+' '+matchingLogic.subString(matchingLogic.lastIndexOf(String.valueof(count)),matchingLogic.length()).replace(String.valueof(count),rentField+' '+operator+' '+transactionRecord.get(transactionFieldValue)!=null?'\''+String.valueof(transactionRecord.get(transactionFieldValue))+'\'':null);
                }else if(dataType!=null && dataType.equalsIgnoreCase('datetime')){
                    DateTime dateTimeValue = transactionRecord.get(transactionFieldValue)!=NULL?DateTime.valueof(String.valueof(transactionRecord.get(transactionFieldValue))):NULL;
                    matchingLogic = matchingLogic.subString(0,matchingLogic.lastIndexOf(String.valueof(count)))+' '+matchingLogic.subString(matchingLogic.lastIndexOf(String.valueof(count)),matchingLogic.length()).replace(String.valueof(count),rentField+' '+operator+' '+dateTimeValue!=null?JSON.serialize(dateTimeValue).remove('"').remove('"'):null);
                    
                }else if(dataType!=null && dataType.equalsIgnoreCase('date')){
                    Date dateValue = transactionRecord.get(transactionFieldValue)!=null?Date.valueof(String.valueof(transactionRecord.get(transactionFieldValue))):null;
                    matchingLogic = matchingLogic.subString(0,matchingLogic.lastIndexOf(String.valueof(count)))+' '+matchingLogic.subString(matchingLogic.lastIndexOf(String.valueof(count)),matchingLogic.length()).replace(String.valueof(count),rentField+' '+operator+' '+(dateValue!=null?String.valueof(dateValue):null));
                }
                else{
                   matchingLogic = matchingLogic.subString(0,matchingLogic.lastIndexOf(String.valueof(count)))+' '+matchingLogic.subString(matchingLogic.lastIndexOf(String.valueof(count)),matchingLogic.length()).replace(String.valueof(count),rentField+' '+operator+' '+transactionRecord.get(transactionFieldValue));
                   
                   system.debug('matchingLogic ::else '+matchingLogic);
                }
            }else{
                system.debug('dataType ::'+ dataType); 
                if(operator.equalsIgnoreCase('like')){
                    matchingLogic += rentField+' '+operator+' %'+transactionRecord.get(transactionFieldValue)!=null?String.valueof(transactionRecord.get(transactionFieldValue)):null+'%'+' AND ';
                }else if(dataType!=null && dataType.equalsIgnoreCase('string')){
                    matchingLogic += rentField+' '+operator+' '+transactionRecord.get(transactionFieldValue)!=null?'\''+transactionRecord.get(transactionFieldValue)+'\'':null+' AND ';
                }else if(dataType!=null && dataType.equalsIgnoreCase('datetime')){
                    DateTime dateTimeValue = transactionRecord.get(transactionFieldValue)!=NULL?DateTime.valueof(String.valueof(transactionRecord.get(transactionFieldValue))):NULL;
                    matchingLogic += rentField+' '+operator+' '+(dateTimeValue!=null?JSON.serialize(dateTimeValue).remove('"').remove('"'):null)+' AND ';
                    system.debug('dtTiem ::'+ rentField +' : '+JSON.serialize(dateTimeValue));
                }else if(dataType!=null && dataType.equalsIgnoreCase('date')){
                    Date dateValue = transactionRecord.get(transactionFieldValue)!=null?Date.valueof(String.valueof(transactionRecord.get(transactionFieldValue))):null;
                    matchingLogic += rentField+' '+operator+' '+(dateValue!=null?String.valueof(dateValue):null)+' AND ';
                }else{
                    system.debug('dtTiem :: else'+transactionFieldValue);
                   matchingLogic += rentField+' '+operator+' '+transactionRecord.get(transactionFieldValue)+' AND ';
                }
            }
        }
        if(matchingLogic!=''){
           matchingLogic = matchingLogic.removeEnd(' AND ');
        }
        system.debug('matchingLogic1 :: '+matchingLogic);
        return matchingLogic;
    }
    
    public class mapRentTransactionFieldsPerCriteriaForSpecificField{//
        public string matchingString ;
        public List<DateTime> transactionFieldDateTimeValue;
        public List<Date> transactionFieldDateValue;
        public mapRentTransactionFieldsPerCriteriaForSpecificField(string matchingString,List<DateTime> transactionFieldDateTimeValue,List<Date> transactionFieldDateValue){
            this.matchingString = matchingString;
            this.transactionFieldDateTimeValue = transactionFieldDateTimeValue;
            this.transactionFieldDateValue = transactionFieldDateValue;
        }
    }
     /**
    * @description method maps all rents with related contracts.
    * @param setOfContractId set of contract Ids.
    */
    
    public static Map<Id,List<HBX_Rent__c>> matchRentWithContract(Set<Id> setOfContractId,HBX_BankTransaction__c bankTransaction){
        
        String filterRentPerCriteria = mapRentTransactionFieldsPerCriteria(bankTransaction);
        // List<DateTime> transactionFieldDateTimeValue = filterRentPerCriteria.transactionFieldDateTimeValue;
        // List<Date> transactionFieldDateValue = filterRentPerCriteria.transactionFieldDateValue;
        List<HBX_Rent__c> lstRent =  new List<HBX_Rent__c>();
        
        system.debug('query :: '+'select id,HBX_Contract__c,HBX_PayedAmount__c,HBX_GrossRentAmount__c from HBX_Rent__c where HBX_Contract__c IN: setOfContractId AND '+ filterRentPerCriteria+' limit 50000');
        
        if(filterRentPerCriteria==''){
            lstRent =  [select id,HBX_Contract__c,HBX_PayedAmount__c,HBX_GrossRentAmount__c from HBX_Rent__c where HBX_Contract__c IN: setOfContractId AND HBX_GrossRentAmount__c =:bankTransaction.HBX_Amount__c  limit 50000];
        }else{
            lstRent =  Database.query('select id,HBX_Contract__c,HBX_PayedAmount__c,HBX_GrossRentAmount__c from HBX_Rent__c where HBX_Contract__c IN: setOfContractId AND '+ filterRentPerCriteria+' limit 50000');
        }
        system.debug('lstRent ::matchRentWithContract  '+lstRent +' filterRentPerCriteria '+filterRentPerCriteria);
        Map<Id,List<HBX_Rent__c>> mapRentContractId = new Map<Id,List<HBX_Rent__c>>();
        for(HBX_Rent__c rent :lstRent){
            if(mapRentContractId.containsKey(rent.HBX_Contract__c)){
                mapRentContractId.get(rent.HBX_Contract__c).add(rent);
            }else{
                mapRentContractId.put(rent.HBX_Contract__c,new List<HBX_Rent__c>{rent});
            }
        }
        return mapRentContractId;
    }
    
     /**
    * @description method maps Accounts with related contracts based on tenant records.
    * @param setAccId set of Account Ids.
    *
    */
    public static Map<Id,Id> matchAccountWithContract(Set<Id> setAccId){
        List<HBX_Payer__c> lstTenant =  [select id,HBX_Account__c,HBX_Contract__c from HBX_Payer__c where HBX_Account__c IN: setAccId  limit 50000];
        Map<Id,Id> mapAccountWithContractId = new Map<Id,Id>();
        for(HBX_Payer__c tenant :lstTenant){
            if(tenant.HBX_Contract__c!=null){
                mapAccountWithContractId.put(tenant.HBX_Contract__c,tenant.HBX_Account__c);
            }
        }
        return mapAccountWithContractId;
    }
     /**
    * @description match particular Account With transactions IBAN NO. Rteurns Account's Id If exists.
    *@Param transactionIBAN IBAN no For Related Transaction.
    */
    public static Map<Id,String> matchIBANOnAccount(List<HBX_BankTransaction__c> bankTransactionList){
        Set<String> lstIBANOfTransaction = new Set<String>();
        for(HBX_BankTransaction__c bankTransaction : bankTransactionList){
            lstIBANOfTransaction.add(bankTransaction.HBX_IBAN__c);
        }
        
        List<Account> accList =  [select id,HBX_IBAN__c from Account where HBX_IBAN__c IN : lstIBANOfTransaction  limit 10000];
        Map<Id,String> mapAccountWithIBAN = new Map<Id,String>();
        for(Account acc : accList){
            If(acc.HBX_IBAN__c!=null){
                mapAccountWithIBAN.put(acc.Id,acc.HBX_IBAN__c);
            }
        }
        return mapAccountWithIBAN;
    }
}