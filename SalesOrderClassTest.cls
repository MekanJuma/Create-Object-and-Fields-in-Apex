@isTest
private class SalesOrderClassTest {
	@isTest static void testSalesOrderRecordCreation() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'John', LastName='Doe', AccountId=testAccount.Id);
        insert testContact;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        Order testOrder = new Order(
            Name = 'Test Order',
            Status = 'Draft',
            EffectiveDate = Date.today(),
            AccountId = testAccount.Id,
            OpportunityId = testOpportunity.Id,
            BillToContactId=testContact.Id
        );
        insert testOrder;

        Test.startTest();
        SalesOrderClass soInstance = new SalesOrderClass();
        soInstance.setupSalesOrderRecords();
        Test.stopTest();

        List<sObject> salesOrders = Database.query('SELECT Sales_Order_Number__c, Date__c, Account_Name__c, Contact_Name__c, Opportunity_Name__c, Name, Sales_Order_Amount__c FROM Sales_Order__c');
        System.assertEquals(1, salesOrders.size(), 'Expected 1 Sales Order record');
        sObject createdSalesOrder = salesOrders[0];

        System.assertEquals(testOrder.Name, (String)createdSalesOrder.get('Name'), 'Order name mismatch');
        System.assertEquals(testOrder.EffectiveDate, (Date)createdSalesOrder.get('Date__c'), 'Order date mismatch');
        System.assertEquals(testOpportunity.Name, (String)createdSalesOrder.get('Opportunity_Name__c'), 'Opportunity name mismatch');
        System.assertEquals(testAccount.Name, (String)createdSalesOrder.get('Account_Name__c'), 'Account name mismatch');
        System.assertEquals(testContact.FirstName + ' ' + testContact.LastName, (String)createdSalesOrder.get('Contact_Name__c'), 'Contact name mismatch');
    }
}