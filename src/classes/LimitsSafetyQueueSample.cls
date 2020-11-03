public with sharing class LimitsSafetyQueueSample {

    private static final Integer DML_STATEMENTS_SHIFT = 10;
    private static final String ACCOUNT_NAME = 'testAccount';

    public void insertDummyAccountsAsync(Integer numberOfRecords) {
        System.enqueueJob(
                new InsertAccountsQueue()
                        .addItems(this.prepareQueueableItems(this.generateDummyAccounts(numberOfRecords)))
        );
    }

    public void insertDummyAccountsSync(Integer numberOfRecords) {
        insert this.generateDummyAccounts(numberOfRecords);
    }

    public void deleteDummyAccountsAsync(Integer numberOfRecords) {
        String name = ACCOUNT_NAME + '%';
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name LIKE :name LIMIT :numberOfRecords];
        System.enqueueJob(new DeleteAccountsQueue().addItems(this.prepareQueueableItems(accounts)));
    }

    private List<Account> generateDummyAccounts(Integer numberOfRecords) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            accounts.add(new Account(Name = ACCOUNT_NAME + i));
        }
        return accounts;
    }

    private Map<String, LimitsSafetyQueue.QueueableItem> prepareQueueableItems(List<Account> accounts) {
        Map<String, LimitsSafetyQueue.QueueableItem> queueableItemMap = new Map<String, LimitsSafetyQueue.QueueableItem>();
        for (Account account : accounts) {
            queueableItemMap.put(account.Name, new LimitsSafetyQueueSample.QueueableItem(account));
        }
        return queueableItemMap;
    }

    private static Boolean hasLimitsExceeded() {
        return Limits.getLimitDmlStatements() - DML_STATEMENTS_SHIFT < Limits.getDmlStatements();
    }

    private class InsertAccountsQueue extends LimitsSafetyQueue {

        public InsertAccountsQueue() {
            super(InsertAccountsQueue.class);
        }

        protected override void processItem(LimitsSafetyQueue.QueueableItem item) {
            LimitsSafetyQueueSample.QueueableItem queueableItem = (LimitsSafetyQueueSample.QueueableItem) item;
            insert queueableItem.getAccount();
        }

        protected override Boolean hasLimitsExceeded() {
            System.debug( LimitsSafetyQueueSample.hasLimitsExceeded() );
            return LimitsSafetyQueueSample.hasLimitsExceeded();
        }

        protected override void makeFinalAction() {
            System.debug( 'Dml statements: ' + Limits.getDmlStatements() );
        }
    }

    private class DeleteAccountsQueue extends LimitsSafetyQueue {
        public DeleteAccountsQueue() {
            super(DeleteAccountsQueue.class);
        }

        protected override void processItem(LimitsSafetyQueue.QueueableItem item) {
            LimitsSafetyQueueSample.QueueableItem queueableItem = (LimitsSafetyQueueSample.QueueableItem) item;
            delete queueableItem.getAccount();
        }

        protected override Boolean hasLimitsExceeded() {
            return LimitsSafetyQueueSample.hasLimitsExceeded();
        }

        protected override void makeFinalAction() {
            System.debug( 'Dml statements: ' + Limits.getDmlStatements() );
        }
    }

    private class QueueableItem extends LimitsSafetyQueue.QueueableItem {
        private Account account;

        public QueueableItem(Account account) {
            this.account = account;
        }

        public Account getAccount() {
            return this.account;
        }
    }
}