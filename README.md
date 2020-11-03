# LimitsSafetyQueue
        
This class is used for creating safety for system limits Queueable classes.
Sample of using this class is in LimitsSafetyQueueSample.cls.

You can test it using developer console and firing next script:

        ```
        new LimitsSafetyQueueSample().insertDummyAccountsAsync(301);
        ```
        or 
        
        ```
        new LimitsSafetyQueueSample().deleteDummyAccountsAsync(301);
        ```
