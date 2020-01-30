@isTest
private class MaintenanceRequestHelperTest {
    @TestSetup
    static void makeData(){
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < 2; i++) {
            products.add(new Product2(
                Name = 'Product ' + i,
                Maintenance_Cycle__c = i + 1,
                Cost__c = 400,
                Current_Inventory__c = 500,
                IsActive = true,
                Replacement_Part__c = true));}
        insert products;

        List<Case> maintReqs = new List<Case>();
        for(Integer i = 0; i < 300; i++) {
            maintReqs.add(new Case(
                Subject = 'Request ' + i,
                Type = 'Repair',
                Status = 'New',
                Priority = 'Medium',
                Origin = 'Phone'));}
        insert maintReqs;

        List<Work_Part__c> wpList = new List<Work_Part__c>();
        for (Case c : maintReqs) {
            wpList.add(new Work_Part__c(Maintenance_Request__c = c.Id, Equipment__c = products.get(0).Id, Quantity__c = 10));
            wpList.add(new Work_Part__c(Maintenance_Request__c = c.Id, Equipment__c = products.get(1).Id, Quantity__c = 5));    
        }
        insert wpList;
    }

    @isTest static void testBulk() {
        Datetime testStart = System.now();
        List<Case> maintReqs = [SELECT Id, Status FROM Case WHERE Subject LIKE 'Request%'];
        for (Case c : maintReqs) {
            c.Status = 'Closed';
        }
        update maintReqs;

        AggregateResult ar = [SELECT COUNT(Id) caseCount, MAX(Date_Due__c) maxDueDate FROM Case WHERE Subject LIKE 'Scheduled Maintenance%' AND CreatedDate >= :testStart].get(0);
        
        System.assertEquals(maintReqs.size(), ar.get('caseCount'));
        System.assertEquals(Date.today().addDays(1), ar.get('maxDueDate'));
    }

    @isTest static void testNegative() {
        Datetime testStart = System.now();
        Case testCase = [SELECT Id, Status FROM Case WHERE Subject LIKE 'Request%' LIMIT 1];
        testCase.Status = 'Working';
        update testCase;
        AggregateResult ar = [SELECT COUNT(Id) caseCount FROM Case WHERE Subject LIKE 'Scheduled Maintenance%' AND CreatedDate >= :testStart].get(0);
        System.assertEquals(0, ar.get('caseCount'));
    }
}
