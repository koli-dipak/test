global class DR_TransformStringUtility implements vlocity_INS.VlocityOpenInterface
{
     global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if (methodName == 'replace')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', replace(arguments));
        }
         if (methodName == 'contains')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', contains(arguments));
        }
        if (methodName == 'match')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', match(arguments));
        }
         if (methodName == 'retriveFromJson')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', retriveFromJson(arguments));
        }
        if (methodName == 'existInList')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', existInList(arguments));
        }
         if (methodName == 'isNumeric')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', isNumeric(arguments));
        }
        
        return true;
    }
     
    String replace(List<Object> arguments){
        String str = String.valueOf(arguments[0]);
        String target = String.valueOf(arguments[1]);
        String replacement = String.valueOf(arguments[2]);
	return str.replace(target,replacement);
    }
    Object retriveFromJson(List<Object> arguments){
        Object rootJson = arguments[0];
        String key = String.valueOf(arguments[1]);
        for(String param  :key.split(':')){
            rootJson = ((Map<String,object>) rootJson).get(param);
        }
        if(arguments.size()>2){
            for(Object item :(List<object>) rootJson){
                Map<String,Object> data = (Map<String,Object>) item;
                if(String.valueOf(data.get('RecordId'))==String.valueOf(arguments[2])){
                    rootJson = item;
                }
            }
            //rootJson = ((List<object>) rootJson)[Integer.valueOf(arguments[2])];
        }
	return rootJson;
    }
    boolean contains(List<Object> arguments){
        String str = String.valueOf(arguments[0]);
        String target = String.valueOf(arguments[1]);
        
	return str.contains(target);
    }
    boolean existInList(List<Object> arguments){
        System.debug('arguments::'+arguments);
        List<Object> str = arguments;
        List<string> strList= new List<string> ();
        for(Object item: str){
           strList.add(String.valueOf(item));
        }
        String target = strList.remove(0);
        
        System.debug('str.indexOf(target)::--'+ strList.indexOf(target));
        if(strList.indexOf(target) == -1){
            return false;
        }
        return true;
	//return str.contains(target);
    }
    boolean match(List<Object> arguments){
        String str = String.valueOf(arguments[0]);
        String regex = String.valueOf(arguments[1]);
        
	return Pattern.matches(regex, str);
    }
    
    boolean isNumeric(List<Object> arguments){
        String input = String.valueOf(arguments[0]);
       Boolean isNumber = false;
        if(input==null)
        {
            isNumber=false;
            return isNumber;
        }
       

        try {
            Decimal inputNumber = Decimal.valueOf(input.trim());
            isNumber = true;
        } catch (TypeException e) {
            isNumber = false;
        }

        return isNumber;  
    }
   
}