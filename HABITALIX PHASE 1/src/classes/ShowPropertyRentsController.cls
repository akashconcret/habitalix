public  class ShowPropertyRentsController {
    public ShowPropertyRentsController(){
        
    }
    
    @AuraEnabled
    public static List<RentDetailsWrapper> returnRents(integer monthNumber,string filterType,Integer recordToShow){
        system.debug('filterType  : '+filterType);
        //string searchKeyword = '%'+keyword+'%';
        List<RentDetailsWrapper> lstRentDetailsWrapper = new List<RentDetailsWrapper>();
        List<String> lstIdAccounting = new List<String>();
        List<Id> lstIdBuilingPortFolio = new List<Id>();
        List<Id> lstIdBuiling = new List<Id>();
        List<Id> lstIdContract = new List<Id>();
        
        lstIdAccounting = retrieveAccountingRecords(lstIdAccounting); 
        // List< HBX_PropertyOwnership__c > lstBuildingOwnership = [select Building__c  from HBX_PropertyOwnership__c where ownerId = : userInfo.getUserId()];
        List< HBX_Portfolio__c> lstBuildingPortFolio = [select id from HBX_Portfolio__c where ownerId = : userInfo.getUserId()];
        
        for(HBX_Portfolio__c buildingPortfolio :lstBuildingPortFolio){
            lstIdBuilingPortFolio.add(buildingPortfolio.Id);
        }
        
        List<HBX_Building__c> lstBuilding = [select id from HBX_Building__c where HBX_Portfolio__c IN : lstIdBuilingPortFolio];
        
        for(HBX_Building__c building :lstBuilding){
            lstIdBuiling.add(building.Id);
        }
        if(lstIdBuiling.size()>0){
            List< HBX_Contract__c > lstContract = [select id , HBX_Building__c   from HBX_Contract__c  where HBX_Building__c  IN : lstIdBuiling];
            for(HBX_Contract__c contract :lstContract){
                lstIdContract.add(contract.id);
            }
        }
        
        List<HBX_Payer__c> lstPayer = [select id,Name,HBX_MainPayer__c ,HBX_Contract__c,HBX_Account__c,HBX_Account__r.Name,createdDate  from HBX_Payer__c where HBX_Contract__c IN:lstIdContract limit 10000];
        Map<Id,String> mapForContarctIdAndRelatedAccName = new Map<Id,String>();
        for(HBX_Payer__c payer :lstPayer){
            if(payer.HBX_MainPayer__c){
                mapForContarctIdAndRelatedAccName.put(payer.HBX_Contract__c,payer.HBX_Account__r.Name);
            }
        }
        List<HBX_Rent__c> lstRents = [select id,Name,HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name, HBX_RentDate__c ,HBX_Contract__c,HBX_Contract__r.HBX_Building__r.HBX_BankAccount__c,HBX_Contract__r.HBX_UnitAddress__c,HBX_PayedAmount__c,HBX_GrossRentAmount__c,createdDate  from HBX_Rent__c where HBX_Contract__c IN:lstIdContract ORDER BY CreatedDate ASC limit 10000];
        system.debug('lstRents  :: '+lstRents.size()+'   ::  lstIdContract  ' +lstIdContract);
        // decides paid rent amount per rent in current month.
        Map<Id,Decimal> mapOfRentPaidAmount = DMLHandler.retrievePaidRentAmountForRentInCurrentMonth(lstRents);
        system.debug('mapOfRentPaidAmount 11  : '+mapOfRentPaidAmount);
        if(!PortFolioSharingUtility.isPortFolioPrivate().equalsIgnoreCase('Private')){
            addOtherPortFolioInvoices(lstRents);
        }
        return returnRentsAsPerFilters(mapOfRentPaidAmount,lstRents,String.valueof(filterType),lstRentDetailsWrapper,mapForContarctIdAndRelatedAccName,recordToShow,userInfo.getName(),PortFolioSharingUtility.isPortFolioPrivate());
    }
    
    public static void addOtherPortFolioInvoices(List<HBX_Rent__c> lstRents){
        List< HBX_Portfolio__c> lstBuildingPortFolio = [select id from HBX_Portfolio__c where ownerId != : userInfo.getUserId()];
        List<Id> lstIdBuilingPortFolio = new List<Id>();
        List<Id> lstIdBuiling = new List<Id>();
        List<Id> lstIdContract = new List<Id>();
        
        for(HBX_Portfolio__c buildingPortfolio :lstBuildingPortFolio){
            lstIdBuilingPortFolio.add(buildingPortfolio.Id);
        }
        
        List<HBX_Building__c> lstBuilding = [select id from HBX_Building__c where HBX_Portfolio__c IN : lstIdBuilingPortFolio];
        
        for(HBX_Building__c building :lstBuilding){
            lstIdBuiling.add(building.Id);
        }
        if(lstIdBuiling.size()>0){
            List< HBX_Contract__c > lstContract = [select id , HBX_Building__c   from HBX_Contract__c  where HBX_Building__c  IN : lstIdBuiling];
            for(HBX_Contract__c contract :lstContract){
                lstIdContract.add(contract.id);
            }
        }
        
        List<HBX_Payer__c> lstPayer = [select id,Name, HBX_MainPayer__c ,HBX_Contract__c,HBX_Account__c,HBX_Account__r.Name,createdDate  from HBX_Payer__c where HBX_Contract__c IN:lstIdContract limit 10000];
        Map<Id,String> mapForContarctIdAndRelatedAccName = new Map<Id,String>();
        for(HBX_Payer__c payer :lstPayer){
            if(payer.HBX_MainPayer__c){
                mapForContarctIdAndRelatedAccName.put(payer.HBX_Contract__c,payer.HBX_Account__r.Name);
            }
        }
        lstRents.addAll([select id,Name,HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name, HBX_RentDate__c ,HBX_Contract__c,HBX_Contract__r.HBX_Building__r.HBX_BankAccount__c,HBX_Contract__r.HBX_UnitAddress__c,HBX_PayedAmount__c,HBX_GrossRentAmount__c,createdDate  from HBX_Rent__c where HBX_Contract__c IN:lstIdContract ORDER BY CreatedDate ASC limit 10000]);
    }
    
    public static List<RentDetailsWrapper> returnRentsAsPerFilters(Map<Id,Decimal> mapOfRentPaidAmount,List<HBX_Rent__c> lstRents ,string filterType,List<RentDetailsWrapper> lstRentDetailsWrapper,Map<Id,String> mapForContarctIdAndRelatedAccName,Integer recordToShow,String ownerName,String sharingModal){
        Integer rentsCountToShow = Integer.valueof(recordToShow);
        Integer count = 0;
        if(filterType == 'All'){
            for(HBX_Rent__c hbxRent : lstRents){
                system.debug('tst :: '+ownerName+' : '+hbxRent.HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name+' '+sharingModal);
                if(rentsCountToShow!=0 && count==rentsCountToShow){
                    return lstRentDetailsWrapper;
                }
                if(mapOfRentPaidAmount.containsKey(hbxRent.Id)){
                    lstRentDetailsWrapper.add(new RentDetailsWrapper(hbxRent,mapForContarctIdAndRelatedAccName.get(hbxRent.HBX_Contract__c),new List<HBX_BankTransaction__c>(),mapOfRentPaidAmount.get(hbxRent.Id)-hbxRent.HBX_GrossRentAmount__c,(ownerName==hbxRent.HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name || sharingModal.equalsIgnoreCase('ReadWrite'))?true:false));
                }else {
                    lstRentDetailsWrapper.add(new RentDetailsWrapper(hbxRent,mapForContarctIdAndRelatedAccName.get(hbxRent.HBX_Contract__c),new List<HBX_BankTransaction__c>(),0-hbxRent.HBX_GrossRentAmount__c,(ownerName==hbxRent.HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name || sharingModal.equalsIgnoreCase('ReadWrite'))?true:false));
                }
                count++;
            }
        }else if(filterType == 'Partial matched Rents'){
            for(HBX_Rent__c hbxRent : lstRents){
                
                if(rentsCountToShow!=0 && count==rentsCountToShow){
                    return lstRentDetailsWrapper;
                }
                if(mapOfRentPaidAmount.containsKey(hbxRent.Id) && (mapOfRentPaidAmount.get(hbxRent.Id)-hbxRent.HBX_GrossRentAmount__c)<0){
                    lstRentDetailsWrapper.add(new RentDetailsWrapper(hbxRent,mapForContarctIdAndRelatedAccName.get(hbxRent.HBX_Contract__c),new List<HBX_BankTransaction__c>(),mapOfRentPaidAmount.get(hbxRent.Id)-hbxRent.HBX_GrossRentAmount__c,(ownerName==hbxRent.HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name || sharingModal.equalsIgnoreCase('ReadWrite'))?true:false));
                }
                count++;
            }
        }else if(filterType == 'Total matched Rents'){
            for(HBX_Rent__c hbxRent : lstRents){
                
                if(rentsCountToShow!=0 && count==rentsCountToShow){
                    return lstRentDetailsWrapper;
                }
                if(mapOfRentPaidAmount.containsKey(hbxRent.Id) && (mapOfRentPaidAmount.get(hbxRent.Id)-hbxRent.HBX_GrossRentAmount__c)>=0){
                    lstRentDetailsWrapper.add(new RentDetailsWrapper(hbxRent,mapForContarctIdAndRelatedAccName.get(hbxRent.HBX_Contract__c),new List<HBX_BankTransaction__c>(),mapOfRentPaidAmount.get(hbxRent.Id)-hbxRent.HBX_GrossRentAmount__c,(ownerName==hbxRent.HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name || sharingModal.equalsIgnoreCase('ReadWrite'))?true:false));
                }
                count++;
            }
        }else if(filterType == 'Not matched Rents'){
            for(HBX_Rent__c hbxRent : lstRents){
                
                if(rentsCountToShow!=0 && count==rentsCountToShow){
                    return lstRentDetailsWrapper;
                }
                if(!(mapOfRentPaidAmount.containsKey(hbxRent.Id))){
                    lstRentDetailsWrapper.add(new RentDetailsWrapper(hbxRent,mapForContarctIdAndRelatedAccName.get(hbxRent.HBX_Contract__c),new List<HBX_BankTransaction__c>(),0-hbxRent.HBX_GrossRentAmount__c,(ownerName==hbxRent.HBX_Contract__r.HBX_Building__r.HBX_Portfolio__r.Owner.Name || sharingModal.equalsIgnoreCase('ReadWrite'))?true:false));
                }
                count++;
            }
        }
        system.debug('lstRentDetailsWrapper  :: '+lstRentDetailsWrapper.size());
        return lstRentDetailsWrapper;
    }
    
    
    public static List<String> retrieveAccountingRecords(List<String> lstIdAccounting){
        for(HBX_Accounting__c accounting : [select HBX_Rent__c,HBX_PaidAmount__c,HBX_BankTransaction__r.HBX_Amount__c from HBX_Accounting__c where HBX_Rent__c != null  ORDER BY createdDate DESC limit 50000]){
        	    lstIdAccounting.add(accounting.HBX_Rent__c);
        }
        return lstIdAccounting;
    }
    
    
    @AuraEnabled
    public static List<TransactionDetailsWrapper> returnBankTransactions(string keyword,String transactionBankAccount,Integer numberOfMonthForTransaction,Integer numberOfrecords){
        string searchKeyword = '%'+keyword+'%';
        List<TransactionDetailsWrapper> lstTransactionDetailsWrapper = new List<TransactionDetailsWrapper>();
        // List<String> lstIdAccounting = new List<String>();
        
        // List<Id> lstIdBuiling = new List<Id>();
        // List<Id> lstStrForBankAccountId = new List<id>();
        // List< HBX_PropertyOwnership__c > lstBuildingOwnership = [select Building__c  from HBX_PropertyOwnership__c where ownerId = : userInfo.getUserId()];
        // for(HBX_PropertyOwnership__c propertyOwenerShip :lstBuildingOwnership){
        //     if(propertyOwenerShip.Building__c!=null){
        //         lstIdBuiling.add(propertyOwenerShip.Building__c);
        //     }
        // }
        // List< HBX_Building__c > lstBuildings = [select id,HBX_BankAccount__c  from HBX_Building__c where Id IN:lstIdBuiling];
        
        // if(lstBuildings.size()>0){
        //     for(HBX_Building__c lstBuild:lstBuildings){
        //         if(lstBuild.HBX_BankAccount__c!=null){
        //             lstStrForBankAccountId.add(lstBuild.HBX_BankAccount__c);
        //         }
        //     }
        // }
        system.debug('transactionBankAccount :: '+transactionBankAccount);
        List<HBX_BankTransaction__c> lstTransactions = new List<HBX_BankTransaction__c>();
        Map<Id,HBX_BankTransaction__c> mapForTransctionPerRent = new Map<Id,HBX_BankTransaction__c>(); 
        Boolean isValidDecimal = true;
        if(keyword!=null && keyword!=''){
            try{
                Decimal.valueof(searchKeyword.replaceAll('%', ''));
            }catch(Exception ee){
                isValidDecimal = false;
            } 
        }
        if(isValidDecimal && !String.isBlank(transactionBankAccount)){
            // AND HBX_Amount__c =: rentAmmount
            // if(keyword==null || keyword==''){
            //     mapForTransctionPerRent = new Map<Id,HBX_BankTransaction__c>([select id,Name ,HBX_Amount__c,CreatedDate  from HBX_BankTransaction__c where Id NOT IN : lstIdAccounting AND HBX_BankAccount__c IN:lstStrForBankAccountId]);
            // }else{
            // 	mapForTransctionPerRent = new Map<Id,HBX_BankTransaction__c>([select id,Name ,HBX_Amount__c,CreatedDate  from HBX_BankTransaction__c where (Name LIKE :searchKeyword OR HBX_Amount__c =: Decimal.valueof(searchKeyword.replaceAll('%', ''))) AND Id NOT IN : lstIdAccounting AND HBX_BankAccount__c IN:lstStrForBankAccountId ]);
            // }
            if(keyword==null || keyword==''){
                mapForTransctionPerRent = new Map<Id,HBX_BankTransaction__c>([select id,Name ,HBX_Amount__c,CreatedDate  from HBX_BankTransaction__c where HBX_BankAccount__c =:transactionBankAccount]);
            }else{
            	mapForTransctionPerRent = new Map<Id,HBX_BankTransaction__c>([select id,Name ,HBX_Amount__c,CreatedDate  from HBX_BankTransaction__c where (Name LIKE :searchKeyword OR HBX_Amount__c =: Decimal.valueof(searchKeyword.replaceAll('%', ''))) AND HBX_BankAccount__c =:transactionBankAccount ]);
            }
        }else if(!String.isBlank(transactionBankAccount)){
            // mapForTransctionPerRent = new Map<Id,HBX_BankTransaction__c>([select id,Name ,HBX_Amount__c,CreatedDate from HBX_BankTransaction__c where Name LIKE :searchKeyword AND Id NOT IN : lstIdAccounting  AND HBX_BankAccount__c IN:lstStrForBankAccountId ]);
            mapForTransctionPerRent = new Map<Id,HBX_BankTransaction__c>([select id,Name ,HBX_Amount__c,CreatedDate from HBX_BankTransaction__c where Name LIKE :searchKeyword AND HBX_BankAccount__c =:transactionBankAccount ]);
        }
        if(mapForTransctionPerRent.size()>0){
            lstTransactions.addAll(mapForTransctionPerRent.values());
        }
        
        Map<id,Decimal> mapForTransactionIdAndTotalAmountPaid = new Map<id,Decimal>();
        for(AggregateResult accounting : [select HBX_BankTransaction__c,SUM (HBX_PaidAmount__c) allAmount from HBX_Accounting__c GROUP BY HBX_BankTransaction__c HAVING HBX_BankTransaction__c IN :mapForTransctionPerRent.keyset()]){
            if(accounting.get('allAmount')!=null && mapForTransctionPerRent.get((ID)accounting.get('HBX_BankTransaction__c')).HBX_Amount__c != null){
                mapForTransactionIdAndTotalAmountPaid.put((ID)accounting.get('HBX_BankTransaction__c'),mapForTransctionPerRent.get((ID)accounting.get('HBX_BankTransaction__c')).HBX_Amount__c  - (Decimal)accounting.get('allAmount'));
            }
            // else if(mapForTransctionPerRent.get((ID)accounting.get('HBX_BankTransaction__c')).HBX_Amount__c!=null){
            //     mapForTransactionIdAndTotalAmountPaid.put((ID)accounting.get('HBX_BankTransaction__c'),mapForTransctionPerRent.get((ID)accounting.get('HBX_BankTransaction__c')).HBX_Amount__c  - 0);
            // }
        }
        Integer count = 0;
        for(HBX_BankTransaction__c transact : lstTransactions){
            if(Integer.valueof(numberOfrecords) != 0 && count == Integer.valueof(numberOfrecords)){
                break;
            }
            if(!(mapForTransactionIdAndTotalAmountPaid.get(transact.Id)==null) && !(mapForTransactionIdAndTotalAmountPaid.get(transact.Id) <= 0)){
                count++;
                lstTransactionDetailsWrapper.add(new TransactionDetailsWrapper(transact,mapForTransactionIdAndTotalAmountPaid.get(transact.Id),mapForTransactionIdAndTotalAmountPaid.get(transact.Id)));
            }
            else if(transact.HBX_Amount__c != null){
                count++;
                lstTransactionDetailsWrapper.add(new TransactionDetailsWrapper(transact,transact.HBX_Amount__c,transact.HBX_Amount__c));
            }
            // else if(!(mapForTransactionIdAndTotalAmountPaid.get(transact.Id) == 0)){
            //     count++;
            //     lstTransactionDetailsWrapper.add(new TransactionDetailsWrapper(transact,transact.HBX_Amount__c,transact.HBX_Amount__c));
            // }
        }
        return lstTransactionDetailsWrapper;
    }
    
    
    @AuraEnabled
    public static List<HBX_Accounting__c> returnAccountingRecords(String rentId, Integer monthNumber){
        Date dt = system.today();
        List<HBX_Accounting__c> lstBankTransactionFromAccounting = new List<HBX_Accounting__c>();
        List<String> transactionsId = new List<String>();
        lstBankTransactionFromAccounting = [select HBX_Rent__c,HBX_PaidAmount__c,HBX_BankTransaction__c,HBX_BankTransaction__r.Name,HBX_BankTransaction__r.HBX_Amount__c from HBX_Accounting__c where HBX_Rent__c =:rentId  AND CALENDAR_MONTH(CreatedDate) =: dt.month() AND CALENDAR_YEAR(CreatedDate) =:dt.year()  limit 50000];  
        return lstBankTransactionFromAccounting;
    }
    
    //mapping rent and transactions in case of manual mapping.
    @AuraEnabled
    public static string mapRentAndTransaction(string mappingJSONForRentAndTransaction){
        return DMLHandler.mapRentAndTransaction(mappingJSONForRentAndTransaction);
    } 
}