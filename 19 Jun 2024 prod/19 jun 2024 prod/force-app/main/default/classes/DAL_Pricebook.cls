public class DAL_Pricebook {

    public static Id getStandardPricebook(){
        return [Select Id, Name From Pricebook2 Where isStandard=True LIMIT 1].id;
    }
}