@isTest 
private class SetupSchedularControllerTest {
    @isTest static void setupSchedularControllerForAccounting(){
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Right Now','');
        
        
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Four Hour','Today');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Hour','Today');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','23','Today');
        
        
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Four Hour','Daily');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Hour','Daily');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','23','Daily');
        
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Four Hour','5th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Hour','5th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','23','5th of every month');
        
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Four Hour','15th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Hour','15th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','23','15th of every month');
        
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Four Hour','25th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','Every Hour','25th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Accounting Batch','23','25th of every month');
    }
    @isTest static void setupSchedularControllerForBalanceList(){
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Right Now','');
        
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Four Hour','Today');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Hour','Today');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','23','Today');
        
        
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Four Hour','Daily');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Hour','Daily');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','23','Daily');
        
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Four Hour','5th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Hour','5th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','23','5th of every month');
        
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Four Hour','15th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Hour','15th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','23','15th of every month');
        
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Four Hour','25th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','Every Hour','25th of every month');
        SetupSchedularAutomaticallyController.scheduleBatch('Balance List Batch','23','25th of every month');
    }
    // @isTest static void saveFieldsForMatchingCriteria(){
    //     PaymentMatchingCriteriaController.saveFilters('[{"operator":"equals","rentField":"hbx_grossrentamount__c","transactionField":"hbx_amount__c"}]','1');
    //     PaymentMatchingCriteriaController.getSavedFilters();
    // }
}