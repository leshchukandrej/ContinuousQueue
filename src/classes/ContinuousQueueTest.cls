@IsTest
private class ContinuousQueueTest {

    static final String ACCOUNT_NAME = 'testAccount';

    static Integer processedRecords = 0;
    static Boolean isEnqueuedNewQueue = false;


    @IsTest
    static void insertDummyAccountsInQueueTest() {

        Test.startTest();

        System.enqueueJob(
                new InsertAccountsQueue()
                        .addItems(prepareQueueableItems(generateDummyAccounts(151)))
        );

        Test.stopTest();

        System.assertEquals(Limits.getLimitDmlStatements(), processedRecords);
        System.assert(isEnqueuedNewQueue);
        System.assertEquals(Limits.getLimitDmlStatements(), [SELECT COUNT() FROM Account]);
    }

    @IsTest
    static void processEmptyQueueTest() {

        Test.startTest();

        EmptyQueue emptyQueue = new EmptyQueue();

        for (Integer i = 0; i < 200; i++) {
            emptyQueue.addItem(String.valueOf(i), new ContinuousQueueTest.EmptyQueueableItem());
        }

        System.enqueueJob(emptyQueue);

        Test.stopTest();

        System.assertEquals(200, processedRecords);
        System.assert(!isEnqueuedNewQueue);
    }

    private static List<Account> generateDummyAccounts(Integer numberOfRecords) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            accounts.add(new Account(Name = ACCOUNT_NAME + i));
        }
        return accounts;
    }

    private static Map<String, ContinuousQueue.QueueableItem> prepareQueueableItems(List<Account> accounts) {
        Map<String, ContinuousQueue.QueueableItem> queueableItemMap = new Map<String, ContinuousQueue.QueueableItem>();
        for (Account account : accounts) {
            queueableItemMap.put(account.Name, new ContinuousQueueTest.QueueableItem(account));
        }

        System.debug( queueableItemMap );

        return queueableItemMap;
    }

    private static Boolean hasLimitsExceeded() {
        return Limits.getLimitDmlStatements() == Limits.getDmlStatements();
    }

    private class InsertAccountsQueue extends ContinuousQueue {

        public InsertAccountsQueue() {
            super(InsertAccountsQueue.class);
        }

        protected override void processItem(ContinuousQueue.QueueableItem item) {
            ContinuousQueueTest.QueueableItem queueableItem = (ContinuousQueueTest.QueueableItem) item;
            insert queueableItem.getAccount();
            processedRecords++;
        }

        protected override Boolean hasLimitsExceeded() {
            return ContinuousQueueTest.hasLimitsExceeded();
        }

        protected override void processRemainingItems() {
            if (itemsToProcessByKey.size() > 0) isEnqueuedNewQueue = true;
        }
    }

    private class QueueableItem extends ContinuousQueue.QueueableItem {
        private Account account;

        public QueueableItem(Account account) {
            this.account = account;
        }

        public Account getAccount() {
            return this.account;
        }
    }

    private class EmptyQueue extends ContinuousQueue {

        public EmptyQueue() {
            super(EmptyQueue.class);
        }

        protected override void processItem(ContinuousQueue.QueueableItem item) {
            processedRecords++;
        }

        protected override void processRemainingItems() {
            if (itemsToProcessByKey.size() > 0) isEnqueuedNewQueue = true;
        }
    }

    private class EmptyQueueableItem extends ContinuousQueue.QueueableItem {}
}