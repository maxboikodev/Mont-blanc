@IsTest
public with sharing class ContactControllerTest {
    //Assets tested by a testClass:
    //Contact obj, Account object, ControllerContoller, ContactTrigger
 
    static Account acc1;
    static Account acc2;
    static Contact con1;
    static Contact con2;
    
    @TestSetup
    static void makeData(){

        List<Account> accounts = new List<Account>{
            new Account(Name = 'acc1'),
            new Account(Name = 'acc2')
        };
        
        insert accounts;
 
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'con1', AccountId = accounts[0].Id),
            new Contact(LastName = 'con2', AccountId = accounts[1].Id, Active__c = true)
        }; 

        insert contacts;
    }
    static void initData() {
        acc1 = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Name = 'acc1' LIMIT 1];
        acc2 = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Name = 'acc2' LIMIT 1];
        con1 = [SELECT Id, LastName, Active__c FROM Contact WHERE Name = 'con1' LIMIT 1];
        con2 = [SELECT Id, LastName, Active__c FROM Contact WHERE Name = 'con2' LIMIT 1];
    }
    @IsTest
    public static void activeContactsComputeTest () {
        initData();
        List <Account> tempAccs = [SELECT Id, Name, Active_Contacts__c, (SELECT Name, Active__c FROM Contacts WHERE Active__c = TRUE) FROM Account WHERE Id IN (:acc1.Id, :acc2.Id)];
        System.assert(tempAccs[0].Active_Contacts__c == null);
        System.assert(tempAccs[1].Active_Contacts__c == 1);   

        con1 = [SELECT Id, LastName, Active__c, AccountId FROM Contact WHERE Id = :con1.Id LIMIT 1];
        con1.AccountId = tempAccs[1].Id;
        update con1; 

        List <Account> tempAccs2 = New List <Account> ();

        for (Account a : tempAccs) {
            Integer count = 0;
            for (Contact c : a.Contacts) {
                If (c.Active__c == True) {
                count++;
				}
            }
            a.Active_Contacts__c = count; 
			tempAccs2.add(a);
        }
		update tempAccs2; 
      
        List <Account> tempAccs3 = [SELECT Id, Name, Active_Contacts__c, (SELECT Name, Active__c FROM Contacts WHERE Active__c = TRUE) FROM Account WHERE Id IN (:acc1.Id, :acc2.Id)]; 
        System.assert(tempAccs3[0].Active_Contacts__c == 0);
        System.debug ('DEBUG statement1: '+ tempAccs3[1].Active_Contacts__c);
        System.assert(tempAccs3[1].Active_Contacts__c == 2);  
    }
@IsTest
    public static void activeContactsInsertTest () {
        initData();
        //Testing insert scenario    
            System.assert (acc1.Active_Contacts__c == null); 

        List <Contact> insertCons = new List<Contact> {
            new Contact (LastName = 'con3'),
            new Contact (LastName = 'con4', AccountId = '0017R00002zA52nQAC', Active__c = true),
            new Contact (LastName = 'con5', AccountId = acc1.Id),
            new Contact (LastName = 'con6', AccountId = acc1.Id, Active__c = true),
            new Contact (LastName = 'con7', AccountId = acc1.Id, Active__c = false)
        };

        insert insertCons;
                    
        Account acc1upd = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Id = :acc1.Id LIMIT 1];
        System.assert (acc1upd.Active_Contacts__c == 1); 
    
        //Testing method code  
        Set <Id> Ids = new Set <Id> ();
        for (Contact c : insertCons) {
            if (String.isNotBlank(c.AccountId) && c.Active__c == true) {
                Ids.add (c.AccountId);  
            }
     }
    system.assert(Ids.size() == 2);
}
@IsTest
    public static void activeContactsUpdateTest () {

        initData();
        System.assert(acc1.Active_Contacts__c == null);
        con1.AccountId = acc1.Id;
        con1.Active__c = TRUE;
        update con1;

        Account updAcc = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Name = 'acc1' LIMIT 1];
        System.assert(updAcc.Active_Contacts__c == 1);
    }
@IsTest
    public static void activeContactsDeleteTest () {
        
        initData();
        System.assert(acc2.Active_Contacts__c == 1);

        delete con2;
        Account updAcc = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Name = 'acc2' LIMIT 1];
        System.assert(updAcc.Active_Contacts__c == 0);
    }
@IsTest
    public static void activeContactsUndeleteTest () {
        initData();
        System.assert(acc2.Active_Contacts__c == 1);

        delete con2;
        Account updAcc = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Name = 'acc2' LIMIT 1];
        System.assert(updAcc.Active_Contacts__c == 0);

        undelete con2;
        Account updAcc1 = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Name = 'acc2' LIMIT 1];
        System.assert(updAcc1.Active_Contacts__c == 1);
    }

}