global class CreateAccountingSchedular implements Schedulable {
   global void execute(SchedulableContext SC) {
      CreateAccountingBatch autoMApping = new CreateAccountingBatch(); 
      database.executeBatch(autoMApping,1);
   }
}