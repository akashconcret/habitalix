public class AssignTaskForDunningProcessController {
    
    public static String AssignTaskForDunningProcess(String dunningDetail) {
        List<Task> listOfTask = new List<Task>();

        Map<String, Object> mapForRentIdAndTransactions = (Map<String, Object>)JSON.deserializeUntyped(dunningDetail);
        Map<String,String> mapContactIdAndDunningStage = new Map<String,String>();
        for(String obj : mapForRentIdAndTransactions.keyset()){
            List<String> lstOfDunningStageAndContractId =  String.valueof(mapForRentIdAndTransactions.get(obj)).split(':');
            mapContactIdAndDunningStage.put(lstOfDunningStageAndContractId[1],lstOfDunningStageAndContractId[0]);
        }
        
        system.debug('contractIds : '+mapContactIdAndDunningStage.keySet());
        // List<AssignTaskForDunningProcessControllerWrapper> objOfWrapper = new List<AssignTaskForDunningProcessControllerWrapper>();
        Map<Id, List<HBX_Payer__c>> mapOfPayerwithContractId = new Map<Id, List<HBX_Payer__c>>();
        for(HBX_Payer__c payr :[SELECT Id, Name, HBX_Account__c,HBX_MainPayer__c, HBX_Account__r.Name, HBX_Account__r.OwnerId, HBX_Account__r.Owner.Name, HBX_Contract__c, HBX_Contract__r.Name,HBX_Contract__r.HBX_ContactPerson__c,HBX_Contract__r.HBX_ContactPerson__r.Email,HBX_Contract__r.HBX_ContactPerson__r.HBX_EmailOptIn__c from HBX_Payer__c WHERE HBX_Contract__c IN: mapContactIdAndDunningStage.keyset() LIMIT 50000] ) {
            if(mapOfPayerwithContractId.containsKey(payr.HBX_Contract__c)){
                mapOfPayerwithContractId.get(payr.HBX_Contract__c).add(payr);
            }else{
                mapOfPayerwithContractId.put(payr.HBX_Contract__c, new List<HBX_Payer__c> { payr });
            }
        }
        System.debug(mapOfPayerwithContractId);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
        List<EmailTemplate> lstEmailTemplate = [select id,Name,developerName from EmailTemplate where developerName IN ('DUNNING_FriendlyReminder','DUNNING_Reminder1','DUNNING_Reminder2')];
        Map<String,Id> mapForTemplate =  new Map<String,Id>();
        for(EmailTemplate temp:lstEmailTemplate){
            mapForTemplate.put(temp.developerName,temp.id);
        }
        for(Id idOfContract : mapOfPayerwithContractId.keySet()) {
            for(HBX_Payer__c payr : mapOfPayerwithContractId.get(idOfContract)){
                system.debug('opt IN  :: '+payr.HBX_Contract__r.HBX_ContactPerson__r.HBX_EmailOptIn__c);
                if(payr.HBX_MainPayer__c && !(payr.HBX_Contract__r.HBX_ContactPerson__r.HBX_EmailOptIn__c)){
                    Task objOfTask = new Task();
                    objOfTask.OwnerId = payr.HBX_Account__r.OwnerId;
                    objOfTask.WhatId = payr.HBX_Account__c;
                    objOfTask.Status = 'To be sent';
                    objOfTask.Subject = mapContactIdAndDunningStage.get(idOfContract);
                    listOfTask.add(objOfTask);
                    break;
                }else if(payr.HBX_MainPayer__c && payr.HBX_Contract__r.HBX_ContactPerson__r.HBX_EmailOptIn__c){
                    sendEmailToTenant(allmsg,mapContactIdAndDunningStage.get(idOfContract),mapForTemplate,payr.HBX_Contract__r.HBX_ContactPerson__r.Email,payr.HBX_Contract__r.HBX_ContactPerson__c);
                }
            }
        }
        if(allmsg.size()>0){
            List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(allmsg);
            System.debug('-------------------------------------- Email sent status : ' + emailResultList[0].isSuccess());
            // Messaging.sendEmail(allmsg,false);
        }
        If(listOfTask.size() > 0) {
            try{
                insert listOfTask;
            }catch(Exception ee){
                system.debug('error : '+ee.getMessage());
                //return ee.getMessage();
            }
        }
        if(listOfTask.size() > 0 || allmsg.size()>0){
            try{
                return updateBalanceListStatus(mapForRentIdAndTransactions);
            }catch(Exception ee){
                system.debug('error : '+ee.getMessage());
                return 'error';
            }
        }else{
            return 'No record For Dunning found';
        }
    }
    public static String updateBalanceListStatus(Map<String, Object> mapForRentIdAndTransactions) {
        List<HBX_BalanceList__c> lstBalanceList = new List<HBX_BalanceList__c>();
        
        Map<String,String> mapForDunningStages = new Map<String,String>{
            'Friendly Reminder' => 'Reminder 1',
            'Reminder 1' => 'Reminder 2',
            'Reminder 2' => 'Default',
            'Default' =>  'Default'
        };
        for(String balListId : mapForRentIdAndTransactions.keySet()){
            string nextDunningStage = mapForDunningStages.get(String.valueof(mapForRentIdAndTransactions.get(balListId)).split(':')[0]);
            if(String.valueof(mapForRentIdAndTransactions.get(balListId)).split(':')[0] == 'Friendly Reminder'){
                lstBalanceList.add(new HBX_BalanceList__c(Id=balListId,HBX_NextDunningStage__c = nextDunningStage,HBX_LastDunningDate__c = system.Today(),HBX_PaymentTarget__c = system.Today().addDays(5)));
            }else if(String.valueof(mapForRentIdAndTransactions.get(balListId)).split(':')[0] == 'Reminder 1'){
                lstBalanceList.add(new HBX_BalanceList__c(Id=balListId,HBX_NextDunningStage__c = nextDunningStage,HBX_LastDunningDate__c = system.Today(),HBX_PaymentTarget__c = system.Today().addDays(8)));
            }else if(String.valueof(mapForRentIdAndTransactions.get(balListId)).split(':')[0] == 'Reminder 2'){
                lstBalanceList.add(new HBX_BalanceList__c(Id=balListId,HBX_NextDunningStage__c = nextDunningStage,HBX_LastDunningDate__c = system.Today(),HBX_PaymentTarget__c = system.Today().addDays(8)));
            }
        }
        if(lstBalanceList.size()>0){
            update lstBalanceList;
        }
        return 'Success';
    }
    
    public static void sendEmailToTenant(List<Messaging.SingleEmailMessage> allmsg ,String mailSubject,Map<String,Id> mapForTemplate,String contactEmail,Id contactId) {
        system.debug('mailSubject :: '+mailSubject+' contactEmail : '+contactEmail);
        system.debug('mapForTemplate :: '+mapForTemplate);
        // system.debug('mailSubject :: '+mailSubject);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(mailSubject == 'Friendly Reminder'){
            mail.setTemplateID(mapForTemplate.get('DUNNING_FriendlyReminder')); 
        }else if(mailSubject == 'Reminder 1'){
            mail.setTemplateID(mapForTemplate.get('DUNNING_Reminder1')); 
        }else if(mailSubject == 'Reminder 2'){
            mail.setTemplateID(mapForTemplate.get('DUNNING_Reminder2')); 
        }
        mail.setToAddresses(new List<String>{contactEmail});
        mail.setTargetObjectId(contactId);
        allmsg.add(mail);
    }
}