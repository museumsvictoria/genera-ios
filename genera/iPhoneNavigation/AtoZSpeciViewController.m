//
//  AtoZSpeciViewController.m
//  genera
//
//  Created by Simon Sherrin on 15/01/12.
/* Copyright (c) 2012 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
//

#import "AtoZSpeciViewController.h"
#import "Speci.h"
#import "DetailViewController.h"
#import "iPhoneDetailViewController.h"
#import "DataFetcher.h"

@implementation AtoZSpeciViewController
@synthesize speciArray, rightViewReference;

@synthesize	sectionsArray, collation;
#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.speciArray = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Speci" withPredicate:nil];	
    
	[self configureSections];
    
}


- (void)configureSections {
	
	// Get the current collation and keep a reference to it.
	self.collation = [UILocalizedIndexedCollation currentCollation];
	
	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	
	// Set up the sections array: elements are mutable arrays 
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
		[array release];
	}
	
	// Segregate the time zones into the appropriate arrays.
	for (Speci *speci in speciArray) {
		
		// Ask the collation which section number the speci.
		NSInteger sectionNumber = [collation sectionForObject:speci collationStringSelector:@selector(label)];
		
		// Get the array for the section.
		NSMutableArray *sectionSpeci = [newSectionsArray objectAtIndex:sectionNumber];
		
		//  Add the time zone to the section.
		[sectionSpeci addObject:speci];
	}
	
	// Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {
		
		NSMutableArray *speciArrayForSection = [newSectionsArray objectAtIndex:index];
		
		// If the table view or its contents were editable, you would make a mutable copy here.
		NSArray *sortedSpeciArrayForSection = [collation sortedArrayFromArray:speciArrayForSection collationStringSelector:@selector(label)];
		
		// Replace the existing array with the sorted array.
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedSpeciArrayForSection];
	}
	
	self.sectionsArray = newSectionsArray;
	[newSectionsArray release];	
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *objectsInSection = [sectionsArray objectAtIndex:section];
	
    
    if([objectsInSection count] == 0){
        return 0.0;}
    else
    {
        return 22.0;
    }
    
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.navigationController.navigationBar.translucent	= NO;
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	tableView.rowHeight = 75;
    //return 1;
	return [[collation sectionTitles] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //   return [animalArray count];
	NSArray *animalsInSection = [sectionsArray objectAtIndex:section];
	
    return [animalsInSection count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	NSLog(@"Search Results in Cell: %d", [self.speciArray count]);
    
    // Configure the cell...
	NSArray *speciInSection = [sectionsArray objectAtIndex:indexPath.section];
    
    Speci *managedSpeci = (Speci *)[speciInSection objectAtIndex:indexPath.row] ;
    
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
	
    
    return cell;
}


//Indexing section of TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[collation sectionTitles] objectAtIndex:section];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [collation sectionIndexTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [collation sectionForSectionIndexTitleAtIndex:index];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    
	NSArray *speciInSection = [sectionsArray objectAtIndex:indexPath.section];
	
	// Configure the cell with the time zone's name.
	Speci *tmpSpeci = (Speci *)[speciInSection objectAtIndex:indexPath.row];
	
    //Handler has been built to deal with being used in iPad or iPhone. Currently only used on iPhone.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		
	{
		
		rightViewReference.detailSpeci = tmpSpeci;
		
	}	else{
		
		//New iPhone View
		iPhoneDetailViewController *detailViewController = [[iPhoneDetailViewController alloc] initWithNibName:@"iPhoneDetailViewController" bundle:nil];
		detailViewController.detailSpeci = tmpSpeci;
		detailViewController.title = tmpSpeci.label;
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
	}
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[speciArray release];
	[rightViewReference release];
	[sectionsArray release];
	[collation release];
    [super dealloc];
}


@end
