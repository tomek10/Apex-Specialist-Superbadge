@isTest
private class WarehouseSyncScheduleTest {
    @isTest static void WarehouseSyncScheduleTest() {
        String CRON_EXP = '0 0 1 * * ?';  
        Test.startTest();    
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            String job = System.schedule('Warehouse Sync Schedule Test', CRON_EXP, new WarehouseSyncSchedule());
            CronTrigger cronTrigger = [SELECT CronExpression FROM CronTrigger WHERE Id = :job];  
        Test.stopTest();  
        System.assertEquals(CRON_EXP, cronTrigger.CronExpression);  
    }
}
