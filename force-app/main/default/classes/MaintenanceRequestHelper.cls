public class MaintenanceRequestHelper {
    
    /*
        Filters MaintenanceRequest trigger parameters (after update) and returns list of cases where:
            - Status was updated to closed
            - Type is either Repair or Routine Maintenance
    */
    public static List<Case> returnClosedCases(Map<Id, Case> oldCaseMap, List<Case> newCaseList) {
        List<Case> casesWhichMeetConditions = new List<Case>();

        for (Case newCase : newCaseList) {
            Case oldCase = oldCaseMap.get(newCase.Id);
            
            if (newCase.Status == 'Closed' && newCase.Status != oldCase.Status && 
                (newCase.Type == 'Repair' || newCase.Type == 'Routine Maintenance')) 
            {
                casesWhichMeetConditions.add(newCase);
            }
        }
        return casesWhichMeetConditions;
    }

    /*
        Returns map of Case Ids and lowest Maintenance_Cycle__c values from Work_Part__c records, 
        related to each record on list of closed cases passed in as parameter
    */
    public static Map<Id, Decimal> getShortestMaintenanceCycleMap(List<Case> closedCases) {
        Map<Id, Decimal> cycleMap = new Map<Id, Decimal>();

        List<AggregateResult> queryRes = [
            SELECT Maintenance_Request__c, min(Equipment__r.Maintenance_Cycle__c) shortestCycle
                FROM Work_Part__c 
                WHERE Maintenance_Request__c IN :closedCases
                GROUP BY Maintenance_Request__c];

        for (AggregateResult ar : queryRes) {
            cycleMap.put((Id) ar.get('Maintenance_Request__c'), (Decimal) ar.get('shortestCycle'));
        }
        return cycleMap;
    }

    /*
        Main method which creates new Routine Maintenance Type Cases and populates their field values according to requirements, 
        whenever certain cases are closed (Type is Repair or Routine Maintenance)
    */
    public static void updateWorkOrders(Map<Id, Case> oldCaseMap, List<Case> newCases) {
        List<Case> closedCases = returnClosedCases(oldCaseMap, newCases);
        Map<Id, Decimal> cycleMap = getShortestMaintenanceCycleMap(closedCases);
        List<Case> casesToCreate = new List<Case>();

        for (Case closed : closedCases) {
            Case maintCase = new Case();

            maintCase.Subject = 'Scheduled Maintenance (' + closed.CaseNumber + ': ' + closed.Subject + ')';
            maintCase.Origin = 'Automation';
            maintCase.Type = 'Routine Maintenance';
            maintCase.Vehicle__c = closed.Vehicle__c;
            maintCase.Equipment__c = closed.Equipment__c;
            maintCase.ContactId = closed.ContactId;
            maintCase.Date_Reported__c = Date.today();
            if (cycleMap.containsKey(closed.Id)) {
                maintCase.Date_Due__c = Date.today() + (Integer) cycleMap.get(closed.Id);
            }

            casesToCreate.add(maintCase);
        }
        insert casesToCreate;
    }      
}