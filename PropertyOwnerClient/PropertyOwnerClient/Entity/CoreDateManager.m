

#import "CoreDateManager.h"

@implementation CoreDateManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Message" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MessageDB.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.??????Documents??????
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//????????????
- (void)insertCoreData:(NSMutableArray*)dataArray
{
    NSManagedObjectContext *context = [self managedObjectContext];

    for (MessageDB *info in dataArray) {
        MessageDB *messagedb = [NSEntityDescription insertNewObjectForEntityForName:TableName inManagedObjectContext:context];
        messagedb.from = [NSString stringWithFormat:@"%@",info.from];
        messagedb.adviceId =[NSString stringWithFormat:@"%@", info.adviceId];
        messagedb.type =[NSString stringWithFormat:@"%@", info.type];
        messagedb.content = [NSString stringWithFormat:@"%@",info.content];
        messagedb.time = [NSString stringWithFormat:@"%@",info.time] ;
        messagedb.status = [NSString stringWithFormat:@"1"];
        NSError *error;
        if(![context save:&error])
        {
            NSLog(@"???????????????%@",[error localizedDescription]);
        }
    }
}

//??????
- (NSMutableArray*)selectData:(int)pageSize andOffset:(int)currentPage
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // ???????????????????????????
    //setFetchLimit
    // ??????????????????
    //setFetchOffset
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

//    [fetchRequest setFetchLimit:pageSize];
//    [fetchRequest setFetchOffset:currentPage];
    
    
//          [fetchRequest setResultType:NSDictionaryResultType];
      NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest .sortDescriptors =[NSArray arrayWithObject:sort];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"limit 0,1"];
//        fetchRequest.predicate = predicate;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
//    NSAttributeDescription* GroupBy = [entity.attributesByName objectForKey:@"type"];
//    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject: GroupBy]];
//    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:@"type"]];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (MessageDB *info in fetchedObjects) {
        NSLog(@"%@",info);
        [resultArray addObject:info];
    }
    return resultArray;
}


-(NSMutableArray *)msgGroupByType{
        NSManagedObjectContext *context = [self managedObjectContext];
    // 0.????????????????????????????????????
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MessageDB.sqlite"];
    
    // 1.???????????????????????????
    self.db = [FMDatabase databaseWithPath:filename];
    NSMutableArray *resultArray = [NSMutableArray array];

    // 2.???????????????
    if ( [self.db open] ) {
        NSLog(@"?????????????????????");
        // 1.????????????
        FMResultSet *rs = [self.db executeQuery:@"select * from ZMESSAGEDB group by ztype ;"];

        // 2.???????????????
                 while (rs.next) {
            MessageDB *msgDB = [NSEntityDescription insertNewObjectForEntityForName:@"MessageDB" inManagedObjectContext:context];
            msgDB.from = [rs stringForColumn:@"zfrom"];
            msgDB.adviceId = [rs stringForColumn:@"zadviceId"];
            msgDB.type =  [rs stringForColumn:@"ztype"];
            msgDB.time = [rs stringForColumn:@"ztime"];
            msgDB.content = [rs stringForColumn:@"zcontent"];
            msgDB.status = [rs stringForColumn:@"zstatus"];
             [resultArray addObject:msgDB];
        }
    }
    return resultArray;
}
//??????
-(void)deleteData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count])
    {
        for (NSManagedObject *obj in datas)
        {
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
}

-(void)deleteByType:(NSString *)type{
        NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TableName];
    // 2. ??????????????????
    request.predicate = [NSPredicate predicateWithFormat:@"type = %@",type];
    
    // 3. ????????????????????????
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    // 4. ????????????
    for (MessageDB *messageDB in result) {
        // ??????????????????
        [context deleteObject:messageDB];
    }
    // 5. ??????_context????????????
    if ([context save:nil]) {
        NSLog(@"????????????");
    } else {
        NSLog(@"????????????");
    }
}

-(void)deleteAll{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TableName];
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    // 4. ????????????
    for (MessageDB *messageDB in result) {
        // ??????????????????
        [context deleteObject:messageDB];
    }
    // 5. ??????_context????????????
    if ([context save:nil]) {
        NSLog(@"????????????");
    } else {
        NSLog(@"????????????");
    }

    
}
- (void)updateMessageByAdviceId:(NSString *)adviceId
{
    NSManagedObjectContext *context = [self managedObjectContext];

    // 1. ?????????????????????
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TableName];
    
    // 2. ??????????????????
    request.predicate = [NSPredicate predicateWithFormat:@"adviceId =%@",adviceId];
    
    // 3. ????????????????????????
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    // 4. ????????????
    for (MessageDB *messageDB in result) {
        NSLog(@"------%@ %@", messageDB.content, messageDB.type);
        
        // ??????
        messageDB.status = @"2";
    }
    
    // ???????????????????????????
    [context save:nil];
}

@end
