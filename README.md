# TSCoreDataStore

Quick and easy access to memory or persistent managed object context on main and background threads

# Build Project

This project relies on another pod so run 'pod install' first

# Pod install
```
pod 'TSCoreDataStore', :git => 'https://github.com/trickysquirrel/TSCoreDataStore.git'
```

# Example
```
self.dataStore = [[TSCoreDataStore alloc] initInMemoryStoreWithModelName:@"TSCoreDataStore"];

__weak typeof(self) weakSelf = self;

NSOperationQueue *queue = [NSOperationQueue new];

[queue addOperationWithBlock:^{

    NSManagedObjectContext *context = self.dataStore.backgroundManagedObjectContext;

    // add managed objects to context

    [weakSelf.dataStore saveContext:context];
}];

```
