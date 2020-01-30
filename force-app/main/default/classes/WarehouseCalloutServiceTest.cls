@IsTest
private class WarehouseCalloutServiceTest {
    @isTest static void testSync() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();

        List<Product2> productList = [SELECT Warehouse_SKU__c FROM Product2];
        System.assertEquals(2, productList.size());
    }
}