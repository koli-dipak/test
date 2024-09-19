@isTest
private class UTIL_LogGenerator_TEST {

    private static final String TEST_MESSAGE = 'Coverage test';
    private static final List<Object> TEST_OBJECT = new List<Object>();
    private static final Boolean IS_PRETTY = true;

    @IsTest static void doTest()
    {
        Test.startTest();
        UTIL_LogGenerator logger = new UTIL_LogGenerator();
        logger.start(UTIL_LogGenerator_TEST.class.getName(), 'doTest');
        logger.log(TEST_MESSAGE);
        logger.log(TEST_OBJECT);
        logger.log(TEST_MESSAGE, TEST_OBJECT);
        logger.log(TEST_OBJECT, IS_PRETTY);
        logger.log(TEST_MESSAGE, TEST_OBJECT, IS_PRETTY);
        logger.end();
        Test.stopTest();
    }
}