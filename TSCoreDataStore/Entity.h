//
//  Entity.h
//  TSCoreDataStore
//
//  Created by Richard Moult on 12/12/2014.
//  Copyright (c) 2014 TrickySquirrel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * number;

@end
