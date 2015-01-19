//
//  TableViewController.m
//  TSCoreDataStore
//
//  Created by Richard Moult on 12/12/2014.
//  Copyright (c) 2014 TrickySquirrel. All rights reserved.
//

#import "TableViewController.h"
#import "TSCoreDataStore.h"
#import "NSManagedObject+JsonParser.h"
#import "Entity.h"


@interface TableViewController() <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) TSCoreDataStore *dataStore;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end


@implementation TableViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.dataStore = [[TSCoreDataStore alloc] initInMemoryStoreWithModelName:@"TSCoreDataStore"];
    
    [self addEntitiesToDataBase];

    self.tableView.dataSource = self;
    
    self.fetchedResultsController = [self fetchedResultsControllerForAllEntities];
    
    [self.fetchedResultsController performFetch:nil];
    
    [self.tableView reloadData];
}


#pragma mark - set data


- (void)addEntitiesToDataBase {
    
    __weak typeof(self) weakSelf = self;
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [queue addOperationWithBlock:^{
        
        NSManagedObjectContext *context = self.dataStore.backgroundManagedObjectContext;
        
        NSArray *list = [self jsonFromResource:@"data.json"];
        
        [weakSelf writeObjectsToDB:list withContext:context];
        
        [weakSelf.dataStore saveContext:context];
    }];
}


- (void)writeObjectsToDB:(NSArray *)objects withContext:(NSManagedObjectContext *)context {
    
    for (NSDictionary *dictionary in objects) {
        
        Entity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:context];
        
        BOOL success = [entity populateFromDictionary:dictionary error:nil];
        
        if (!success) {
            [context deleteObject:entity];
        }
    }
}


- (id)jsonFromResource:(NSString *)resource {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:nil];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}


#pragma mark - table data source 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCellIdentifier" forIndexPath:indexPath];
    
    Entity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = entity.title;
    
    return cell;
}


#pragma mark - fetched results controller 

- (NSFetchedResultsController *)fetchedResultsControllerForAllEntities {
    
    NSManagedObjectContext *context = self.dataStore.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    
    return aFetchedResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView reloadData];
}

@end
