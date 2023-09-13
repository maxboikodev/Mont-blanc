public class ContactController {
    // LOCAL ELIGIBILITY INDICATOR 
    //  for (Contact c : Trigger.new) {
    //           if (String.isNotBlank(c.AccountId) && c.Active__c = true){ git add 
    //           //We have All AccountIds of Accounts with active contacts 
    //
    // // for (Ingeer i = 0; i<=a.Contacts.size(); i++) {
    //   }
    
    
    public static void activeContactsCompute (Set<Id> Id) {
        List <Account> tempAccs = [SELECT Id, Name, Active_Contacts__c, (SELECT Name, Active__c FROM Contacts WHERE Active__c = TRUE) FROM Account WHERE Id IN :Ids];
		List <Account> finalAccs = New List <Account> ();
        
        for (Account a : tempAccs) {
            Integer count = 0;
            for (Contact c : a.Contacts) {
                If (c.Active__c == True) {
                count++;
				}
            }
            a.Active_Contacts__c = count; 
			finalAccs.add(a);
         //   System.debug('Account: '+a.Name+ '. Number of active contacts: ' +count);
        }
		update finalAccs;        	
    }
    
    
    public static void activeContactsInsert (List <Contact> tempCons) {
        Set <Id> Ids = new Set <Id> ();
      
        for (Contact c : tempCons) {
            if (String.isNotBlank(c.AccountId) && c.Active__c == true) {
                Ids.add (c.AccountId);  
            }
        }
        ContactController.activeContactsCompute (Ids);
    }
            
   
      public static void activeContactsUpdate (List <Contact> tempCons, Map <Id, Contact> OldCons) {
          Set <Id> Ids = new Set <Id> ();
        for (Contact c : tempCons) {
            if (String.isNotBlank(c.AccountId) && OldCons.get(c.Id).Active__c != c.Active__c) {
                Ids.add (c.AccountId);
            }
        }
           ContactController.activeContactsCompute(Ids);    
      }
    
    public static void activeContactsDelete (List <Contact> tempCons) {
          Set <Id> Ids = new Set <Id> ();
        for (Contact c : tempCons) {
            if (String.isNotBlank(c.AccountId) && c.Active__c == true) {
                Ids.add (c.AccountId);
            }
        }
           ContactController.activeContactsCompute(Ids);    
      }
    
    public static void activeContactsUndelete (List <Contact> tempCons) {
          Set <Id> Ids = new Set <Id> ();
        for (Contact c : tempCons) {
            if (String.isNotBlank(c.AccountId) && c.Active__c == true) {
                Ids.add (c.AccountId);
            }
        }
           ContactController.activeContactsCompute(Ids);    
      }
     
}