public class BalanceSheetController {
    //used to display Balance list on Component.
    // @AuraEnabled
    // public static List<BalanceSheetControllerWrapper> getRecords(Integer sizeOfRecords,Integer monthNumber) {
    //     List<HBX_Accounting__c> lst = new List<HBX_Accounting__c>();
    //     Set<Id> lstBankTransactionIds = new Set<Id>();
    //     List<BalanceSheetControllerWrapper> listOfWrapper = new List<BalanceSheetControllerWrapper>();
    //     System.debug('monthNumber '+ monthNumber+' sizeOfRecords :'+sizeOfRecords);
    //     if(sizeOfRecords != null){
    //         Map<Id, HBX_Accounting__c> mapOfAccounting = new Map<Id, HBX_Accounting__c>([SELECT id,HBX_Rent__c, HBX_Rent__r.Name, HBX_Rent__r.HBX_GrossRentAmount__c,HBX_PaidAmount__c  FROM HBX_Accounting__c where CALENDAR_MONTH(CreatedDate) =:Integer.valueof(monthNUmber)]);
    //         System.debug(mapOfAccounting);
            
    //         for(Id accId :mapOfAccounting.keyset()){
    //             lstBankTransactionIds.add(mapOfAccounting.get(accId).HBX_Rent__c);
    //         }
    //         Map<Id,HBX_Rent__c> mapOfRent =  new Map<Id,HBX_Rent__c>();
    //         if(lstBankTransactionIds.size()>0){
    //             mapOfRent = new Map<Id,HBX_Rent__c>([select Id,Name,HBX_Contract__c from HBX_Rent__c where Id IN:lstBankTransactionIds limit 50000]);
    //         }
    //         //System.debug('monthNUmber '+ monthNUmber+' sizeOfRecords :'+sizeOfRecords);
    //         List<AggregateResult> lstAss = [select HBX_Rent__c, SUM (HBX_PaidAmount__c) allAmount from HBX_Accounting__c GROUP BY HBX_Rent__c HAVING HBX_Rent__c IN :lstBankTransactionIds ];
            
    //         Map<Id,Decimal> mapForGrossTransaction = new Map<Id,Decimal>();
    //         for(AggregateResult aggrResult :lstAss){
    //             mapForGrossTransaction.put((Id) aggrResult.get('HBX_Rent__c'),(Decimal) aggrResult.get('allAmount'));
    //         }
    //         Set<Id> test = new Set<Id>();
            
    //         for(Id accId : mapOfAccounting.keySet()) {
    //             HBX_Accounting__c accValue = mapOfAccounting.get(accId);
    //             if(!test.contains(accValue.HBX_Rent__c)){
    //                 Decimal allSummerisedAmmountFromTransaction = mapForGrossTransaction.get(mapOfAccounting.get(accId).HBX_Rent__c);
    //                 listOfWrapper.add(new BalanceSheetControllerWrapper(mapOfRent.get(accValue.HBX_Rent__c),accValue.HBX_Rent__r.HBX_GrossRentAmount__c,allSummerisedAmmountFromTransaction));
    //                 test.add(accValue.HBX_Rent__c);
    //             }
    //         } 
    //     } 
    //     return listOfWrapper;
    // }
    
    
    // called from batch class to create balance list.
    public static List<BalanceSheetControllerWrapper> getAcountingRecords(List<HBX_Accounting__c> lstAccounting,Decimal lastMonthCredit,Boolean accountingFoundForCurrentMonth,HBX_Rent__c currentMonthRent,String lastMonthStatus,DateTime lastDunningDateTime,Boolean creatingBalanceListFirstTime,Date paymentTarget){
        system.debug('creatingBalanceListFirstTime :: '+creatingBalanceListFirstTime);
        if(!accountingFoundForCurrentMonth){
            createBalanceListForNoAccountingRecordInCurrentMonth(lastMonthCredit,currentMonthRent,lastMonthStatus,lastDunningDateTime,creatingBalanceListFirstTime,paymentTarget);
            return null;
        }
        List<HBX_Accounting__c> lst = new List<HBX_Accounting__c>();
        Set<Id> lstBankTransactionIds = new Set<Id>();
        List<BalanceSheetControllerWrapper> listOfWrapper = new List<BalanceSheetControllerWrapper>();
        //System.debug('monthNumber '+ monthNumber+' sizeOfRecords :'+sizeOfRecords);
        Map<Id, HBX_Accounting__c> mapOfAccounting = new Map<Id, HBX_Accounting__c>(lstAccounting);
        System.debug(mapOfAccounting);
        for(Id accId :mapOfAccounting.keyset()){
            lstBankTransactionIds.add(mapOfAccounting.get(accId).HBX_Rent__c);
        }
        Map<Id,Id> mapRentContractId = new Map<Id,Id>();
        Map<Id,HBX_Rent__c> mapOfRent =  new Map<Id,HBX_Rent__c>();
        if(lstBankTransactionIds.size()>0){
            mapOfRent = new Map<Id,HBX_Rent__c>([select Id,Name,HBX_Contract__c from HBX_Rent__c where Id IN:lstBankTransactionIds limit 50000]);
            for(HBX_Rent__c rentDetail:mapOfRent.values()){
               mapRentContractId.put(rentDetail.Id,rentDetail.HBX_Contract__c);
            }
        }
        //System.debug('monthNUmber '+ monthNUmber+' sizeOfRecords :'+sizeOfRecords);
        List<AggregateResult> lstAss = [select HBX_Rent__c,calendar_year(CreatedDate),calendar_month(CreatedDate), SUM (HBX_PaidAmount__c) allAmount from HBX_Accounting__c GROUP BY HBX_Rent__c,calendar_year(CreatedDate),calendar_month(CreatedDate) HAVING HBX_Rent__c IN :lstBankTransactionIds AND calendar_month(CreatedDate) =:System.today().month() AND calendar_year(CreatedDate)=:System.today().year()];
        Map<Id,Decimal> mapForGrossTransaction = new Map<Id,Decimal>();
        for(AggregateResult aggrResult :lstAss){
            mapForGrossTransaction.put((Id) aggrResult.get('HBX_Rent__c'),(Decimal) aggrResult.get('allAmount'));
        }
        Set<Id> rentId = new Set<Id>();
        
        for(Id accId : mapOfAccounting.keySet()) {
            HBX_Accounting__c accValue = mapOfAccounting.get(accId);
            if(!rentId.contains(accValue.HBX_Rent__c)){
                Decimal allSummerisedAmmountFromTransaction = mapForGrossTransaction.get(mapOfAccounting.get(accId).HBX_Rent__c);
                listOfWrapper.add(new BalanceSheetControllerWrapper(mapOfRent.get(accValue.HBX_Rent__c),accValue.HBX_Rent__r.HBX_GrossRentAmount__c,allSummerisedAmmountFromTransaction));
                rentId.add(accValue.HBX_Rent__c);
            }
        } 
        if(!mapRentContractId.isEmpty()){
            createBalanceList(listOfWrapper,mapRentContractId,mapOfAccounting,lastMonthCredit,lastMonthStatus,lastDunningDateTime,creatingBalanceListFirstTime,currentMonthRent,paymentTarget);
        }
        return listOfWrapper;
    }
    
    
    // creating balance sheet.
    public static List<BalanceSheetControllerWrapper> createBalanceList(List<BalanceSheetControllerWrapper> listOfBalanceSheetControllerWrapper,Map<Id,Id> mapRentContractId,Map<Id, HBX_Accounting__c> mapOfAccounting,Decimal lastMonthCredit,String lastMonthStatus,DateTime lastDunningDateTime,Boolean creatingBalanceListFirstTime,HBX_Rent__c currentMonthRent,Date paymentTarget){
        
        //Map<String,HBX_BalanceList__c>  mapBalanceSheetPerExterlanId = getBalanceListAsPerExternalId();
        system.debug('lastMonthStatus :: '+lastMonthStatus);
        Map<String,String> mapForDunningStages = new Map<String,String>{
            'Friendly Reminder' => 'Reminder 1',
            'Reminder 1' => 'Reminder 2',
            'Reminder 2' => 'Default',
            'Default' =>  'Default'
        };
        system.debug('mapForDunningStages :: '+mapForDunningStages.containsKey(lastMonthStatus));
        
        List<HBX_BalanceList__c> lstBalSheet = new List<HBX_BalanceList__c>();
        List<HBX_Accounting__c> lstAccounting = mapOfAccounting.values();
        for(BalanceSheetControllerWrapper balanceSheet : listOfBalanceSheetControllerWrapper){
            String externalId = mapRentContractId.get(balanceSheet.rent.id)+balanceSheet.rent.Name+String.valueof(system.today().month())+String.valueof(system.today().year());
            system.debug('rent ::Check  '+balanceSheet.rent.Name+' : totalRent : '+balanceSheet.rentTotalAmount+' : paid : '+balanceSheet.totalPaidAmount+lastMonthCredit);
            if(lastMonthStatus == ''){
                if(creatingBalanceListFirstTime){
                    lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=mapRentContractId.get(balanceSheet.rent.id),
                                Name=balanceSheet.rent.Name,HBX_ActualPaymentCurrentMonth__c = balanceSheet.totalPaidAmount,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit,
                                HBX_NextDunningStage__c = balanceSheet.rentTotalAmount<=(balanceSheet.totalPaidAmount+lastMonthCredit)?'Paid':'Friendly Reminder'
                                ,HBX_LastDunningDate__c = balanceSheet.rentTotalAmount<=(balanceSheet.totalPaidAmount+lastMonthCredit)?null:lastDunningDateTime,
                                HBX_PaymentTarget__c = (currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c!=null?Date.newInstance(system.today().year(), system.today().month(),Integer.valueof(currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c)):null)));
                }else{
                    lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=mapRentContractId.get(balanceSheet.rent.id),
                                Name=balanceSheet.rent.Name,HBX_ActualPaymentCurrentMonth__c = balanceSheet.totalPaidAmount,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit));
                }
            }else if(mapForDunningStages.containsKey(lastMonthStatus)){
                if(creatingBalanceListFirstTime){
                    lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=mapRentContractId.get(balanceSheet.rent.id),
                                Name=balanceSheet.rent.Name,HBX_ActualPaymentCurrentMonth__c = balanceSheet.totalPaidAmount,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit,
                                HBX_NextDunningStage__c = balanceSheet.rentTotalAmount<=(balanceSheet.totalPaidAmount+lastMonthCredit)?'Paid':mapForDunningStages.get(lastMonthStatus),
                                HBX_LastDunningDate__c = balanceSheet.rentTotalAmount<=(balanceSheet.totalPaidAmount+lastMonthCredit)?null:lastDunningDateTime,
                                HBX_PaymentTarget__c = balanceSheet.rentTotalAmount<=(balanceSheet.totalPaidAmount+lastMonthCredit)?(currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c!=null?Date.newInstance(system.today().year(), system.today().month(),Integer.valueof(currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c)):null):paymentTarget));
                }else{
                    lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=mapRentContractId.get(balanceSheet.rent.id),
                                Name=balanceSheet.rent.Name,HBX_ActualPaymentCurrentMonth__c = balanceSheet.totalPaidAmount,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit));
                }
            }
        }
        if(lstBalSheet.size()>0){
            try{
                upsert lstBalSheet HBX_ExternalId__c;
            }catch(Exception ee){
                system.debug('error while creating Balance Sheet');
            }
        }
        if(lstAccounting.size()>0 && lstBalSheet.size()>0){
            for(HBX_Accounting__c accounting :lstAccounting){
                accounting.HBX_BalanceList__c = lstBalSheet[0].Id;
            }
            update lstAccounting;
        }
        return null;
    }
    // in case there is no accounting for any rent in current month.
    public static List<BalanceSheetControllerWrapper> createBalanceListForNoAccountingRecordInCurrentMonth(Decimal lastMonthCredit,HBX_Rent__c currentMonthRent,String lastMonthStatus,DateTime lastDunningDateTime,Boolean creatingBalanceListFirstTime,Date paymentTarget){
        List<HBX_BalanceList__c> lstBalSheet = new List<HBX_BalanceList__c>();
        Map<String,String> mapForDunningStages = new Map<String,String>{
            'Friendly Reminder' => 'Reminder 1',
            'Reminder 1' => 'Reminder 2',
            'Reminder 2' => 'Default',
            'Default' =>  'Default'
        };
        String externalId = currentMonthRent.HBX_Contract__c+currentMonthRent.Name+String.valueof(system.today().month())+String.valueof(system.today().year());
        if(lastMonthStatus==''){
            if(creatingBalanceListFirstTime){
                lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=currentMonthRent.HBX_Contract__c,
                            Name=currentMonthRent.Name,HBX_ActualPaymentCurrentMonth__c = 0,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit,
                            HBX_NextDunningStage__c = currentMonthRent.HBX_GrossRentAmount__c<=lastMonthCredit?'Paid':'Friendly Reminder',
                            HBX_LastDunningDate__c=currentMonthRent.HBX_GrossRentAmount__c<=lastMonthCredit?null:lastDunningDateTime,
                            HBX_PaymentTarget__c = currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c!=null?Date.newInstance(system.today().year(), system.today().month(),Integer.valueof(currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c)):null));//HBX_BalanceListStatus__c = 
            }else{
                lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=currentMonthRent.HBX_Contract__c,Name=currentMonthRent.Name,HBX_ActualPaymentCurrentMonth__c = 0,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit));//HBX_BalanceListStatus__c = 
            }
            
        }else if(mapForDunningStages.containsKey(lastMonthStatus)){
            if(creatingBalanceListFirstTime){
                lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=currentMonthRent.HBX_Contract__c,
                            Name=currentMonthRent.Name,HBX_ActualPaymentCurrentMonth__c = 0,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit,
                            HBX_NextDunningStage__c = currentMonthRent.HBX_GrossRentAmount__c<=lastMonthCredit?'Paid':mapForDunningStages.get(lastMonthStatus),
                            HBX_LastDunningDate__c = currentMonthRent.HBX_GrossRentAmount__c<=lastMonthCredit?null:lastDunningDateTime,
                            HBX_PaymentTarget__c = currentMonthRent.HBX_GrossRentAmount__c<=lastMonthCredit?(currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c!=null?Date.newInstance(system.today().year(), system.today().month(),Integer.valueof(currentMonthRent.HBX_Contract__r.HBX_PaymentDeadlineDay__c)):null):paymentTarget));//HBX_BalanceListStatus__c = 
            }else{
                lstBalSheet.add(new HBX_BalanceList__c(HBX_Building__c=currentMonthRent.HBX_Contract__r.HBX_Building__c,HBX_ExternalId__c = externalId,HBX_ContractNumber__c=currentMonthRent.HBX_Contract__c,Name=currentMonthRent.Name,HBX_ActualPaymentCurrentMonth__c = 0,HBX_DeltaCreditTotalPreviousMonth__c = lastMonthCredit));//HBX_BalanceListStatus__c = 
            }
            
        }
        try{
          upsert lstBalSheet HBX_ExternalId__c;
        }catch(Exception ee){
            system.debug('error while creating BS when no accounting found in current month');
        }                
        return null;
    }
    
    // lock old balance list.
    public static void lockPreviousMonthdBalanceList() {
        Date  currentDate = System.today().addMonths(-1);
        
        List<HBX_BalanceList__c> listOfBalanceList = new List<HBX_BalanceList__c>();
        for(HBX_BalanceList__c objBalanceList : [SELECT id, HBX_BalanceListStatus__c from HBX_BalanceList__c where HBX_BalanceListStatus__c=: 'Processing' AND CALENDAR_MONTH(CreatedDate) =: currentDate.month() AND CALENDAR_YEAR(CreatedDate) =: currentDate.year()]) {
            objBalanceList.HBX_BalanceListStatus__c = 'Locked';
            listOfBalanceList.add(objBalanceList);
        }
        try{
            if(listOfBalanceList.size() > 0){
                update listOfBalanceList;
            }else{
                System.debug('There is no balance list');
            }
        }catch(Exception ex){
            System.debug('BalanceSheetContlroller line no 142 ::'+ ex.getMessage());
        }
    }
    
}