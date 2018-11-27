public class RentTransactionFieldsPerCriteriaWrapper {
    
    public string transactionField;
    public string operator;
    public string rentField;
    
    public RentTransactionFieldsPerCriteriaWrapper(string transactionField,string operator,string rentField){
        this.transactionField = transactionField;
        this.operator = operator;
        this.rentField = rentField;
    }   
    
}