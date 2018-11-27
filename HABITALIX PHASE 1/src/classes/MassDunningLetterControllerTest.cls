@isTest
private class MassDunningLetterControllerTest {
    @isTest static void MassDunningLetterControllerTestMethod() {
        List<Id> contractIds = new List<Id>();
        Integer month = System.today().month();
        
        Account acc = new Account();
        acc.Name= 'Test Account123';
        insert acc;
        
        HBX_Portfolio__c objPortfolio = new HBX_Portfolio__c();
        objPortfolio.Name = 'Test Portfolio';
        insert objPortfolio;
        
        HBX_Building__c objBuilding = new HBX_Building__c();
        objBuilding.Name = 'Test Building';
        objBuilding.HBX_Portfolio__c = objPortfolio.Id;
        objBuilding.HBX_ManagementStartDate__c = System.today();
        objBuilding.HBX_NrFloors__c = 2;
        objBuilding.HBX_BuildingAreaGroundPlanSQM__c = 2;
        objBuilding.HBX_MonthlyNetRent__c = 1000;
        objBuilding.HBX_VATAmount__c = 1;
        //objBuilding.HBX_WarmRent__c = 3500;
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
        objContract.HBX_MonthlyNetRent__c = 3500;
        objContract.HBX_VATPercent__c = 1;
        objContract.HBX_PetFee__c = 200;
        objContract.HBX_DepositAmount__c = 1000;
        //objContract.HBX_NetIncome__c = 1000;
        //objContract.HBX_GrossIncome__c = 1200;
        insert objContract;
        contractIds.add(objContract.Id);
        
        HBX_Payer__c objOfPayer = new HBX_Payer__c();
        objOfPayer.Name = 'Test Payer123';
        objOfPayer.HBX_Account__c = acc.Id;
        objOfPayer.HBX_Contract__c = objContract.Id;
        objOfPayer.HBX_MainPayer__c = true;
        insert objOfPayer;
        
        HBX_Rent__c objRent = new HBX_Rent__c();
        objRent.HBX_Contract__c = objContract.id;
        objRent.HBX_RentDate__c = System.today();
        objRent.HBX_PayedAmount__c = 1200;
        objRent.HBX_Credit__c = 500;
        objRent.HBX_IsActive__c = true;
        insert objRent;
        
        Id rentId = objRent.Id;
        
        HBX_TransactionType__c objOfTransactionType = new HBX_TransactionType__c();
        objOfTransactionType.Name = 'Test Transaction Type';
        insert objOfTransactionType;
        
        HBX_BankTransaction__c objOfBankTransaction = new HBX_BankTransaction__c();
        objOfBankTransaction.Name = 'Test Bank Transcation';
        objOfBankTransaction.HBX_InvoiceDate__c = System.today();
        objOfBankTransaction.HBX_TransactionType__c = objOfTransactionType.Id;
        objOfBankTransaction.HBX_Amount__c = 300;
        objOfBankTransaction.HBX_InvoiceAmount__c  = 700;
        insert objOfBankTransaction;
        
        String mappingJSONForRentAndTransaction = ' {"'+objRent.Id+'"'+':[{"Name":"Test Bank Transaction 2","Id":"'+objOfBankTransaction.id+'","Amount":1300}]}';
        String ss = ShowPropertyRentsController.mapRentAndTransaction(mappingJSONForRentAndTransaction);
        Test.startTest();
        database.executeBatch(new BalanceSheetBatch(),1);
        Test.stopTest();
        MassDunningLetterController.getDunningRecords();
        
        List<HBX_BalanceList__c> lst = new List<HBX_BalanceList__c>([SELECT id, HBX_CreditTotal__c,HBX_ContractNumber__c from HBX_BalanceList__c]);
        
        String results = MassDunningLetterController.createTaskForDunningProcess('{"'+lst[0].Id+'":"Reminder 2:'+lst[0].HBX_ContractNumber__c+'"}');
        System.assertEquals('Success',results);
        
        System.assertEquals(1, lst.size());
        // List<HBX_Accounting__c> lstofaac = new   List<HBX_Accounting__c>([SELECT Id from HBX_Accounting__c where HBX_BalanceList__c =: lst[0].id]);
        // System.assertEquals(1 ,lstofaac.size());
       
    }
    @isTest static void BalanceListForNoAccounting() {
        List<Id> contractIds = new List<Id>();
        Integer month = System.today().month();
        
        Account acc = new Account();
        acc.Name= 'Test Account123';
        insert acc;
        
        HBX_Portfolio__c objPortfolio = new HBX_Portfolio__c();
        objPortfolio.Name = 'Test Portfolio';
        insert objPortfolio;
        
        HBX_Building__c objBuilding = new HBX_Building__c();
        objBuilding.Name = 'Test Building';
        objBuilding.HBX_Portfolio__c = objPortfolio.Id;
        objBuilding.HBX_ManagementStartDate__c = System.today();
        objBuilding.HBX_NrFloors__c = 2;
        objBuilding.HBX_BuildingAreaGroundPlanSQM__c = 2;
        objBuilding.HBX_MonthlyNetRent__c = 1000;
        objBuilding.HBX_VATAmount__c = 1;
        //objBuilding.HBX_WarmRent__c = 3500;
        insert objBuilding;
        
        HBX_PropertyOwnership__c objOfProp = new HBX_PropertyOwnership__c(); 
        objOfProp.Account__c = acc.Id;
        objOfProp.Building__c = objBuilding.Id;
        objOfProp.HBX_Share__c = 100;
        insert objOfProp;
        
        Contact con = new Contact();
        con.lastName = 'test';
        con.HBX_EmailOptIn__c = true;
        con.Email = 'katja.feldtmann@gmail.com';
        insert con;
        
        
        HBX_Contract__c objContract = new HBX_Contract__c();
        objContract.HBX_Building__c =  objBuilding.Id;
        objContract.HBX_UsageType__c = 'Commercial';
        objContract.HBX_Status__c = 'Active';
        objContract.HBX_StartDate__c = System.today();
        objContract.HBX_MonthlyNetRent__c = 3500;
        objContract.HBX_VATPercent__c = 1;
        objContract.HBX_PetFee__c = 200;
        objContract.HBX_DepositAmount__c = 1000;
        objContract.HBX_ContactPerson__c = con.Id;
        //objContract.HBX_NetIncome__c = 1000;
        //objContract.HBX_GrossIncome__c = 1200;
        insert objContract;
        contractIds.add(objContract.Id);
        
        HBX_Payer__c objOfPayer = new HBX_Payer__c();
        objOfPayer.Name = 'Test Payer123';
        objOfPayer.HBX_Account__c = acc.Id;
        objOfPayer.HBX_Contract__c = objContract.Id;
        objOfPayer.HBX_MainPayer__c = true;
        insert objOfPayer;
        
        HBX_Rent__c objRent = new HBX_Rent__c();
        objRent.HBX_Contract__c = objContract.id;
        objRent.HBX_RentDate__c = System.today();
        objRent.HBX_PayedAmount__c = 1200;
        objRent.HBX_Credit__c = 500;
        objRent.HBX_IsActive__c = true;
        insert objRent;
        
        Test.startTest();
        database.executeBatch(new BalanceSheetBatch(),1);
        Test.stopTest();
        
        List<HBX_BalanceList__c> lst = new List<HBX_BalanceList__c>([SELECT id, HBX_CreditTotal__c,HBX_ContractNumber__c from HBX_BalanceList__c]);
        
        String results = MassDunningLetterController.createTaskForDunningProcess('{"'+lst[0].Id+'":"Reminder 2:'+lst[0].HBX_ContractNumber__c+'"}');
        System.assertEquals('Success',results);
    }
    
}