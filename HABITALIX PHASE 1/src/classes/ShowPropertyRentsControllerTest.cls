@isTest 
private class ShowPropertyRentsControllerTest {
    //static List<RentDetailsWrapper> listOfRentDetailsWrapper = new List<RentDetailsWrapper>();
    @isTest static void showPropertyRentsControllerMethod(){
        List<String> lstIdAccounting = new List<String>();
        String mappingJSONForRentAndTransaction;
        String rentId = 'a0E1q0000009VtgEAE';
        
        Account acc = new Account();
        acc.Name= 'Test Account';
        insert acc;
        
        HBX_Portfolio__c objPortfolio = new HBX_Portfolio__c();
        objPortfolio.Name = 'Test Portfolio';
        insert objPortfolio;
        
        HBX_BankAccount__c  ba = new HBX_BankAccount__c ();
        ba.Name = 'test';
        ba.HBX_IBAN__c  = '12345';
        insert ba;
        
        HBX_Building__c objBuilding = new HBX_Building__c();
        objBuilding.Name = 'Test Building';
        objBuilding.HBX_Portfolio__c = objPortfolio.Id;
        objBuilding.HBX_ManagementStartDate__c = System.today();
        objBuilding.HBX_NrFloors__c = 2;
        objBuilding.HBX_BankAccount__c = ba.Id;
        objBuilding.HBX_BuildingAreaGroundPlanSQM__c = 2;
        insert objBuilding;
        
        HBX_PropertyOwnership__c objOfProp = new HBX_PropertyOwnership__c(); 
        objOfProp.Account__c = acc.Id;
        objOfProp.Building__c = objBuilding.Id;
        objOfProp.HBX_Share__c = 100;
        insert objOfProp;
        
        HBX_Contract__c objContract = new HBX_Contract__c();
        objContract.HBX_Building__c =  objBuilding.Id;
        objContract.HBX_UsageType__c = 'Commercial';
        objContract.HBX_Status__c = 'Active';
        objContract.HBX_StartDate__c = System.today();
        insert objContract;
        
        HBX_Payer__c objOfPayer = new HBX_Payer__c();
        objOfPayer.Name = 'Test Payer';
        objOfPayer.HBX_Account__c = acc.Id;
        objOfPayer.HBX_Contract__c = objContract.Id;
        objOfPayer.HBX_MainPayer__c = true;
        insert objOfPayer;
        
        HBX_Rent__c objRent = new HBX_Rent__c();
        objRent.HBX_Contract__c = objContract.id;
        objRent.HBX_RentDate__c = System.today();
        objRent.HBX_PayedAmount__c = 1200;
        insert objRent;
        
        HBX_TransactionType__c objOfTransactionType = new HBX_TransactionType__c();
        objOfTransactionType.Name = 'Test Transaction Type';
        insert objOfTransactionType;
        
        HBX_BankTransaction__c objOfBankTransaction = new HBX_BankTransaction__c();
        objOfBankTransaction.Name = 'Test Bank Transcation';
        objOfBankTransaction.HBX_InvoiceDate__c = System.today();
        objOfBankTransaction.HBX_TransactionType__c = objOfTransactionType.Id;
        objOfBankTransaction.HBX_BankAccount__c = ba.Id;
        objOfBankTransaction.HBX_Amount__c = 200;
        insert objOfBankTransaction;
        
        
        HBX_Accounting__c objAccounting = new HBX_Accounting__c();
        objAccounting.Name = 'Test Accounting';
        objAccounting.HBX_Rent__c = objRent.Id;
        objAccounting.HBX_BankTransaction__c = objOfBankTransaction.Id;
        insert objAccounting;
        
        mappingJSONForRentAndTransaction='{"'+objRent.Id+'"'+':[{"Name":"Test Bank Transaction 2","Id":"a041q000000SWh2AAG","Amount":1300}]}';
        
        
        Test.startTest();
        List<RentDetailsWrapper> listOfWrapper = ShowPropertyRentsController.returnRents(08,'Partial matched Rents',5);
        System.assertEquals(0, listOfWrapper.size());
        ShowPropertyRentsController.returnAccountingRecords(rentId, 08);
        ShowPropertyRentsController.returnRents(08,'Not matched Rents',5);
        ShowPropertyRentsController.returnRents(08,'Total matched Rents',5);
        ShowPropertyRentsController.returnRents(08,'All',5);
        ShowPropertyRentsController.returnBankTransactions(' ', ba.Id, 2, 2);
        ShowPropertyRentsController.mapRentAndTransaction(mappingJSONForRentAndTransaction);
        Test.stopTest();
      
        
    }
}