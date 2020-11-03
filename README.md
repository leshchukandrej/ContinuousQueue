# LimitsSafetyQueue
        
This class is used for creating safety for system limits Queueable classes.
Sample of using this class is in LimitsSafetyQueueSample.cls.

You can test it using developer console and firing next script:

        ```sh
        new LimitsSafetyQueueSample().insertDummyAccountsAsync(301);
        ```
        or 
        
        ```sh
        new LimitsSafetyQueueSample().deleteDummyAccountsAsync(301);
        ```
