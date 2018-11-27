public class SetupSchedularAutomaticallyController {
    public SetupSchedularAutomaticallyController(){
        
    }
    @AuraEnabled
    public static String scheduleBatch(String batchName,String prefferedTime , String prefferedDay){
        if(batchName=='Accounting Batch'){
            if(prefferedTime != 'Right Now'){
                validateSchedule('CreateAccountingSchedular');
            }
            return setAccountingBatch(prefferedTime,prefferedDay);
        }else if(batchName=='Balance List Batch'){
            validateSchedule('BalanceSheetSchedular');
            return setBalanceSheetBatch(prefferedTime,prefferedDay);
        }
        return null;
    }
    public static string setAccountingBatch(String prefferedTime , String PrefferedDay){  //0 0 1 1 * ? *    ist of mnth
        if(prefferedTime == 'Right Now'){
            database.executeBatch(new CreateAccountingBatch(),1);
            return 'Accounting Batch is Being executed Successfully';
        }else if(PrefferedDay == 'Daily'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 * * * ?', new CreateAccountingSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 0,4,8,12,16,20 * * ?', new CreateAccountingSchedular());
            }else{
                System.schedule('CreateAccountingSchedular', '0 0 '+prefferedTime+' * * ?', new CreateAccountingSchedular());
            }
        }else if(PrefferedDay == 'Today'){
            String day = String.valueof(system.today().day());
            String month = String.valueof(system.today().month());
            String year = String.valueof(system.today().year());
            if(prefferedTime == 'Every Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 * '+day+' '+month+''+' ? '+year , new CreateAccountingSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 0,4,8,12,16,20 '+day+' '+month+''+' ? '+year , new CreateAccountingSchedular());
            }else{
                System.schedule('CreateAccountingSchedular', '0 0 '+prefferedTime+' '+day+' '+month+''+' ? '+year , new CreateAccountingSchedular());
            }
        }else if(PrefferedDay == '5th of every month'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 * 5 * ? *', new CreateAccountingSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 0,4,8,12,16,20 5 * ? *', new CreateAccountingSchedular());
            }else{
                System.schedule('CreateAccountingSchedular', '0 0 '+prefferedTime+' 5 * ? *', new CreateAccountingSchedular());
            }
        }else if(PrefferedDay == '15th of every month'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 * 15 * ? *', new CreateAccountingSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 0,4,8,12,16,20 15 * ? *', new CreateAccountingSchedular());
            }else{
                System.schedule('CreateAccountingSchedular', '0 0 '+prefferedTime+' 15 * ? *', new CreateAccountingSchedular());
            }
        }else if(PrefferedDay == '25th of every month'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 * 25 * ? *', new CreateAccountingSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('CreateAccountingSchedular', '0 0 0,4,8,12,16,20 25 * ? *', new CreateAccountingSchedular());
            }else{
                System.schedule('CreateAccountingSchedular', '0 0 '+prefferedTime+' 25 * ? *', new CreateAccountingSchedular());
            }
        }
        return 'Accounting Batch Scheduled Successfully';
    }
    public static string setBalanceSheetBatch(String prefferedTime , String PrefferedDay){
        system.debug('prefferedTime :: '+prefferedTime+' PrefferedDay :: '+PrefferedDay);
        if(prefferedTime == 'Right Now'){
            database.executeBatch(new BalanceSheetBatch(),1);
            return 'BalanceSheet Batch is Being executed Successfully';
        }else if(PrefferedDay == 'Daily'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 * * * ?', new BalanceSheetSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 0,4,8,12,16,20 * * ?', new BalanceSheetSchedular());
            }else{
                System.schedule('BalanceSheetSchedular', '0 0 '+prefferedTime+' * * ?', new BalanceSheetSchedular());
            }
        }else if(PrefferedDay == 'Today'){
            String day = String.valueof(system.today().day());
            String month = String.valueof(system.today().month());
            String year = String.valueof(system.today().year());
            if(prefferedTime == 'Every Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 * '+day+' '+month+''+' ? '+year , new BalanceSheetSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 0,4,8,12,16,20 '+day+' '+month+''+' ? '+year , new BalanceSheetSchedular());
            }else{
                System.schedule('BalanceSheetSchedular', '0 0 '+prefferedTime+' '+day+' '+month+''+' ? '+year , new BalanceSheetSchedular());
            }
        }else if(PrefferedDay == '5th of every month'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 * 5 * ? *', new BalanceSheetSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 0,4,8,12,16,20 5 * ? *', new BalanceSheetSchedular());
            }else{
                System.schedule('BalanceSheetSchedular', '0 0 '+prefferedTime+' 5 * ? *', new BalanceSheetSchedular());
            }
        }else if(PrefferedDay == '15th of every month'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 * 15 * ? *', new BalanceSheetSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 0,4,8,12,16,20 15 * ? *', new BalanceSheetSchedular());
            }else{
                System.schedule('BalanceSheetSchedular', '0 0 '+prefferedTime+' 15 * ? *', new BalanceSheetSchedular());
            }
        }else if(PrefferedDay == '25th of every month'){
            if(prefferedTime == 'Every Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 * 25 * ? *', new BalanceSheetSchedular());
            }else if(prefferedTime == 'Every Four Hour'){
                System.schedule('BalanceSheetSchedular', '0 0 0,4,8,12,16,20 25 * ? *', new BalanceSheetSchedular());
            }else{
                System.schedule('BalanceSheetSchedular', '0 0 '+prefferedTime+' 25 * ? *', new BalanceSheetSchedular());
            }
        }
        return 'BalanceSheet Batch Scheduled Successfully';
    }
    public static void  validateSchedule(String batchClass){
        List<CronTrigger> crnTrigger = [select id,CronJobDetail.Id,CronJobDetail.Name,CronJobDetail.JobType from CronTrigger where CronJobDetail.Name =:batchClass AND CronJobDetail.JobType = '7' limit 1];
        if(crnTrigger.size()>0){
            List<AsyncApexJob> asyncJob = [Select Id,Status, ApexClassId, ApexClass.Name  From AsyncApexJob where Id=:crnTrigger[0].CronJobDetail.Id limit 1];
            if(asyncJob.size()>0){
                System.abortJob(asyncJob[0].Id);
            }
            system.abortJob(crnTrigger[0].Id);
        }
    }
}