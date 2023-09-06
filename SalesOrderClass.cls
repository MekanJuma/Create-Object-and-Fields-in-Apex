public class SalesOrderClass {
    
    public static MetadataService.MetadataPort createService() { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    
    public void main() {
        MetadataService.MetadataPort service = createService();
        
        List<MetadataService.SaveResult> objResults = createObject(service);
        if(objResults[0].success) {
            List<MetadataService.SaveResult> fieldResults = createFields(service);
        } else {
            System.debug('Error creating custom object: ' + objResults[0].errors[0].message);
        }
    }
    
    public List<MetadataService.SaveResult> createObject(MetadataService.MetadataPort service) {
        // Define the Custom Object
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'Sales_Order__c';
        customObject.label = 'Sales Order';
        customObject.pluralLabel = 'Sales Orders';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Sales Order Name';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        
        
        // Insert the object
        List<MetadataService.SaveResult> objResults = service.createMetadata(new MetadataService.Metadata[] { customObject });
        return objResults;
    }
    
    public List<MetadataService.SaveResult> createFields(MetadataService.MetadataPort service) {

        // Define fields
        List<MetadataService.Metadata> fields = new List<MetadataService.Metadata>();
        
        // Sales Order Number
        MetadataService.CustomField salesOrderNumber = new MetadataService.CustomField();
        salesOrderNumber.fullName = 'Sales_Order__c.Sales_Order_Number__c';
        salesOrderNumber.label = 'Sales Order Number';
        salesOrderNumber.type_x = 'Text';
        salesOrderNumber.length = 10;        
        fields.add(salesOrderNumber);
        
        // Date
        MetadataService.CustomField dateField = new MetadataService.CustomField();
        dateField.fullName = 'Sales_Order__c.Date__c';
        dateField.label = 'Date';
        dateField.type_x = 'Date';
        fields.add(dateField);
        
        // Account Name
        MetadataService.CustomField accountName = new MetadataService.CustomField();
        accountName.fullName = 'Sales_Order__c.Account_Name__c';
        accountName.label = 'Account Name';
        accountName.type_x = 'Text';
        accountName.length = 50;
        fields.add(accountName);
        
        // Contact Name
        MetadataService.CustomField contactName = new MetadataService.CustomField();
        contactName.fullName = 'Sales_Order__c.Contact_Name__c';
        contactName.label = 'Contact Name';
        contactName.type_x = 'Text';
        contactName.length = 50;
        fields.add(contactName);
        
        // Opportunity Name
        MetadataService.CustomField opportunityName = new MetadataService.CustomField();
        opportunityName.fullName = 'Sales_Order__c.Opportunity_Name__c';
        opportunityName.label = 'Opportunity Name';
        opportunityName.type_x = 'Text';
        opportunityName.length = 100;
        fields.add(opportunityName);
        
        // Sales Order Amount
        MetadataService.CustomField salesOrderAmount = new MetadataService.CustomField();
        salesOrderAmount.fullName = 'Sales_Order__c.Sales_Order_Amount__c';
        salesOrderAmount.label = 'Sales Order Amount';
        salesOrderAmount.type_x = 'Currency';
        salesOrderAmount.precision = 18;
        salesOrderAmount.scale = 2;
        fields.add(salesOrderAmount);
        
        // Create the fields
        List<MetadataService.SaveResult> fieldResults = service.createMetadata(fields);
        
        return fieldResults;
    }
    
    public void setupSalesOrderRecords() {
        SalesOrderQueueable job = new SalesOrderQueueable();
        System.enqueueJob(job);
    }

    public class SalesOrderQueueable implements Queueable {
        public void execute(QueueableContext context) {
            String orderObjectName = 'Order';
            String salesOrderObjectName = 'Sales_Order__c';
            
            // Validate if objects exist
            if(Schema.getGlobalDescribe().containsKey(orderObjectName) &&
               Schema.getGlobalDescribe().containsKey(salesOrderObjectName)) {                
                List<sObject> orders = Database.query('SELECT Id, Name, OrderNumber, EffectiveDate, TotalAmount, Account.Name, Opportunity.Name, BillToContact.Name FROM ' + orderObjectName + ' WHERE Opportunity.StageName = \'Closed Won\'');
                
                List<sObject> salesOrdersToInsert = new List<sObject>();
                
                for(sObject o : orders) {
                    sObject so = Schema.getGlobalDescribe().get(salesOrderObjectName).newSObject();
                    so.put('Sales_Order_Number__c', o.get('OrderNumber'));
                    so.put('Date__c', o.get('EffectiveDate'));
                	
                    sObject relatedAccount = (sObject)o.getSObject('Account');
                    if(relatedAccount != null) {
                        so.put('Account_Name__c', relatedAccount.get('Name'));
                    } else {
                        continue;
                    }
                	
                    sObject relatedContact = (sObject)o.getSObject('BillToContact');
                    if(relatedContact != null) {
                        so.put('Contact_Name__c', relatedContact.get('Name'));
                    }
                    
                    sObject relatedOpportunity = (sObject)o.getSObject('Opportunity');
                    if(relatedOpportunity != null) {
                        so.put('Opportunity_Name__c', relatedOpportunity.get('Name'));
                    }
                    so.put('Name', o.get('Name'));
                    so.put('Sales_Order_Amount__c', o.get('TotalAmount'));
                    salesOrdersToInsert.add(so);
                }

                if(!salesOrdersToInsert.isEmpty()) {
                    insert salesOrdersToInsert;
                }
            }
        }
    }
}