public class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public static List<Product2> getProductList(List<Object> lst) {
        List<Product2> productList = new List<Product2>();
        for (Object o : lst) {
            Map<String, Object> row = (Map<String, Object>) o;
            productList.add(new Product2(
                ExternalId = (String) row.get('_id'),
                Replacement_Part__c = true,
                Current_Inventory__c = (Decimal) row.get('quantity'),
                Name = (String) row.get('name'),
                Maintenance_Cycle__c = (Decimal) row.get('maintenanceperiod'),
                Lifespan_Months__c = (Decimal) row.get('lifespan'),
                Cost__c = (Decimal) row.get('cost'),
                Warehouse_SKU__c = (String) row.get('sku')
            ));
        }
        return productList;
    } 

    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<Object> lst = (List<Object>) JSON.deserializeUntyped(response.getBody());
            List<Product2> productList = getProductList(lst);
            upsert productList;
        }
    }
}