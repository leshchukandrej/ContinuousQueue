public abstract inherited sharing class ContinuousQueue implements Queueable, Database.AllowsCallouts {

    protected final Integer CALLOUT_SHIFT = 10;
    protected final Integer LIMIT_STOPWATCH = 100000;

    protected List<Exception> exceptions;

    private Type queueableType;
    protected Map<String, QueueableItem> itemsToProcessByKey;
    private Stopwatch stopwatch;

    public ContinuousQueue(Type queueableType) {
        this.queueableType = queueableType;
    }

    public Boolean hasItems() {
        return this.itemsToProcessByKey != null && this.itemsToProcessByKey.keySet().size() > 0;
    }

    public ContinuousQueue addItem(String key, QueueableItem item) {
        if (this.itemsToProcessByKey == null) {
            this.itemsToProcessByKey = new Map<String, QueueableItem>();
        }
        this.itemsToProcessByKey.put(key, item);

        return this;
    }

    public ContinuousQueue addItems(Map<String, QueueableItem> itemByString) {
        if (this.itemsToProcessByKey == null) {
            this.itemsToProcessByKey = new Map<String, QueueableItem>();
        }
        this.itemsToProcessByKey.putAll(itemByString);

        return this;
    }

    public void execute(QueueableContext qc) {

        if (!this.hasItems()) return;

        Set<String> processedItemKeys = new Set<String>();

        this.initStopwatch();

        this.startStopwatch();

        this.makeStartAction();

        this.endStopWatch();

        for (String itemKey : this.itemsToProcessByKey.keySet()) {
            if (this.hasAnyLimitsExceeded()) {
                break;
            }

            this.startStopwatch();

            try {
                this.processItem(this.itemsToProcessByKey.get(itemKey));
            } catch (Exception e) {
                this.addError(e);
            }

            this.endStopWatch();

            processedItemKeys.add(itemKey);
        }

        this.removeProcessedItems(processedItemKeys);

        this.makeFinalAction();

        this.processRemainingItems();

        this.commitErrors();

        System.debug('Callout stopwatch: ' + this.stopwatch.getTime());
    }

    protected abstract void processItem(QueueableItem item);

    protected virtual void makeStartAction() {
    }

    protected virtual void makeFinalAction() {
    }

    protected virtual void processRemainingItems() {
        if (this.itemsToProcessByKey.values().size() > 0) {
            ContinuousQueue queueable = (ContinuousQueue) this.queueableType.newInstance();
            System.enqueueJob(queueable.addItems(this.itemsToProcessByKey));
        }
    }

    protected virtual Boolean hasLimitsExceeded() {
        return false;
    }

    protected virtual void addError(Exception e) {
        if (this.exceptions == null) {
            this.exceptions = new List<Exception>();
        }
        this.exceptions.add(e);
    }

    protected virtual void commitErrors() {
        if (this.exceptions == null) return;

        for (Exception e: this.exceptions) {
            System.debug( e );
        }
    }

    private void initStopwatch() {
        this.stopwatch = new Stopwatch();
    }

    private void startStopwatch() {
        this.stopwatch.start();
    }

    private void endStopWatch() {
        this.stopwatch.pause();
    }

    private Boolean hasAnyLimitsExceeded() {
        return this.hasCalloutsExceeded() || this.hasLimitsExceeded();
    }

    private Boolean hasCalloutsExceeded() {
        return Limits.getLimitCallouts() - CALLOUT_SHIFT < Limits.getCallouts()
                || this.stopwatch.getTime() > LIMIT_STOPWATCH;
    }

    private void removeProcessedItems(Set<String> processedItemStrings) {
        this.itemsToProcessByKey.keySet().removeAll(processedItemStrings);
    }

    public abstract class QueueableItem {

    }

    private class Stopwatch {
        private Long startTime;
        private Long fullTime;

        public Stopwatch() {
            this.startTime = 0;
            this.fullTime = 0;
        }

        public void start() {
            this.startTime = Datetime.now().getTime();
        }

        public void pause() {
            Long endTime = Datetime.now().getTime();
            this.fullTime += (endTime - this.startTime);
        }

        public Long getTime() {
            return this.fullTime;
        }
    }

}