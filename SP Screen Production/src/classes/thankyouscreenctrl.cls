public class thankyouscreenctrl {
    public String displayName{get;set;}
    public String firstName {get;set;}
    public ServiceAppointment sa {get;set;}
    public Boolean showFlag {get;set;}
    public String wrdOrdrId {get;set;}
    public Contact cntObj {get;set;}
    public WorkOrder wrkOrdr {get;set;}
    public DateTime strtTime {get;set;}
    public DateTime endTime {get;set;}
    
    public thankyouscreenctrl(){
        showFlag = false;
        if(ApexPages.currentPage().getParameters().get('wrdOrdrId') != null){
            wrdOrdrId = ApexPages.currentPage().getParameters().get('wrdOrdrId');
            wrkOrdr = [Select Id,Opportunity__c from WorkOrder where Id=: wrdOrdrId];
        }
        if(ApexPages.currentPage().getParameters().get('cntId') != null){
            String cntId = ApexPages.currentPage().getParameters().get('cntId');
            cntObj = [Select id,firstName,AccountId from Contact where id=: cntId];
            firstName = cntObj.firstName;
        }
    }
    
    public void assignResource(){
        sa = [Select id, EarliestStartTime, DueDate,SchedStartTime,ArrivalWindowStartTime,ArrivalWindowEndTime from ServiceAppointment where ParentRecord.id=:wrdOrdrId limit 1];
        List<AssignedResource> obj_currentresource = [select id,ServiceAppointmentId,ServiceResourceId, ServiceResource.Name,ServiceResource.RelatedRecordId from AssignedResource where ServiceAppointmentId =:sa.Id limit 1];
        //system.debug('88888' + obj_currentresource);
        //system.debug('*******' + sa.ArrivalWindowStartTime);
        if(obj_currentresource != null && obj_currentresource.size() > 0 && sa.ArrivalWindowStartTime != null && sa.ArrivalWindowEndTime != null){
            showFlag =true;
            displayName = obj_currentresource[0].ServiceResource.Name;
            strtTime = sa.ArrivalWindowStartTime.addHours(10);
            endTime = sa.ArrivalWindowEndTime.addHours(10);
            system.debug(endTime);
            cntObj.OwnerId = obj_currentresource[0].ServiceResource.RelatedRecordId;
            update cntObj;
            
            Account act = new Account(Id=cntObj.AccountId);
            act.OwnerId = obj_currentresource[0].ServiceResource.RelatedRecordId;
            update act;
            
            Opportunity opp = new Opportunity(Id=wrkOrdr.Opportunity__c);
            opp.OwnerId = obj_currentresource[0].ServiceResource.RelatedRecordId;
            update opp;
        }
    }
}