@isTest 
private class PaymentMatchingCriteriaControllerTest {
    @isTest static void availFieldsForMatchingCriteria(){
        PaymentMatchingCriteriaController.getRentTransactionFields();
    }
    @isTest static void saveFieldsForMatchingCriteria(){
        PaymentMatchingCriteriaController.saveFilters('[{"operator":"equals","rentField":"hbx_grossrentamount__c","transactionField":"hbx_amount__c"}]','1');
        PaymentMatchingCriteriaController.getSavedFilters();
    }
}