# <img src="https://cdn-icons-png.flaticon.com/512/873/873143.png" width=30 /> Create Custom Object and Fields in Apex

I utilized the Metadata API to create a custom object and fields.
You need to deploy the [MedatadataService.cls](https://github.com/certinia/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataService.cls) and [MetadataServiceTest.cls](https://github.com/certinia/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataServiceTest.cls) classes to your Salesforce org.

# Assignment:

Write an Apex class that creates a custom object called "Sales Order” and populates it with data from the Opportunity object.

# Fields

-   Sales Order Number (Text, 10 characters)
-   Date (Date)
-   Account Name (Text, 50 characters)
-   Contact Name (Text, 50 characters)
-   Opportunity Name (Text, 100 characters)
-   Sales Order Amount (Currency)

The class should have a method that creates a sales order record for each Opportunity record

**Criteria:**

-   The Opportunity Stage is "Closed Won"
-   The Opportunity does not already have a sales order
