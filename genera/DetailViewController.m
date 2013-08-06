//
//  DetailViewController.m
//  genera
//
//  Created by Simon Sherrin on 3/01/12.
/* Copyright (c) 2012 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
//

#import "DetailViewController.h"
#import "VariableStore.h"
#import "MVPagingScollView.h"
#import "Speci.h"
#import "Group.h"
#import "Template.h"
#import "AudioListViewController.h"
#import "CustomSearchViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize titleBarLabel = _titleBarLabel;
@synthesize detailsWebView = _detailsWebView;
@synthesize audioPopoverButton = _audioPopoverButton;
@synthesize searchPopoverButton = _searchPopoverButton;
@synthesize aboutPopoverButton = _aboutPopoverButton;
@synthesize imageTextLayoutControl = _imageTextLayoutControl;
@synthesize imageView = _imageView;
@synthesize detailView = _detailView;
@synthesize aboutView = _aboutView;
@synthesize welcomeView = _welcomeView;
@synthesize startButtonView = _startButtonView;

@synthesize detailToolbar = _detailToolbar;
@synthesize imageScrollView = _imageScrollView;
@synthesize detailSpeci = _detailSpeci;
@synthesize currentGroupLabel = _currentGroupLabel;

//startup properties

@synthesize activityIndicator= _activityIndicator;
@synthesize progressLabel = _progressLabel;
@synthesize progressView = _progressView;
@synthesize orientationLock = _orientationLock;


- (void)setDetailSpeci:(Speci *)detailSpeci{
   
        NSLog(@"Set Animal");
		//startScreen.hidden = YES;	
        _aboutView.hidden = YES;
       _welcomeView.hidden =YES;
   //     webBackImage.hidden = YES;
        _startButtonView.hidden = YES; //remove tap to begin gesture recogniser
        
        if (_detailSpeci != detailSpeci) {
            [_detailSpeci release];
            _detailSpeci = [detailSpeci retain];
            // Update the view.
            [self configureView];
        }
        
        [self dismissAllPopovers];
    }
    
    -(void) dismissAllPopovers{
       if (self.masterPopoverController != nil) {
            [self.masterPopoverController dismissPopoverAnimated:YES];
        }		
       if (_audioPopoverController !=nil) {
            [_audioPopoverController dismissPopoverAnimated:YES];
        }
        if (_searchPopoverController !=nil) {
            //Hide search popover
            [_searchPopoverController dismissPopoverAnimated:YES];
        }
       
    }
    



- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item


- (void)configureView
{
    // Update the user interface for the detail item.

    // Update the user interface for the detail item.
	//startButton.hidden = YES;
    _detailToolbar.tintColor = [VariableStore sharedInstance].toolbarTint;
	_titleBarLabel.text = _detailSpeci.label;
	
	//if portrait mode and first button is popover && _detailSpeci is not null....
    if (_detailSpeci != NULL){
        if (self.interfaceOrientation== UIInterfaceOrientationPortraitUpsideDown || self.interfaceOrientation == UIInterfaceOrientationPortrait)  {
		
            UIBarButtonItem *barButtonItem = [[_detailToolbar items] objectAtIndex:0];
            if ([_detailSpeci.group.label length] >13) {
                _currentGroupLabel = [_detailSpeci.group.label stringByReplacingCharactersInRange:NSMakeRange(10, [_detailSpeci.group.label length]-10) withString:@"..."];
            }else{
			
                _currentGroupLabel  = _detailSpeci.group.label;
            }
        
        barButtonItem.title = _currentGroupLabel;
        }
    }

	
	
	//Set Up images controller
	
	//self.animalImages = [animal sortedImages];
	//imagePagingControl.numberOfPages = [animalImages count];
	//imagePagingControl.currentPage = 0;
    
	NSLog(@"Before Image Controller Init");
    NSArray *tmpImageArray = [_detailSpeci sortedImages];
	[_imageScrollView newImageSet:tmpImageArray];
	
	//Set Image Credit to First Page - don't think this is needed
	//imageCredit.text = [NSString stringWithFormat:NSLocalizedString(@"Credit: %@",nil), [(Image *)[animalImages objectAtIndex:0] credit]];
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
    //	NSLog([self constructHTML]);
	NSLog(@"Set up Web Details");
	_detailsWebView.opaque = NO;
	_detailsWebView.backgroundColor = [UIColor clearColor];
	NSLog(@"Load HTML into WebView");
	//NSString *baseHTMLCode = @"<html><body style='background-color: transparent; color:white;'><%genus%><%species%><br/>Now there's just a question of freeing the order.</body></html>";
	//Code for checking for design versions
	NSString *htmlPath;
	
    NSLog(@"Template File: %@", _detailSpeci.template.tabletTemplate);
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabletTemplate stringByDeletingPathExtension] ofType:@"html"]]) {
        NSLog(@"Template File Found");
        htmlPath = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabletTemplate stringByDeletingPathExtension] ofType:@"html"];
	}else {
        NSLog(@"Template File Not Found");
		htmlPath = [[NSBundle mainBundle] pathForResource:@"template-ipad" ofType:@"html"];
	}
	
    
	NSMutableString *baseHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath usedEncoding:nil error:NULL];
	

    
    //Replace template fields in HTML with values.

	
    [self htmlTemplate:baseHTMLCode keyString:@"label" replaceWith:_detailSpeci.label];
	[self htmlTemplate:baseHTMLCode keyString:@"sublabel" replaceWith:_detailSpeci.sublabel];
    for (NSString *tmpKey in (NSDictionary *) _detailSpeci.details) {
        [self htmlTemplate:baseHTMLCode keyString:tmpKey replaceWith:[(NSDictionary*)_detailSpeci.details objectForKey:tmpKey]];
        
    }

    
	[_detailsWebView loadHTMLString:baseHTMLCode baseURL:baseURL];
	[baseHTMLCode release];
    
	
	//Enable or disable audio buttons
    
	if ([_detailSpeci.audios count] > 0){
		_audioPopoverButton.enabled = YES;	
		
		_audioPopoverViewController.audioFilesArray = (NSArray *)[_detailSpeci sortedAudio];
	}else {
		_audioPopoverButton.enabled = NO;

	}

    
}

-(void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString{
	
	if (replacementString != nil && [replacementString length] > 0) {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@" " options:0 range:NSMakeRange(0, [templateString length])];
	}else {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:@"" options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@"invisible" options:0 range:NSMakeRange(0, [templateString length])];
        
	}
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Set up start button single approach
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]
											   initWithTarget:self action:@selector(handleSingleTap:)];
    singleFingerTap.numberOfTapsRequired = 1;
   	[_startButtonView addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
	
/*		
	self.animalImageControllers = [[NSMutableArray alloc] init];
 */
	
	_detailToolbar.tintColor  = [VariableStore sharedInstance].toolbarTint;
		
	//Setup Popover
	_audioPopoverViewController = [[AudioListViewController alloc] init];
	_audioPopoverController = [[UIPopoverController alloc] initWithContentViewController:_audioPopoverViewController];
	_audioPopoverController.passthroughViews = [NSArray arrayWithObject:_detailToolbar];
	_searchViewController = [[CustomSearchViewController alloc] init];
	_searchViewController.rightViewReference = self;
	_searchPopoverController = [[UIPopoverController alloc] initWithContentViewController:_searchViewController];
	_searchPopoverController.passthroughViews =[NSArray arrayWithObject:_detailToolbar];
    //set the value for the top of the details screen and detailView to not raised
	detailsTopLeft = 551;
	detailsViewRaised = NO;
    self.currentGroupLabel = NSLocalizedString(@"Catalog", nil);
	//self.startScreen.contentSize = self.startScreen.frame.size;
	
    _aboutView.opaque = NO;
	_aboutView.backgroundColor = [UIColor clearColor];
    
   	NSString *aboutPath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSString *welcomePath = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];
	NSMutableString *aboutHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:aboutPath usedEncoding:nil error:NULL];
  	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];  
    [_aboutView loadHTMLString:aboutHTMLCode	baseURL:baseURL];
    _aboutView.hidden = YES;
	_welcomeView.opaque = NO;
	_welcomeView.backgroundColor = [UIColor clearColor];
    [self showWelcomeView];
	NSMutableString *welcomeHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:welcomePath usedEncoding:nil error:NULL];
	[_welcomeView loadHTMLString:welcomeHTMLCode baseURL:baseURL];

    
    _imageScrollView = [[MVPagingScollView alloc] initWithNibName:@"MVPagingScollView" bundle:nil];
	CGRect imageViewFrame = self.imageView.frame;
    
	NSLog(@"FrameSize:%f,%f", imageViewFrame.size.width, imageViewFrame.size.height);
	NSLog(@"OriginSize:%f,%f", imageViewFrame.origin.x, imageViewFrame.origin.y);
	imageViewFrame.origin.x = 0;
	imageViewFrame.origin.y = 0;
	_imageScrollView.view.frame = imageViewFrame;
	_imageScrollView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.imageView addSubview:_imageScrollView.view];
	[aboutHTMLCode release]; //added 26/02/2011
	[welcomeHTMLCode release]; // added 26/02/2011
   
    
    [self configureView];
}

-(void) setSpeci:(Speci*)newSpeci{
    //startScreen.hidden = YES;	
/*	aboutHTML.hidden = YES;
	welcomeHTML.hidden =YES;
	webBackImage.hidden = YES;
	startButton.hidden = YES; //remove tap to begin gesture recogniser
*/	
	if (_detailSpeci != newSpeci) {
		[_detailSpeci release];
		_detailSpeci = [newSpeci retain];
        // Update the view.
        [self configureView];
	}
    
//	[self dismissAllPopovers];  

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
#pragma mark - Rotation section

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	NSLog(@"Animal Detail: didRotateFromInterface");
    
    [_detailsWebView reload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

	[_imageScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	//[animalHTMLDetails reload];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
	//CGRect tmpStartContents = self.startScreen.frame;
	//tmpStartContents.size.height = 960;
	//self.startScreen.contentSize = tmpStartContents.size;
    
	
	//Resize Interface Layout
	CGRect currentDetailsRect = _detailView.frame;
	CGRect currentImageRect = _imageView.frame;
	CGRect currentParentViewRect = self.view.frame;
	
	if (_imageTextLayoutControl.selectedSegmentIndex == 0) {
		currentDetailsRect.origin.y = 44;
		currentDetailsRect.size.height = currentParentViewRect.size.height - 44;
        
	}else {
		if (_imageTextLayoutControl.selectedSegmentIndex==1) {
			currentDetailsRect.origin.y = detailsTopLeft;
			currentDetailsRect.size.height = currentParentViewRect.size.height - detailsTopLeft;
			currentImageRect.size.height = detailsTopLeft - 44;
		}else {
			currentDetailsRect.origin.y = currentParentViewRect.size.height;
			currentImageRect.size.height = currentParentViewRect.size.height-44;
			currentParentViewRect.origin.x =0;
		}
		
	}
	_detailView.frame = currentDetailsRect;
	_imageView.frame = currentImageRect;
	self.view.frame = currentParentViewRect;
	[_imageScrollView willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    
	
}

- (void)changeDetailsView:(id)sender{
    
    //Can Change Position
    CGRect currentDetailsRect = _detailView.frame;
    CGRect currentImageRect = _imageView.frame;
    CGRect currentParentViewRect = self.view.frame;
    
    if (_imageTextLayoutControl.selectedSegmentIndex == 0) {
        currentDetailsRect.origin.y = 44;
        currentDetailsRect.size.height = currentParentViewRect.size.height - 44;
        
    }else {
        if (_imageTextLayoutControl.selectedSegmentIndex==1) {
            currentDetailsRect.origin.y = detailsTopLeft;
            currentDetailsRect.size.height = currentParentViewRect.size.height - detailsTopLeft;
            currentImageRect.size.height = detailsTopLeft - 44;
        }else {
            currentDetailsRect.origin.y = currentParentViewRect.size.height;
            currentImageRect.size.height = currentParentViewRect.size.height-44;
            
        }
        
    }
    
    
    [UIView animateWithDuration:0.1 animations:^{
		_detailView.frame = currentDetailsRect;
        _imageView.frame = currentImageRect;
        self.view.frame = currentParentViewRect;
        
    }];
    
    NSLog(@"New origin: %f", currentDetailsRect.origin.y);
    
	
}

-(void)layoutControlChanged:(id)sender{
    
	[self dismissAllPopovers];
	UISegmentedControl *layoutControl = (UISegmentedControl *)sender;
	CGRect currentDetailsRect = _detailView.frame;
	CGRect currentParentViewRect = self.view.bounds;
	CGRect currentImageRect = _imageView.frame;
	CGRect currentParentFrame = self.view.frame;
	BOOL imageViewWidthChanged;
	
	if (layoutControl.selectedSegmentIndex == 0) {
		//Full Text Display
		currentDetailsRect.origin.y = 44;
		currentDetailsRect.size.height = currentParentViewRect.size.height - 44;
        
	}else {
		if (layoutControl.selectedSegmentIndex == 1) {
			//standard layout
			currentDetailsRect.origin.y = detailsTopLeft;
			currentDetailsRect.size.height = currentParentViewRect.size.height - detailsTopLeft;
			currentImageRect.size.height = detailsTopLeft - 44;
            
		} else {
			//selected segment = 2
			NSLog(@"Full Screen");
			currentDetailsRect.origin.y = currentParentViewRect.size.height;
			currentImageRect.size.height = currentParentViewRect.size.height-44	;	
            
            
			//UISplitViewCode
			if (self.interfaceOrientation== UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)  {
                
				imageViewWidthChanged = YES;
			}
		}
        
	}
	[UIView animateWithDuration:1.0 animations:^{
        
		_detailView.frame = currentDetailsRect;
		_imageView.frame = currentImageRect;
		self.view.frame = currentParentFrame;	
	}];
	
	[_imageScrollView refreshLayout];
	
    
}
#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

#pragma mark - start button
//Start button is only for start up. If the user touches anywhere on the "Welcome Screen" the Group list is presented

-(void) handleSingleTap:(UIGestureRecognizer *)sender{
	_startButtonView.hidden = YES;
	[_startButtonView removeGestureRecognizer:sender];
	[self touchToBegin:sender];
	
	
}

- (void) touchToBegin:(id)sender{
    
	_startButtonView.hidden = YES;
	UIBarButtonItem *tmpCast = (UIBarButtonItem *) [[_detailToolbar items] objectAtIndex:0];
	[self.masterPopoverController presentPopoverFromBarButtonItem:tmpCast permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];	
}

#pragma mark - About Views

- (void) toggleAboutView:(id)sender{
    _startButtonView.hidden = YES;
    if (_aboutView.hidden) {
        //show about View
        _aboutView.hidden = NO;
        _detailDescriptionLabel.text = NSLocalizedString(@"About", @"About");
        _welcomeView.hidden = YES;
        
    }else
    {
        //hide about View - if there's no detailed item selected, show welcome screen again
        if (_detailSpeci != nil) {
            _detailDescriptionLabel.text = _detailSpeci.label;
            _welcomeView.hidden = YES;
        }else
        {
            [self showWelcomeView];
            
        }
        _aboutView.hidden = YES;
    }
    
    
}

- (void) showWelcomeView{
    _welcomeView.hidden = NO;
    _detailDescriptionLabel.text = NSLocalizedString(@"Welcome", @"Welcome");
}

#pragma mark - Setup

-(void) makeToolbarButtonsInactive{
	for (id toolbarItem in [self.detailToolbar items]) {
		if ([toolbarItem respondsToSelector:@selector(enabled)]) {
			
			UIBarButtonItem *tempButton = (UIBarButtonItem *)toolbarItem;
			tempButton.enabled = NO;
		}
	}
   
    
    
}

-(void) makeToolbarButtonsActive{
	for (id toolbarItem in [self.detailToolbar items]) {
		if ([toolbarItem respondsToSelector:@selector(enabled)]) {
			
			UIBarButtonItem *tempButton = (UIBarButtonItem *)toolbarItem;
			tempButton.enabled = YES;
		}
	}
    self.audioPopoverButton.enabled = NO;
}

-(void) hideProgress{
    
	_progressLabel.hidden = YES;
	self.detailToolbar.userInteractionEnabled = YES;
	_progressView.hidden = YES;
}



-(void) updateProgressBar:(float)loadprogress{
	_progressView.progress = loadprogress;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
   /* barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
        self.masterPopoverController = popoverController;
    	NSLog(@"CurrentGroupLabel:%@", _currentGroupLabel);*/
   self.masterPopoverController = popoverController;
    /*
    if ([_detailSpeci.group.label length] >13) {
		barButtonItem.title = [_detailSpeci.group.label stringByReplacingCharactersInRange:NSMakeRange(10, [_detailSpeci.group.label length]-10) withString:@"..."];
	}else{
		
		barButtonItem.title = _detailSpeci.group.label;
	}*/
    barButtonItem.title = _currentGroupLabel;
	NSLog(@"CurrentGroupLabel:%@", _currentGroupLabel);
    NSMutableArray *items = [[_detailToolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [_detailToolbar setItems:items animated:YES];
    [items release];
   
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    /*[self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;*/
    //Get the button items, left most one will be navigation button
    NSMutableArray *items = [[_detailToolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [_detailToolbar setItems:items animated:YES];
    [items release];
    self.masterPopoverController = nil;
    
    
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation

{
  // 30/07/2013 Changed the default behavior to always hide view controller.
    //
  //  if (UIInterfaceOrientationIsLandscape(orientation)) {
  //      return NO;
 //   }else{
        
        return YES;
 //   }
    
}

#pragma mark Audio


- (void) showAudio:(id)sender{
/*	if (searchPopoverController !=nil) {
		//Hide search popover
		[searchPopoverController dismissPopoverAnimated:YES];
	}
*/
    if (self.masterPopoverController !=nil) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
	UIBarButtonItem *tmpCast = (UIBarButtonItem *)sender;
	[_audioPopoverController setPopoverContentSize:[_audioPopoverViewController contentSizeForViewInPopover]];
    
	[_audioPopoverController presentPopoverFromBarButtonItem:tmpCast permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


#pragma mark Search Popover

- (void) showSearch:(id)sender{
	
	if (_audioPopoverController !=nil) {
		//Hide audio popover
		[_audioPopoverController dismissPopoverAnimated:YES];
	}
	if (self.masterPopoverController !=nil) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
	UIBarButtonItem *tmpCast = (UIBarButtonItem *)sender;
	[_searchPopoverController presentPopoverFromBarButtonItem:tmpCast permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	
}

@end
