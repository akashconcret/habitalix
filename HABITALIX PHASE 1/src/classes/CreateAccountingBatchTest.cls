@isTest
private class CreateAccountingBatchTest {
    @isTest static void batchTestMethod() {
         List<Id> contractIds = new List<Id>();
        Integer month = System.today().month();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.HBX_IBAN__c = '1234567';
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
        system.debug([select id,HBX_GrossIncome__c from HBX_Contract__c where id =: objContract.id]);
        
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
        objRent.hbx_lastmanualmatchdate__c = system.now();
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
        objOfBankTransaction.HBX_Amount__c = 3737;
        objOfBankTransaction.HBX_InvoiceAmount__c  = 700;
        objOfBankTransaction.hbx_bookingdate__c = system.now();
        objOfBankTransaction.HBX_IBAN__c = '1234567';
        objOfBankTransaction.hbx_valuedate__c = system.now();
        insert objOfBankTransaction;
        
        HBX_PaymentMatchingCriteria__c paymentMatchingCriteria = new HBX_PaymentMatchingCriteria__c();
        paymentMatchingCriteria.Name = 'hbx_amount__c';
        paymentMatchingCriteria.HBX_Operator__c ='equals';
        paymentMatchingCriteria.HBX_RentField__c ='hbx_grossrentamount__c';
        insert paymentMatchingCriteria;
        
        HBX_PaymentMatchingCriteria__c paymentMatchingCriteria1 = new HBX_PaymentMatchingCriteria__c();
        paymentMatchingCriteria1.Name = 'hbx_bookingdate__c';
        paymentMatchingCriteria1.HBX_Operator__c ='not equals to';
        paymentMatchingCriteria1.HBX_DataType__c = 'datetime';
        paymentMatchingCriteria1.HBX_RentField__c ='hbx_lastmanualmatchdate__c';
        insert paymentMatchingCriteria1;
        
        
        HBX_PaymentMatchingCriteria__c paymentMatchingCriteria2 = new HBX_PaymentMatchingCriteria__c();
        paymentMatchingCriteria2.Name = 'hbx_valuedate__c';
        paymentMatchingCriteria2.HBX_Operator__c ='greater than';
        paymentMatchingCriteria2.HBX_DataType__c = 'datetime';
        paymentMatchingCriteria2.HBX_RentField__c ='hbx_lastautomaticmatchdate__c';
        //insert paymentMatchingCriteria2;
        
        Test.startTest();
        database.executeBatch(new CreateAccountingBatch(),1);
        Test.stopTest();
       	AutoMapTransactionWithRentController objAutoMap = new AutoMapTransactionWithRentController();
    }
    @isTest static void batchTestMethodForFilterLogicAvailable() {
         List<Id> contractIds = new List<Id>();
        Integer month = System.today().month();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.HBX_IBAN__c = '1234567';
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
        system.debug([select id,HBX_GrossIncome__c from HBX_Contract__c where id =: objContract.id]);
        
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
        objRent.hbx_lastmanualmatchdate__c = system.now();
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
        objOfBankTransaction.HBX_Amount__c = 3737;
        objOfBankTransaction.HBX_InvoiceAmount__c  = 700;
        objOfBankTransaction.hbx_bookingdate__c = system.now();
        objOfBankTransaction.HBX_IBAN__c = '1234567';
        objOfBankTransaction.hbx_valuedate__c = system.now();
        insert objOfBankTransaction;
        
        HBX_PaymentMatchingCriteria__c paymentMatchingCriteria = new HBX_PaymentMatchingCriteria__c();
        paymentMatchingCriteria.Name = 'hbx_amount__c';
        paymentMatchingCriteria.HBX_Operator__c ='equals';
        paymentMatchingCriteria.HBX_FilterLogic__c = '(1)';
        paymentMatchingCriteria.HBX_DataType__c = 'currency';
        paymentMatchingCriteria.HBX_RentField__c ='hbx_grossrentamount__c';
        insert paymentMatchingCriteria;
        
        HBX_PaymentMatchingCriteria__c paymentMatchingCriteria1 = new HBX_PaymentMatchingCriteria__c();
        paymentMatchingCriteria1.Name = 'hbx_bookingdate__c';
        paymentMatchingCriteria1.HBX_Operator__c ='not equals to';
        paymentMatchingCriteria1.HBX_DataType__c = 'datetime';
        paymentMatchingCriteria1.HBX_FilterLogic__c = '(1 AND 2)'; 
        paymentMatchingCriteria1.HBX_RentField__c ='hbx_lastmanualmatchdate__c';
        //insert paymentMatchingCriteria1;
        
        
        HBX_PaymentMatchingCriteria__c paymentMatchingCriteria2 = new HBX_PaymentMatchingCriteria__c();
        paymentMatchingCriteria2.Name = 'hbx_valuedate__c';
        paymentMatchingCriteria2.HBX_Operator__c ='greater than';
        paymentMatchingCriteria2.HBX_DataType__c = 'datetime';
        paymentMatchingCriteria2.HBX_RentField__c ='hbx_lastautomaticmatchdate__c';
        //insert paymentMatchingCriteria2;
        
        Test.startTest();
        database.executeBatch(new CreateAccountingBatch(),1);
        Test.stopTest();
       	AutoMapTransactionWithRentController objAutoMap = new AutoMapTransactionWithRentController();
    }
}