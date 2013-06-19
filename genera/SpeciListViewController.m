//
//  SpeciListViewController.m
//  genera
//
//  Created by Simon Sherrin on 9/01/12.
/* Copyright (c) 2012 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
//

#import "SpeciListViewController.h"
#import "DetailViewController.h"
#import "Group.h"
#import "DataFetcher.h"
#import "Speci.h"
#import "iPhoneDetailViewController.h"

@implementation SpeciListViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize selectedGroup = __selectedGroup;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    tableView.rowHeight = 75;
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // cell.textLabel.text = [[managedObject valueForKey:@"timeStamp"] description];
    
	Speci *managedSpeci = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell textLabel].text = [managedSpeci label];
    [cell textLabel].font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    [cell textLabel].textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [cell detailTextLabel].text = [managedSpeci sublabel];
    if ([managedSpeci.labelStyle isEqualToString:@"italic"]) {
        [cell textLabel].font = [UIFont fontWithName:@"Helvetica-Oblique" size:16];
    }
    NSLog(@"SubLabelStyle:%@",managedSpeci.sublabelStyle);
    if ([managedSpeci.sublabelStyle isEqualToString:@"italic"]) {
        NSLog(@"italicSection");
    	[cell detailTextLabel].font = [UIFont fontWithName:@"Helvetica-Oblique" size:14];
		[cell detailTextLabel].textColor = [UIColor colorWithRed:0.258 green:.258 blue:.258 alpha:1];	
    } else
    {
        [cell detailTextLabel].font = [UIFont fontWithName:@"Helvetica" size:14];
        [cell detailTextLabel].textColor = [UIColor colorWithRed:0.258 green:.258 blue:.258 alpha:1];	
    }
    
	NSString *path = [[NSBundle mainBundle] pathForResource:[managedSpeci.squareThumbnail stringByDeletingPathExtension] ofType:@"jpg"];
	
	UIImage *theImage;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		theImage = [UIImage imageWithContentsOfFile:path];
        
	} else {
		theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
	}

	
	cell.imageView.image = theImage;   
    
}

- (NSString *) tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)section {
    
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        iPhoneDetailViewController *searchiPhoneDetailViewController = [[iPhoneDetailViewController alloc] initWithNibName:@"iPhoneDetailViewController" bundle:nil];
         Speci *selectedSpeci = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        searchiPhoneDetailViewController.detailSpeci = selectedSpeci;    
        searchiPhoneDetailViewController.title = selectedSpeci.label;
        [self.navigationController pushViewController:searchiPhoneDetailViewController animated:YES];
        [searchiPhoneDetailViewController release];
        
    } else {
        Speci *selectedSpeci = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailSpeci = selectedSpeci;
    }
}

#pragma mark - FetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Speci" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortGroupDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"subgroup" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortGroupDescriptor, sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];    
    
    //Set up predicate
    NSString *searchTerm = [NSString stringWithFormat:@"group.label ='%@'",__selectedGroup.label];
    NSLog(@"Seleced Group %@", __selectedGroup.label);
	NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchTerm];
    
    [fetchRequest setPredicate:searchPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext  sectionNameKeyPath:@"subgroup" cacheName:[NSString stringWithFormat:@"Speci%@",__selectedGroup.label]] autorelease];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}  

-(void) dealloc{
    
    [_detailViewController release];
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [super dealloc];
    
}

@end
