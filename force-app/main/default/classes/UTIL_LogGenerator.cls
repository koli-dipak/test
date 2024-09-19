public with sharing class UTIL_LogGenerator 
{
    private static final String DELIMETER = '::';
    private static final LoggingLevel DEFAULT_LOGGING_LEVEL = LoggingLevel.INFO;
    private static final String DEFAULT_MESSAGE = 'Message';
    private static final String ENTER_MESSAGE = 'Enter method';
    private static final String ERROR_LINE = 'ERROR LINE';
    private static final String ERROR_MESSAGE = 'ERROR MESSAGE';
    private static final String ERROR_STACK_TRACE = 'ERROR STACK TRACE';
    private static final String ERROR_TYPE = 'ERROR TYPE';
    private static final String EXCEPTION_ENTER_MESSAGE = 'Exception has been catched';
    private static final String EXIT_MESSAGE = 'Exit method';
    private static final String OBJECT_MESSAGE = 'Object';
    private static final String PREFIX = '##### ';
    private static final String LIMITS_MESSAGE = 'LIMIT BLOCK';

    private String className;
    private String methodName;
    private Phase currentPhase;

    private enum Phase
    {
        START_PHASE, END_PHASE, PROCESSING_PHASE
    }

    public void start(String className, String methodName)
    {
        start(className, methodName, true);
    }

    public void start(String className, String methodName, Boolean withLimits)
    {
        this.className = className;
        this.methodName = methodName;
        this.currentPhase = Phase.START_PHASE;
        this.debug(this.createMessage(ENTER_MESSAGE));
        if (withLimits) this.limits();
        this.currentPhase = Phase.PROCESSING_PHASE;
    }

    public void end()
    {
        end(true);
    }

    public void end(Boolean withLimits)
    {
        this.currentPhase = Phase.END_PHASE;
        if (withLimits) this.limits();
        this.debug(this.createMessage(EXIT_MESSAGE));
    }

    public void log(String msg)
    {
        this.debug(createMessage(msg));
    }

    public void log(String msg, Object obj)
    {
        this.log(msg, obj, false);
    }

    public void log(String msg, Object obj, Boolean pretty)
    {
        this.debug(createMessage(msg));
        this.log(obj, pretty);
    }

    public void log(Object obj)
    {
        this.log(obj, false);
    }

    public void log(Object obj, Boolean pretty)
    {
        this.debug(createMessage(OBJECT_MESSAGE, pretty ? JSON.serializePretty(obj) : JSON.serialize(obj)));
    }

    public void error(Exception e)
    {
        LoggingLevel level = LoggingLevel.ERROR;
        this.debug(level, this.createMessage(EXCEPTION_ENTER_MESSAGE));
        this.debug(level, this.createMessage(ERROR_TYPE, e.getTypeName()));
        this.debug(level, this.createMessage(ERROR_MESSAGE, e.getMessage()));
        this.debug(level, this.createMessage(ERROR_LINE, String.valueOf(e.getLineNumber())));
        this.debug(level, this.createMessage(ERROR_STACK_TRACE, e.getStackTraceString()));
    }

    private void debug(LoggingLevel level, String message)
    {
        System.debug(level, message);
    }

    private void debug(String message)
    {
        this.debug(DEFAULT_LOGGING_LEVEL, message);
    }

    private String createMessage(String messageDescription, String message)
    {
        String resultMessage = this.className + DELIMETER;
        resultMessage += this.methodName + DELIMETER;
        resultMessage += '[' + messageDescription + ']: ' + message;
        return resultMessage;
    }

    private String createMessage(String message)
    {
        return this.createMessage(DEFAULT_MESSAGE, message);
    }

    public void limits()
    {
        this.debug(this.createMessage(LIMITS_MESSAGE + '-' + String.valueOf(this.currentPhase)));
        this.debug(createMessage('QueryRows', Limits.getQueryRows() + ' / ' + Limits.getLimitQueryRows()));
        this.debug(createMessage('DMLRows', Limits.getDMLRows() + ' / ' + Limits.getLimitDMLRows()));
        this.debug(createMessage('DMLStatements', Limits.getDMLStatements() + ' / ' + Limits.getLimitDMLStatements()));
    }
}