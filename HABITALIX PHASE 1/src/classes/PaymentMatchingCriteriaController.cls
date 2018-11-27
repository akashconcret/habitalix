public class PaymentMatchingCriteriaController {
    
    // @AuraEnabled
    // public static List<PaymentMatchingCriteriaControllerWrapper.TranscationsRecords> getTransactionFields() {
    //     List<PaymentMatchingCriteriaControllerWrapper.TranscationsRecords> listOfTransactionFields = new  List<PaymentMatchingCriteriaControllerWrapper.TranscationsRecords>();
        
    //     // SObjectType accountType = Schema.getGlobalDescribe().get('HBX_BankTransaction__c');
    //     // Map<String,Schema.SObjectField> mapOfTransactionFields = accountType.getDescribe().fields.getMap();
    //     // for(String fieldName:mapOfTransactionFields.keySet()) {
    //     //     Schema.SObjectField sfield = mapOfTransactionFields.get(fieldName);
    //     //     schema.describefieldresult fieldresult = sfield.getDescribe();
    //     //     if(fieldresult.isAccessible() && fieldresult.isCustom())
    //     //         listOfTransactionFields.add(new PaymentMatchingCriteriaControllerWrapper.TranscationsRecords(fieldName, mapOfTransactionFields.get(fieldName).getDescribe().getLabel()));
    //     // }
    //     return listOfTransactionFields;
    // }
    
    // @AuraEnabled
    // public static List<PaymentMatchingCriteriaControllerWrapper.RentsRecords> getRentsFields() {
    //     List<PaymentMatchingCriteriaControllerWrapper.RentsRecords> listOfRentFields = new  List<PaymentMatchingCriteriaControllerWrapper.RentsRecords>();
        
    //     // SObjectType accountType = Schema.getGlobalDescribe().get('HBX_Rent__c');
    //     // Map<String,Schema.SObjectField> mapOfTransactionFields = accountType.getDescribe().fields.getMap();
    //     // for(String fieldName:mapOfTransactionFields.keySet()) {
    //     //     Schema.SObjectField sfield = mapOfTransactionFields.get(fieldName);
    //     //     schema.describefieldresult fieldresult = sfield.getDescribe();
    //     //     if(fieldresult.isAccessible() && fieldresult.isCustom())
    //     //         listOfRentFields.add(new PaymentMatchingCriteriaControllerWrapper.RentsRecords(fieldName, mapOfTransactionFields.get(fieldName).getDescribe().getLabel()));
    //     // }
    //     return listOfRentFields;
    // }
    @AuraEnabled
    public static PaymentMatchingCriteriaControllerWrapper getRentTransactionFields() {
        List<fieldDetailWrapper> transactionFields = new List<fieldDetailWrapper>();
        List<fieldDetailWrapper> rentFields = new List<fieldDetailWrapper>();
        
        getTransactionField(transactionFields);
        getRentField(rentFields);
        
        
        return new PaymentMatchingCriteriaControllerWrapper(rentFields,transactionFields,getSavedFilters());
        // return null;
    }
    public static void getTransactionField(List<fieldDetailWrapper> transactionFields){
        SObjectType objTypeTransaction = Schema.getGlobalDescribe().get('HBX_BankTransaction__c');
        Map<String,Schema.SObjectField> mapOfTransactionFields = objTypeTransaction.getDescribe().fields.getMap();
        for(String fieldName:mapOfTransactionFields.keySet()) {
            Schema.SObjectField sfield = mapOfTransactionFields.get(fieldName);
            schema.describefieldresult fieldresult = sfield.getDescribe();
            if(fieldresult.isAccessible() && fieldresult.isCustom())
                transactionFields.add(new fieldDetailWrapper(fieldName, mapOfTransactionFields.get(fieldName).getDescribe().getLabel(),String.valueOf(mapOfTransactionFields.get(fieldName).getDescribe().getType())));
        }
    }
    
    public static void getRentField(List<fieldDetailWrapper> rentFields){
        SObjectType objTypeRent = Schema.getGlobalDescribe().get('HBX_Rent__c');
        Map<String,Schema.SObjectField> mapOfTransactionFields = objTypeRent.getDescribe().fields.getMap();
        for(String fieldName:mapOfTransactionFields.keySet()) {
            Schema.SObjectField sfield = mapOfTransactionFields.get(fieldName);
            schema.describefieldresult fieldresult = sfield.getDescribe();
            if(fieldresult.isAccessible() && fieldresult.isCustom())
                rentFields.add(new fieldDetailWrapper(fieldName, mapOfTransactionFields.get(fieldName).getDescribe().getLabel(),String.valueOf(mapOfTransactionFields.get(fieldName).getDescribe().getType())));
        }
        getSavedFilters();
    }
    
    public static String getSavedFilters(){
        List<HBX_PaymentMatchingCriteria__c> lstSavedFiltersCS = [select id,Name,HBX_Operator__c,HBX_RentField__c,HBX_FilterLogic__c from HBX_PaymentMatchingCriteria__c limit 1000];
        
        List<SavedFiltersWrapper> lstSavedFilters = new List<SavedFiltersWrapper>();
        for(HBX_PaymentMatchingCriteria__c savedFilters : lstSavedFiltersCS){
            lstSavedFilters.add(new SavedFiltersWrapper(savedFilters.Name,savedFilters.HBX_Operator__c,savedFilters.HBX_RentField__c,savedFilters.HBX_FilterLogic__c));
        }
        system.debug(' lstSavedFilters:: '+JSON.serialize(lstSavedFilters));
        if(lstSavedFiltersCS.size()==0){
            return 'No Filter found';
        }else{
            return JSON.serialize(lstSavedFilters);
        }
    }
    
    @AuraEnabled
    public static String saveFilters(String filters,string filterLogic) {
        system.debug(' :: filters : '+filters);
        Delete [select id from HBX_PaymentMatchingCriteria__c limit 1000];
        List<HBX_PaymentMatchingCriteria__c> lstPaymentMatchingCriteriaCS = new List<HBX_PaymentMatchingCriteria__c>();
        List<Object> lstFilter = (List<Object>) JSON.deserializeUntyped(filters);
        for(Object filter : lstFilter){
            Map<String,Object> mapForFilters = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(filter));
            system.debug(' :: '+mapForFilters);
            if(!mapForFilters.isEmpty()){
                lstPaymentMatchingCriteriaCS.add(new HBX_PaymentMatchingCriteria__c(Name = String.valueof(mapForFilters.get('transactionField')),HBX_Operator__c = String.valueof(mapForFilters.get('operator')),HBX_RentField__c =  String.valueof(mapForFilters.get('rentField')),HBX_FilterLogic__c = filterLogic,HBX_DataType__c = String.valueof(mapForFilters.get('dataType'))));
            }
        }
        if(lstPaymentMatchingCriteriaCS.size()>0){
            insert lstPaymentMatchingCriteriaCS;
        }
        
        system.debug(' :: '+lstPaymentMatchingCriteriaCS+' ::filterLogic '+filterLogic);
        return 'Payment Criteria Filters Saved SuccessFully.';
    }
}