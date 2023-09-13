public with sharing class CTPersonController {
    
    public static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);
        // return encoded string
        return EncodingUtil.base64Encode(hash);
    }
    
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }
    
    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
            FROM Person__c 
            WHERE Name LIKE :searchTerm 
                OR Mobile__c LIKE :searchTerm 
                OR Token__c LIKE :searchTerm 
            ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }
    
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                WHERE Id =:personId];
        if(people != null && people.size() > 0){
            return people[0];
        }
        return null;
    }
    
    public static Map <String, Integer> getHealthStatusCount () {
		Map <String, Integer> healthStatusesMap = new Map <String, Integer> (); 
        
        AggregateResult [] healthStatuses = [SELECT Health_Status__c, COUNT(Id) FROM Person__c GROUP BY Health_Status__c];
        
        for (AggregateResult i : healthStatuses) {
            String tempString = String.valueOf(i.get('Health_Status__c'));
            Integer tempInteger = Integer.valueOf (i.get('expr0'));
			healthStatusesMap.put(tempString, tempInteger);
        }
        system.debug (healthStatusesMap);
        return healthStatusesMap;
    }

    
}