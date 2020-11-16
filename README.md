# ContinuousQueue
        
This class is used for creating queue that must processes big scope of data or makes to many callouts.
Sample of using this class is in ContinuousQueueTest.cls.

ContinuousQueue class required override for `void processItem(QueueableItem item)`;

If it is needed to collect/cache data before queue execution then override `void makeStartAction()`;

If it is needed to make some actions (like DML) in the end of queue (like after scope of Callouts) then override `void makeFinalAction()`;
 
If it is needed to change the logic of remaining items then override `void processRemainingItems()`;

If the limits check is needed then override `Boolean hasLimitsExceeded()`;

You can set your own error handling by overriding `void addError(Exception e)` and log errors by overriding `void commitErrors()`.
