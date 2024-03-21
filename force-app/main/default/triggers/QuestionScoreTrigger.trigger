trigger QuestionScoreTrigger on Question__c (after insert, after update) {
    Set<Id> examIds = new Set<Id>();
    for (Question__c question : Trigger.new) {
        examIds.add(question.Exam__c);
    }
 
    Map<Id, Exam__c> examsToUpdate = new Map<Id, Exam__c>([
        SELECT Id, TotalScore__c, (SELECT Id, Score__c FROM Questions__r) 
        FROM Exam__c 
        WHERE Id IN :examIds
    ]);

    for (Question__c question : Trigger.new) {
        Exam__c exam = examsToUpdate.get(question.Exam__c);
        if (exam != null) {
            Decimal newTotalScore = 0;
            for (Question__c q : exam.Questions__r) {
                newTotalScore += q.Score__c;
            }
            exam.TotalScore__c = newTotalScore;
            examsToUpdate.put(exam.Id, exam);
        }
    }

    update examsToUpdate.values();
}
