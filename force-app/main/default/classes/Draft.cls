public with sharing class Draft {
  
//Person trigger
when AFTER_UPDATE {
    CTPersonController.afterUpdateTrigger (trigger.new, trigger.oldMap);
    }

//CTPersonController class
public static void afterUpdateTrigger (Set<Person__c> triggeredPerson, Map<Person__c, Id> oldTriggeredPerson) {
    
    Set<Person__c> healthChangedP = new Set <Id>();
    Set<Id> redStatusP = new Set <Id>();
    Set<Id> orangeYellowStatusP = new Set <Id>();

for (Person__c p : triggeredPerson) {
    if (p.Health_Status__c != oldTriggeredPerson.get(p.Id).Health_Status__c) {
        healthChangedP.add (p);
    }
}

for (Person__c cp : healthChangedP) {
    if (cp.Health_Status__c == 'Red' && oldTriggeredPerson.get(cp.Id).Health_Status__c != 'Red') {
        redStatusP.add (cp);
    } else {
        orangeYellowStatusP.add (cp);
    }
}

//Set of cohabitants and primary (other) records of redStatusP
Set<Id> toOrange = Set<Id>();
//Set of neighbours and secondary (other) records of orangeYellowStatusP
Set<Id> toYellow = Set<Id>();
//Bulk of both for DML
List <Person__c> recordsToUpdate = List <Person__c> (); 

toOrange.addAll (PersonTriggerExtra.getCohabitants(redStatusP));
Set <Id> primaryTemp = PersonTriggerExtra.getPrimary(redStatusP);
toOrange.addAll (primaryTemp);

toYellow.addAll (PersonTriggerExtra.getNeighbours(redStatusP));
toYellow.addAll (PersonTriggerExtra.getSecondary(primaryTemp));

}

//PersonTriggerExtra class

public static Set <Id> getCohabitants (Set<Id> newRed){

    Set<Id> cohabitants = new Set<Id>();
    List<String> healthStats = new List<String>{'Yellow','Green'};
    List <People_Tracing__c> matchedTraces = [SELECT Id, Person_1__c, Person_2__c, Contact_Type__c FROM People_Tracing__c 
                                              WHERE Person_1__c.id IN :newRed OR Person_2__c.id IN :newRed AND Contact_Type__c == 'Cohabitant'];
    for (People_Tracing__c pt :matchedTraces) {
        if (newRed.contains(pt.Person_1__c.id) && healthStats.contains(pt.Person_2__c.Health_Status__c))  {
            cohabitants.add(pt.Person_2__c.id);
        } else if (newRed.contains(pt.Person_2__c.id) && healthStats.contains(pt.Person_1__c.Health_Status__c)) {
            cohabitants.add(pt.Person_1__c.id); 
            }
        }
        return cohabitants;
    }
   
public static Set <Id> getPrimary (Set<Id> newRed){
    Set<Id> primary = new Set<Id>();
    List<String> healthStats = new List<String>{'Yellow','Green'};
    List <People_Tracing__c> matchedTraces = [SELECT Id, Person_1__c, Person_2__c, Contact_Type__c, Contact_Date__c FROM People_Tracing__c 
                                              WHERE Person_1__c.id IN :newRed OR Person_2__c.id IN :newRed AND Contact_Type__c == 'Other' AND Contact_Date__c = LAST_N_DAYS:10];
    for (People_Tracing__c pt :matchedTraces) {
        if (newRed.contains(pt.Person_1__c.id) && healthStats.contains(pt.Person_2__c.Health_Status__c)) {
            primary.add(pt.Person_2__c.id);

        } else if (newRed.contains(pt.Person_2__c.id) && healthStats.contains(pt.Person_1__c.Health_Status__c)) {
            primary.add(pt.Person_1__c.id); 
            }
        }
        return primary;
    }

public static Set <Id> getNeighbours (Set<Id> newRed){
    Set<Id> neighbours = new Set<Id>();
    List <People_Tracing__c> matchedTraces = [SELECT Id, Person_1__c, Person_2__c, Contact_Type__c FROM People_Tracing__c 
                                              WHERE Person_1__c.id IN :newRed OR Person_2__c.id IN :newRed AND Contact_Type__c == 'Neighbours'];
    for (People_Tracing__c pt :matchedTraces) {
        if (newRed.contains(pt.Person_1__c.id) && pt.Person_2__c.healthStats == 'Green') {
            neighbours.add(pt.Person_2__c.id);

        } else if (newRed.contains(pt.Person_2__c.id) && healthStats.contains(pt.Person_1__c.Health_Status__c)) {
            neighbours.add(pt.Person_1__c.id); 
            }
        }
    return neighbours;
}

public static Set <Id> getSecondary (Set<Id> primaryContactsIds) {

    Set<Id> secondary = new Set<Id>();
    List <People_Tracing__c> matchedTraces = [SELECT Id, Person_1__c, Person_2__c, Contact_Type__c, Contact_Date__c, FROM People_Tracing__c 
                                              WHERE Person_1__c.id IN :primaryContactsIds OR Person_2__c.id IN :primaryContactsIds AND Contact_Type__c == 'Other' AND Contact_Date__c = LAST_N_DAYS:10];
    for (People_Tracing__c pt :matchedTraces) {
        if (primaryContactsIds.contains(pt.Person_1__c.id) && pt.Person_2__c.healthStats == 'Green') {
            secondary.add(pt.Person_2__c.id);

        } else if (primaryContactsIds.contains(pt.Person_2__c.id) && healthStats.contains(pt.Person_1__c.Health_Status__c)) {
            secondary.add(pt.Person_1__c.id); 
            }
        }
    return secondary;
}
    

}