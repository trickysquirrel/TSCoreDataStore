//
//  Created by Richard Moult on 12/12/2014.
//  Copyright (c) 2014 TrickySquirrel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>




@interface TSCoreDataStore : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectContext *backgroundManagedObjectContext;

- (id)initInMemoryStoreWithModelName:(NSString *)modelName;

- (id)initPersistentStoreWithModelName:(NSString *)modelName;

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext;
    
@end
