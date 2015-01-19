//
//  Created by Richard Moult on 12/12/2014.
//  Copyright (c) 2014 TrickySquirrel. All rights reserved.
//

#import "TSCoreDataStore.h"


@interface TSCoreDataStore ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@property (nonatomic,strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *storeType;
@end





@implementation TSCoreDataStore

- (id)init {
    
    return [self initInMemoryStoreWithModelName:nil];
}


- (id)initInMemoryStoreWithModelName:(NSString *)modelName {
    
    NSAssert(modelName, @"model name required");
    
    return [self initWithModelName:modelName storeType:NSInMemoryStoreType];
}


- (id)initPersistentStoreWithModelName:(NSString *)modelName {
    
    NSAssert(modelName, @"model name required");

    return [self initWithModelName:modelName storeType:NSSQLiteStoreType];
}


- (id)initWithModelName:(NSString *)modelName storeType:(NSString *)storeType {
    
    self = [super init];
    
    if (self) {
        
        _modelName = modelName;
        _storeType = storeType;
        [self registerForBackgroundManagedObjectContextDidSaveNotification];
    }
    
    return self;
}


- (void)dealloc {
    
    [self unregisterForManagedObjectContextDidSaveNotification];
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSURL *storeURL = nil;
    
    if ([self createSQLStoreManagedObjectContext]) {
        
        storeURL = [self persistentStoreURLWithStoreName:self.modelName];
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorWithModel:self.managedObjectModel type:self.storeType storeURL:storeURL options:nil];
    
    _managedObjectContext = [self managedObjectContextWithCoordinator:coordinator concurrencyType:NSMainQueueConcurrencyType];

    return _managedObjectContext;
}


- (BOOL)createSQLStoreManagedObjectContext {
    
    if ([self.storeType isEqualToString:NSSQLiteStoreType]) {
        return YES;
    }
    return NO;
}


- (NSManagedObjectContext *)managedObjectContextWithCoordinator:(NSPersistentStoreCoordinator*)coordinator concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType{
    
    NSManagedObjectContext *managedObjectContext = nil;
    
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.storeName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSURL*)persistentStoreURLWithStoreName:(NSString*)storeName {
    
    NSURL *libraryPathURL = [self libraryPathURL];
    storeName = [[storeName stringByDeletingPathExtension]stringByAppendingPathExtension:@"sql"];
    NSURL *url = [NSURL URLWithString:storeName relativeToURL:libraryPathURL];
    return url;
}


- (NSURL *)libraryPathURL {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return [NSURL fileURLWithPath:libraryDirectory isDirectory:YES];
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithModel:(NSManagedObjectModel*)model type:(NSString*)storeType storeURL:(NSURL*)url options:(NSDictionary *)options {
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:url options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

#pragma mark - background moc

- (NSManagedObjectContext *)backgroundManagedObjectContext {
    
    if ( !_backgroundManagedObjectContext ) {
        
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        _backgroundManagedObjectContext.parentContext = self.managedObjectContext;
    }
    
    return _backgroundManagedObjectContext;
    
}


- (NSManagedObjectContext *)newManagedObjectContextWithParent:(NSManagedObjectContext *)parentContext concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    
    NSManagedObjectContext *aBackgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    
    aBackgroundManagedObjectContext.persistentStoreCoordinator = parentContext.persistentStoreCoordinator;
    
    return aBackgroundManagedObjectContext;
}


#pragma mark - Managed Object Context Merging

- (void)registerForBackgroundManagedObjectContextDidSaveNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundManagedObjectContextDidSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.backgroundManagedObjectContext];
}


- (void)unregisterForManagedObjectContextDidSaveNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)backgroundManagedObjectContextDidSaveNotification:(NSNotification *)notification {
    
    [self.managedObjectContext performBlockAndWait:^{
        
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        
        [self.managedObjectContext save:nil];
    }];
    
}


#pragma mark - save

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext {
    
    [managedObjectContext save:nil];
}


@end
