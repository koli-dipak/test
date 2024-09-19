@isTest
public class DR_TransformStringUtility_T {
    public testmethod static void InvokeFunctions(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        List<Object> listObj=new List<Object>();
        listObj.add('{"data":{"data":"data"}}');
        listObj.add('data');
        listObj.add('data');
        inputs.put('arguments',listObj);
        new DR_TransformStringUtility().invokeMethod('replace', inputs, output, options);
        new DR_TransformStringUtility().invokeMethod('contains', inputs, output, options);
        new DR_TransformStringUtility().invokeMethod('match', inputs, output, options);
        new DR_TransformStringUtility().invokeMethod('isNumeric', inputs, output, options);
        listObj=new List<Object>();
        listObj.add(null);
        inputs.put('arguments',listObj);
        new DR_TransformStringUtility().invokeMethod('isNumeric', inputs, output, options);
        listObj=new List<Object>();
        listObj.add(123);
        inputs.put('arguments',listObj);
        new DR_TransformStringUtility().invokeMethod('isNumeric', inputs, output, options);
        listObj=new List<Object>();
        Map<String,Object> dataRec=new Map<String,Object>();
        Map<String,Object> childdataRec=new Map<String,Object>();
        
        childdataRec.put('RecordId','data');
        List<object> childArray=new List<Object>();
        childArray.add(childdataRec);
        dataRec.put('data',childArray);
        
        listObj.add(dataRec);
        listObj.add('data');
        listObj.add('data');
        inputs.put('arguments',listObj);
        
        new DR_TransformStringUtility().invokeMethod('retriveFromJson', inputs, output, options);
        new DR_TransformStringUtility().invokeMethod('existInList', inputs, output, options);
    }
}