//
//  AppDelegate.m
//  genera
//
//  Created by Simon Sherrin on 3/01/12.
/* Copyright (c) 2012 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "DataFetcher.h"
#import "DataVersion.h"
#import "Audio.h"
#import "Template.h"
#import "TemplateTab.h"
#import "Image.h"
#import "Speci.h"
#import "Group.h"
#import "VariableStore.h"
#import "iPhoneInitialLoadView.h"
#import "CustomSearchViewController.h"
#import "AtoZSpeciViewController.h"
#import "iphoneAboutViewController.h"

NSString * const DidRefreshDatabaseNotificationName = @"FieldGuideDidRefreshDatabase";

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [_splitViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadSettings];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    //Database Check/Build
    BOOL buildingDatabase = NO;
	// If the database or Set up database file from animalData.plist
	//Database setup occurs on a separate thread, buildingDatabase is used to prevent userinput and orientation changes in the iPad Version
	//while the database is building
	if (![[DataFetcher sharedInstance] databaseExists]||!isDatabaseComplete) {
		[self setupDatabase];
		buildingDatabase = YES;
	}
    else
    { //check if stored version number is the same as the current, if not, refresh database
        NSArray *currentVersionArray = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"DataVersion" withPredicate:nil];
        if ([currentVersionArray count] > 0) {
            
            DataVersion *currentDataVersion = [currentVersionArray objectAtIndex:0];
            if (![currentDataVersion.versionID isEqualToString:[VariableStore sharedInstance].currentDataVersion]) {
                NSLog(@"The database is being refreshed as the stored versionID is different to the CustomSettingsID");
                NSLog(@"Stored data version: %@", currentDataVersion.versionID);
                NSLog(@"CustomSetting data version: %@", [VariableStore sharedInstance].currentDataVersion);
                buildingDatabase = YES;
                [self refreshDatabase];
            }
            
        }
        else //we don't have a version in the database, refersh
        {
            NSLog(@"The data base is being refreshed as there is no versionID");
            buildingDatabase = YES;
            [self refreshDatabase];
            
        }
        
    }
    
	NSLog(@"Passed Database Build");
    
    //Check Count
  //  NSArray *currentGroupCount = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Group" withPredicate:nil];
  //  NSLog(@"Count of Groups past build:%d", [currentGroupCount count]);
    
    //UI Setup
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
       
        
     /*   MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        self.window.rootViewController = self.navigationController;
        masterViewController.managedObjectContext = self.managedObjectContext;
       */
        if (buildingDatabase) {
            //display the wait screen
            //initiPhoneLayout gets called when the database build is complete in
			iPhoneLoaderView = [[iPhoneInitialLoadView alloc] initWithNibName:@"iPhoneInitialLoadView" bundle:nil];
			//[_window addSubview:iPhoneLoaderView.view];
            [_window setRootViewController:iPhoneLoaderView];
		}else{
			[self initiPhoneLayout];
		}
        
        
    } else {
        MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil] autorelease];
        
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        
        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil] autorelease];
    	
        self.splitViewController = [[[UISplitViewController alloc] init] autorelease];

       // self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailViewController, nil];
        self.splitViewController.delegate = detailViewController;      
        self.window.rootViewController = self.splitViewController;
        masterViewController.detailViewController = detailViewController;
        masterViewController.managedObjectContext = self.managedObjectContext;
      
        if (buildingDatabase) {
            //Disable everything to prevent oddities
			masterViewController.detailViewController.detailToolbar.userInteractionEnabled = NO;
			masterViewController.detailViewController.progressLabel.hidden = NO;
			masterViewController.detailViewController.progressView.hidden = NO;
			masterViewController.detailViewController.orientationLock = YES;
			[masterViewController.detailViewController.activityIndicator startAnimating];
		}
		else {
			masterViewController.detailViewController.orientationLock = NO;
		}

        
    }
    [self.window makeKeyAndVisible];
    return YES;
}

-(void) initiPhoneLayout{
	tabBarController = [[UITabBarController alloc] init];  
    MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil] autorelease];
    masterViewController.managedObjectContext = self.managedObjectContext;
	masterViewController.title = NSLocalizedString(@"Objects by Group",nil);
    UINavigationController *groupNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController] ;
	groupNavigationController.navigationBar.tintColor = [VariableStore sharedInstance].toolbarTint;

	
	iphoneAboutViewController *aboutVC = [[iphoneAboutViewController alloc] initWithNibName:@"iphoneAboutViewController" bundle:nil];
	
	CustomSearchViewController *customSearchViewController = [[CustomSearchViewController alloc] initWithNibName:@"CustomSearchViewController" bundle:nil];
	UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:customSearchViewController];
    
	searchNavController.navigationBar.tintColor = [VariableStore sharedInstance].toolbarTint;
	customSearchViewController.title =  NSLocalizedString(@"Search",nil);
	searchNavController.title = NSLocalizedString(@"Search",nil);
	aboutVC.title = NSLocalizedString(@"About",nil);
	AtoZSpeciViewController *aToZViewController = [[AtoZSpeciViewController alloc] initWithNibName:@"AtoZSpeciViewController" bundle:nil];
	UINavigationController *aToZNavController = [[UINavigationController alloc] initWithRootViewController:aToZViewController];
	aToZNavController.navigationBar.tintColor = [VariableStore sharedInstance].toolbarTint;
	aToZNavController.title = NSLocalizedString(@"A - Z",nil);
	aToZViewController.title = NSLocalizedString(@"Alphabetical",nil);
	aToZNavController.tabBarItem.image = [UIImage imageNamed:@"tabBar1_alphabetical.png"];
	self.navigationController.tabBarItem.image = [UIImage imageNamed:@"tabBar1_categories.png"];
	searchNavController.tabBarItem.image = [UIImage imageNamed:@"tabBar1_search.png"];
	aboutVC.tabBarItem.image = [UIImage imageNamed:@"tabBar1_about.png"];
	
	NSArray *tabBarVCArray = [NSArray arrayWithObjects:groupNavigationController,aToZNavController,searchNavController,aboutVC, nil];
	tabBarController.viewControllers = tabBarVCArray;
	NSLog(@"In Tab View Controller");
	//[_window addSubview:tabBarController.view];
    [_window setRootViewController:tabBarController];
	[aboutVC release];
	[customSearchViewController release];
	[searchNavController release];
	[aToZViewController release];
	[aToZNavController release];
//    [masterViewController release];
    //	[groupNavigationController release];
	
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Database Setup/Refresh 
-(void) setupDatabase{
	if ([NSThread currentThread] == [NSThread mainThread]) //If called from the main thread rather than background thread
	{
		[self performSelectorInBackground:@selector(setupDatabase) withObject: nil];
		return;
	}
	
	//Setup pool
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
 	NSUInteger totalNumberOfRecords;
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];

	int currentRecord = 1;
	NSLog(@"No Database Found");
	NSManagedObjectContext *backgroundContext = [[[NSManagedObjectContext alloc] init] autorelease];
    
    backgroundContext.persistentStoreCoordinator = [[DataFetcher sharedInstance] persistentStoreCoordinator];
    
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *commonArrayPath;
	if ((commonArrayPath =[thisBundle pathForResource:@"generaData" ofType:@"plist"])) {
		//NSArray *loadValues = [[NSArray alloc] initWithContentsOfFile:commonArrayPath];
		NSDictionary *loadValues = [NSDictionary dictionaryWithContentsOfFile:commonArrayPath];
        
		if ([loadValues count] > 0) {
            //Update Version Data
            //Note that if the value for currentAnimalData in CustomSettings.plist is different to the versionID 
            //in animalData, the database will be reloaded everytime the user starts the application. 
            //May make the versionID in animalData purely for human reference.
            NSString *loadingVersionID = [loadValues objectForKey:@"versionID"];
            DataVersion *loadingDataVersion = [NSEntityDescription insertNewObjectForEntityForName:@"DataVersion" inManagedObjectContext:backgroundContext];
            loadingDataVersion.versionID = loadingVersionID;
    
            //Create Default Template
            Template *defaultTemplate = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:backgroundContext];
            defaultTemplate.templateName = @"default";
            defaultTemplate.tabletTemplate = @"iPadTemplate.html";     
            
            TemplateTab *imageTab =  [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:backgroundContext]; 
            imageTab.tabName = @"images";
            imageTab.tabLabel= @"Images";
            imageTab.tabIcon=@"images.png";
          //  [imageTab addFirstTabsObject:defaultTemplate];
            defaultTemplate.tabOne =imageTab;
            TemplateTab *audioTab =  [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:backgroundContext];   
            audioTab.tabIcon = @"audio.png";
            audioTab.tabLabel = @"Audio";
            audioTab.tabName = @"audio";
            defaultTemplate.tabTwo = audioTab;
          //  [audioTab addSecondTabsObject:defaultTemplate];
      /*      TemplateTab *detailsTab =  [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:currentContext]; 
            detailsTab.tabIcon = @"details.png";
            detailsTab.tabLabel = @"Details";
            detailsTab.tabName = @"details";
            defaultTemplate.tabThree = detailsTab;
         //   [detailsTab addThirdTabsObject:defaultTemplate];
 
        */    
            
            //Create Group
            NSArray *groupArray = [loadValues objectForKey:@"groupList"];
            for (NSDictionary *tmpGroup in groupArray) {
				
				Group *testGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:backgroundContext];
				
				testGroup.label = [tmpGroup objectForKey:@"label"];
				testGroup.standardImage = [tmpGroup objectForKey:@"standardImage"];
				testGroup.highlightedImage = [tmpGroup objectForKey:@"highlightedImage"];
                testGroup.order = [f numberFromString:[tmpGroup objectForKey:@"order"]];
				//NSLog(@"Group Name Set");
                
				
			}
            
            NSArray *currentGroupCount = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Group" withPredicate:nil];
            NSLog(@"Count of Groups:%d", [currentGroupCount count]);
            
            //load Templates
            
            NSArray *templateArray = [loadValues objectForKey:@"templateList"];
            for (NSDictionary *tmpTemplate in templateArray){
                Template *newTemplate = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:backgroundContext];
                newTemplate.templateName = [tmpTemplate objectForKey:@"templateName"];
                newTemplate.tabletTemplate = [tmpTemplate objectForKey:@"tabletTemplate"];     
                
                NSArray *mobileTabArray = [tmpTemplate objectForKey:@"mobileTabs"];
                int tabCounter = 0;
                for (NSDictionary *tmpTemplateTab in mobileTabArray) {
                    tabCounter ++;
                    TemplateTab *newTemplateTab;
                    NSString *tabName = [tmpTemplateTab objectForKey:@"tabName"];
                    
                   // if (tabName!=@"audio"&&tabName!=@"details"&&tabName!=@"images") {
                    if (![tabName isEqual:@"audio"]&& ![tabName isEqual:@"images"]) {
                        newTemplateTab =  [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:backgroundContext]; 
                        newTemplateTab.tabName = tabName;
                        newTemplateTab.tabLabel= [tmpTemplateTab objectForKey:@"tabLabel"];
                        newTemplateTab.tabIcon=   [tmpTemplateTab objectForKey:@"tabIcon"]; 
                        newTemplateTab.tabTemplate = [tmpTemplateTab objectForKey:@"tabTemplate"];
                        
                    }
                    else{ //audio, details and images tab definitions already exist
                            if ([tabName isEqual: @"audio"]) {
                                newTemplateTab = audioTab;
                            }
                      /*      if (tabName == @"details") {
                                newTemplateTab = detailsTab;
                            } */    
                            if ([tabName isEqual: @"images"]) {
                                newTemplateTab = imageTab;
                            }
                    }
                    //assign to postion
                    switch (tabCounter) {
                        case 1:
                            [newTemplateTab addFirstTabsObject:newTemplate];
                       //     newTemplate.tabOne = newTemplateTab;
                            break;
                        case 2:
                            [newTemplateTab addSecondTabsObject:newTemplate];
                      //      newTemplate.tabTwo = newTemplateTab;
                            break;
                        case 3:
                            [newTemplateTab addThirdTabsObject:newTemplate];
                       //     newTemplate.tabThree = newTemplateTab;
                            break;
                        case 4:
                            [newTemplateTab addFourthTabsObject:newTemplate];
                         //   newTemplate.tabFour = newTemplateTab;
                            break;
                        case 5:
                            [newTemplateTab addFifthTabsObject:newTemplate];
                          //  newTemplate.tabFive = newTemplateTab;
                            break;
                        default:
                            break;
                    }
                    
                    
                    
                }
                       
            }
            
            //load Objects
            NSArray *objectArray = [loadValues objectForKey:@"objectData"];
            totalNumberOfRecords = [objectArray count];
            for (NSDictionary *tmpObjectData in objectArray){
                currentRecord += 1;
				NSLog(@"Before call to Main Thread");
				[self performSelectorOnMainThread:@selector(updateLoadProgress:) withObject:[NSNumber numberWithInt:currentRecord]  waitUntilDone:NO];
				NSLog(@"After Selector");
				Speci *tmpSpeci = [NSEntityDescription insertNewObjectForEntityForName:@"Speci" inManagedObjectContext:backgroundContext];
                tmpSpeci.subgroup = [tmpObjectData objectForKey:@"subgroup"];
                tmpSpeci.identifier = [tmpObjectData objectForKey:@"identifier"];
                tmpSpeci.label = [tmpObjectData objectForKey:@"label"];
                tmpSpeci.labelStyle = [tmpObjectData objectForKey:@"labelStyle"];
                tmpSpeci.sublabel = [tmpObjectData objectForKey:@"sublabel"];
                tmpSpeci.sublabelStyle = [tmpObjectData objectForKey:@"sublabelStyle"];                    
                tmpSpeci.searchText =[tmpObjectData objectForKey:@"searchText"];
                tmpSpeci.squareThumbnail = [tmpObjectData objectForKey:@"squareThumbnail"];
                //cast details as dictionary
                NSDictionary *tmpDetails = [tmpObjectData objectForKey:@"details"];
                tmpSpeci.details = tmpDetails;
                
                //Add object to Group
                NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"label=%@", [tmpObjectData objectForKey:@"group"]];		
				NSArray *currentgroup = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Group" withPredicate:groupPredicate inContext:backgroundContext];
				if ([currentgroup count] > 0) {
					Group *localGroup = [currentgroup objectAtIndex:0];
		            [localGroup addObjectsObject:tmpSpeci];
                } else
                {
                    //TO DO
                    //Object doesn't belong to Group - should raise log
                }
                
                //Template
                NSString *tmpString = [tmpObjectData objectForKey:@"template"];
                if (([tmpString length]==0)||([tmpString isEqualToString:@"default"])) {
                    tmpSpeci.template = defaultTemplate;
                }else
                {
                    //Get and update template
                    NSPredicate *templatePredicate = [NSPredicate predicateWithFormat:@"templateName=%@", tmpString];		
                    NSArray *currentTemplate = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Template" withPredicate:templatePredicate inContext:backgroundContext];
                    if (currentTemplate.count > 0) {
                        Template *objectTemplate = [currentTemplate objectAtIndex:0];
                        tmpSpeci.template = objectTemplate;
                    }
                    
                }
                
                //Images
                NSArray *tmpImageArray = [tmpObjectData objectForKey:@"images"];
				int counter = 0;
				for (NSDictionary *tmpImageData in tmpImageArray){
					counter +=1;
					Image *tmpImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:backgroundContext];
					tmpImage.filename = [tmpImageData objectForKey:@"filename"];
					tmpImage.credit = [tmpImageData objectForKey:@"credit"];
                    tmpImage.imageDescription  = [tmpImageData objectForKey:@"imageDescription"];
					tmpImage.order = [NSNumber numberWithInt:counter];
					[tmpSpeci addImagesObject:tmpImage];
			
					
				}
                //Audio
                NSArray *tmpAudioArray = [tmpObjectData objectForKey:@"audioFiles"];
                counter = 0;
				for (NSDictionary *tmpAudioData in tmpAudioArray) {
                    counter +=1;
					Audio *tmpAudio = [NSEntityDescription insertNewObjectForEntityForName:@"Audio" inManagedObjectContext:backgroundContext];
					tmpAudio.filename = [tmpAudioData objectForKey:@"filename"];
					tmpAudio.credit = [tmpAudioData objectForKey:@"credit"];
                    tmpAudio.audioDescription = [tmpAudioData objectForKey:@"audioDescription"];
                    tmpAudio.order =  [NSNumber numberWithInt:counter];
					[tmpSpeci addAudiosObject:tmpAudio];
				}
                
                
            }
            
            NSLog(@"About to Save");
			NSError *saveError;
            [backgroundContext save:&saveError];
            
        }
    }
    [self performSelectorOnMainThread:@selector(finishedImport) withObject:nil waitUntilDone:NO];
    [pool drain];
    
	[NSNotificationCenter.defaultCenter postNotificationName:DidRefreshDatabaseNotificationName
                                                      object:nil];
}
-(void) refreshDatabase{
    
    //delete everything and start again
    NSManagedObjectContext *currentContext = [[DataFetcher sharedInstance] managedObjectContext];	
    NSArray *allGroups = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Group" withPredicate:nil];
    for (Group *tmpGroup in allGroups){
        [currentContext deleteObject:tmpGroup];
        
    }
    //Cascade delete should have removed all the objects, but just in case there's one outside the group
    NSArray *remainingSpeci = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Speci" withPredicate:nil];
    NSLog(@"Remaining Object Count: %d", [remainingSpeci count]);
    for (Speci *tmpSpeci in remainingSpeci){
        [currentContext deleteObject:tmpSpeci];
    }
    
    
    NSLog(@"About to Save");
    NSError *saveError;
    [currentContext save:&saveError];
    //now reload
    [self setupDatabase];
}

- (BOOL)databaseExists
{
	NSString	*path = [self databasePath];
	BOOL		databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	
	return databaseExists;
}

- (NSString *)databasePath
{ 
	return [[[self applicationDocumentsDirectory] absoluteString] stringByAppendingPathComponent: @"temp.sqlite"];
}


- (void) updateLoadProgress:(id)value{
	NSNumber *currentCount = (NSNumber *) value;
	NSLog(@"Current Count, %d", [currentCount intValue]);
    // TODO: Change 700 to be count of total animal entries in animalData.plist
	float progress = [currentCount floatValue]/700.0f;
	NSLog(@"Progress: %f", progress);
//	[iPhoneLoaderView updateProgressBar:progress];
//	[rightViewReference updateProgressBar:progress];
}

- (void) finishedImport{
	isDatabaseComplete = YES;
	[self saveSettings];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		//ipad
        DetailViewController *iPadDetailVC = (DetailViewController *)[self.splitViewController.viewControllers objectAtIndex:1];
        iPadDetailVC.orientationLock = NO;
        [iPadDetailVC.activityIndicator stopAnimating ];
        [iPadDetailVC makeToolbarButtonsActive];
        [iPadDetailVC hideProgress];
	}else{
		//Need to hide wait screen.
		iPhoneLoaderView.view.hidden = YES;
		[iPhoneLoaderView.view removeFromSuperview];
        [self initiPhoneLayout];
		
	}

    
    
 }
#

#pragma mark - Settings
-(void)loadSettings{
    
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs boolForKey:@"isDatabaseComplete"]) {
		isDatabaseComplete = [prefs boolForKey:@"isDatabaseComplete"];
	}
	
}

-(void)saveSettings{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:isDatabaseComplete forKey:@"isDatabaseComplete"]; //Database has been built after inital opening
	[prefs synchronize];
	
}
#

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"genera" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"genera.sqlite"];
    
    
	NSDictionary *options = @{
                           NSMigratePersistentStoresAutomaticallyOption: @YES,
                           NSInferMappingModelAutomaticallyOption: @YES
                           };
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
