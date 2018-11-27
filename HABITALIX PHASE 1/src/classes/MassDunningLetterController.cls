public class MassDunningLetterController {
    
    // @AuraEnabled public static List<MassDunningLetterControllerWrapper> getRecords() {
    //   // Map<Id, HBX_Accounting__c> mapOfAccounting = new Map<Id, HBX_Accounting__c>([SELECT Id, Name, HBX_BalanceList__c, Rent__c FROM HBX_Accounting__c]);
    //     Map<Id, List<HBX_Accounting__c>> mapOfAccountingWithBalanceListId = new Map<Id, List<HBX_Accounting__c>>();
    //     //Set<Id> listOfRent = new Set<Id>();
        
    //     Date myDate = System.today();
    //     Date newDate = myDate.addMonths(-1);
    //     Integer previousmonth = newDate.month();
    //     for(HBX_Accounting__c aa: [SELECT Id, Name,HBX_Rent__r.Name, HBX_BalanceList__c, HBX_BalanceList__r.HBX_CreditCurrentMonth__c, Rent__c FROM HBX_Accounting__c WHERE CALENDAR_MONTH(CreatedDate) =: 08 AND HBX_BalanceList__r.HBX_CreditCurrentMonth__c < 0 LIMIT 50000]){
    //         if(mapOfAccountingWithBalanceListId.containsKey(aa.HBX_BalanceList__c)) {
    //           //  listOfRent.add(aa.Rent__c);
                
    //           // System.debug(aa.HBX_Rent__r.Name);
    //             //System.debug(aa.HBX_BalanceList__r.HBX_CreditCurrentMonth__c);
                
    //             List<HBX_Accounting__c> acc = mapOfAccountingWithBalanceListId.get(aa.HBX_BalanceList__c);
    //             acc.add(aa);
    //             mapOfAccountingWithBalanceListId.put(aa.HBX_BalanceList__c, acc);  
    //         }else{
    //              //listOfRent.add(aa.Rent__c);
    //             mapOfAccountingWithBalanceListId.put(aa.HBX_BalanceList__c, new List<HBX_Accounting__c> { aa });
                
    //              //System.debug(aa.HBX_Rent__r.Name);
    //              //System.debug(aa.HBX_BalanceList__r.HBX_CreditCurrentMonth__c);
    //         }
    //     }
    //     System.debug('mapOfAccountingWithBalanceListId::'+mapOfAccountingWithBalanceListId);
        
    //     for(Id balanceListId : mapOfAccountingWithBalanceListId.keySet()){
    //         Integer i = 0;
    //         for(HBX_Accounting__c accounting : mapOfAccountingWithBalanceListId.get(balanceListId)) {
    //             System.debug(accounting);  
    //         }
    //     }
    //     return null;
    // }
    
    
    //used to display dunning records on component.
    @AuraEnabled 
    public static List<MassDunningLetterControllerWrapper> getDunningRecords() {
        system.debug(' system : '+(system.Today().month()-1));
        Integer previousmonth = Test.isRunningTest()?System.today().month():System.today().addMonths(-1).month();
        Integer currentyear = Test.isRunningTest()?System.today().year():System.today().addMonths(-1).year();
        
        List<HBX_BalanceList__c> lstBalanceList =  [SELECT Id,HBX_Building__c,HBX_PaymentTarget__c,HBX_Building__r.Name,Name,HBX_CreditTotal__c,HBX_ExpectedPaymentCurrentMonth__c,HBX_NextDunningStage__c,HBX_LastDunningDate__c,HBX_ContractNumber__c,HBX_ContractNumber__r.HBX_PaymentDeadlineDay__c,
                                                        HBX_CreditCurrentMonth__c,(select Id,HBX_Rent__c,HBX_IsAutomaticMatch__c,CreatedDate, Name,HBX_Rent__r.Name,HBX_Rent__r.HBX_GrossRentAmount__c,HBX_Rent__r.HBX_Contract__c,
                                                        HBX_Rent__r.HBX_Contract__r.HBX_StartDate__c, HBX_BalanceList__c from Accountings__r limit 200) 
                                                        from HBX_BalanceList__c where HBX_CreditTotal__c < 0 AND CALENDAR_MONTH(CreatedDate) =: previousmonth AND CALENDAR_YEAR(CreatedDate)=:currentyear];
        
        Map<Id,List<HBX_Accounting__c>> mapAccountingPerBalList =  new Map<Id,List<HBX_Accounting__c>>();
        List<Id> lstContractId = new List<Id>();
        
        Integer i=0;
        List<MassDunningLetterControllerWrapper> lstMassDunningLetterControllerWrapper = new List<MassDunningLetterControllerWrapper>();
        Boolean isManualMatch = false;
        Boolean isAutoMatch = false;
        Integer count  = -1;
        
        for(HBX_BalanceList__c balList :lstBalanceList){
            mapAccountingPerBalList.put(balList.Id,balList.Accountings__r);
            lstContractId.add(balList.HBX_ContractNumber__c);
        }
        List<HBX_Rent__c> lstRent = [select id,HBX_Contract__c,Name,HBX_GrossRentAmount__c,HBX_Contract__r.HBX_StartDate__c from HBX_Rent__c where HBX_Contract__c IN: lstContractId];
        Map<Id,List<HBX_Rent__c>> mapOfContractIdAndRent = new Map<Id,List<HBX_Rent__c>>();
        for(HBX_Rent__c rent : lstRent){
            if(mapOfContractIdAndRent.containsKey(rent.HBX_Contract__c)){
                mapOfContractIdAndRent.get(rent.HBX_Contract__c).add(rent);
            }else{
                mapOfContractIdAndRent.put(rent.HBX_Contract__c,new List<HBX_Rent__c>{rent});
            }
        }
        
        Map<Id,Decimal> mapOfRentPaidAmount = DMLHandler.retrievePaidRentAmountForRentInCurrentMonth(lstRent);
        system.debug('mapOfRentPaidAmount :: '+mapOfRentPaidAmount);
        for(Id  balanceListId : mapAccountingPerBalList.keyset()){
            count++;
            if(mapAccountingPerBalList.get(balanceListId).size()>0){ 
                List<DateTime> accountingCreationDate = new List<DateTime>();
                Id rentId ;
                for(HBX_Accounting__c accounting : mapAccountingPerBalList.get(balanceListId)){
                    if(accounting.HBX_IsAutomaticMatch__c){
                        isAutoMatch = true;
                    }else{
                        isManualMatch = true;
                    }
                    rentId = accounting.HBX_Rent__c;
                    accountingCreationDate.add(accounting.CreatedDate);
                }
                if(accountingCreationDate.size()>0){
                    accountingCreationDate.sort();
                }
                if(isAutoMatch){  // mapAccountingPerBalList.get(balanceListId)[0].HBX_Rent__r.HBX_GrossRentAmount__c    mapAccountingPerBalList.get(balanceListId)[0].HBX_Rent__r.HBX_Contract__r.HBX_StartDate__c
                    lstMassDunningLetterControllerWrapper.add(new MassDunningLetterControllerWrapper(mapAccountingPerBalList.get(balanceListId)[0].HBX_Rent__r.Name,mapAccountingPerBalList.get(balanceListId)[0].HBX_Rent__c,
                                                            lstBalanceList[count].HBX_ExpectedPaymentCurrentMonth__c,lstBalanceList[count].HBX_PaymentTarget__c,null,accountingCreationDate[accountingCreationDate.size()-1],
                                                            lstBalanceList[count].HBX_ContractNumber__c,lstBalanceList[count].HBX_CreditTotal__c,lstBalanceList[count].HBX_CreditCurrentMonth__c,lstBalanceList[count].HBX_NextDunningStage__c
                                                            ,balanceListId,lstBalanceList[count].HBX_LastDunningDate__c,(String)lstBalanceList[count].HBX_Building__c,lstBalanceList[count].HBX_Building__r.Name));//
                }else if(isManualMatch){
                    lstMassDunningLetterControllerWrapper.add(new MassDunningLetterControllerWrapper(mapAccountingPerBalList.get(balanceListId)[0].HBX_Rent__r.Name,mapAccountingPerBalList.get(balanceListId)[0].HBX_Rent__c,
                                                            lstBalanceList[count].HBX_ExpectedPaymentCurrentMonth__c,lstBalanceList[count].HBX_PaymentTarget__c,accountingCreationDate[accountingCreationDate.size()-1],
                                                            null,lstBalanceList[count].HBX_ContractNumber__c,lstBalanceList[count].HBX_CreditTotal__c,lstBalanceList[count].HBX_CreditCurrentMonth__c,lstBalanceList[count].HBX_NextDunningStage__c,
                                                            balanceListId,lstBalanceList[count].HBX_LastDunningDate__c,(String)lstBalanceList[count].HBX_Building__c,lstBalanceList[count].HBX_Building__r.Name));
                }
                isAutoMatch = false;
                isManualMatch = false;
                accountingCreationDate.clear();
            }else{ //in case no accounting records found.
                for(HBX_Rent__c rent: mapOfContractIdAndRent.get(lstBalanceList[count].HBX_ContractNumber__c)){
                    if(rent.Name == lstBalanceList[count].Name){
                        lstMassDunningLetterControllerWrapper.add(new MassDunningLetterControllerWrapper(rent.Name,rent.Id,lstBalanceList[count].HBX_ExpectedPaymentCurrentMonth__c,
                                                                lstBalanceList[count].HBX_PaymentTarget__c,
                                                                null,null,lstBalanceList[count].HBX_ContractNumber__c,0-lstBalanceList[count].HBX_ExpectedPaymentCurrentMonth__c,lstBalanceList[count].HBX_CreditCurrentMonth__c,
                                                                lstBalanceList[count].HBX_NextDunningStage__c,balanceListId,lstBalanceList[count].HBX_LastDunningDate__c,(String)lstBalanceList[count].HBX_Building__c,lstBalanceList[count].HBX_Building__r.Name));//
                        break;
                    }
                }
                //lstMassDunningLetterControllerWrapper.add(new MassDunningLetterControllerWrapper(lstBalanceList[count].Name,lstBalanceList[count].HBX_ExpectedPaymentCurrentMonth__c,lstBalanceList[count].HBX_ContractNumber__r.HBX_StartDate__c,null,null,lstBalanceList[count].HBX_ContractNumber__c,0-lstBalanceList[count].HBX_ExpectedPaymentCurrentMonth__c));//
            }
        }
        return lstMassDunningLetterControllerWrapper;
     }  
     
     // used to create tasks for dunning records.
     @AuraEnabled 
     public static string createTaskForDunningProcess(String dunningDetail) {
         system.debug('dunningDetail :: '+dunningDetail);
        //  return contractIds;
        // {"a0r1q0000005bdnAAA":"Reminder 2:a081q0000004sGJAAY"}
        // system.debug('mapForRentIdAndTransactions  :: '+mapForRentIdAndTransactions+' statusContractInfo '+statusContractInfo);
        return AssignTaskForDunningProcessController.AssignTaskForDunningProcess(dunningDetail);
     }
}