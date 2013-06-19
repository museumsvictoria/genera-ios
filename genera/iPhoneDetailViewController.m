//
//  iPhoneDetailViewController.m
//  genera
//
//  Created by Simon Sherrin on 16/01/12.
/* Copyright (c) 2012 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
//

#import "iPhoneDetailViewController.h"
#import "AudioListViewController.h"
#import "MVPagingScollView.h"
#import "Speci.h"
#import "Template.h"
#import "TemplateTab.h"

@implementation iPhoneDetailViewController

@synthesize detailSpeci = _detailSpeci;
@synthesize detailTab1 = _detailTab1;
@synthesize detailTab2 = _detailTab2;
@synthesize detailTab3 = _detailTab3;
@synthesize detailWebView1 = _detailWebView1;
@synthesize detailWebView2 = _detailWebView2;
@synthesize detailWebView3 = _detailWebView3;
@synthesize audioTab = _audioTab;
@synthesize imageTab = _imageTab;
@synthesize tabBar = _tabBar;
@synthesize imageView = _imageView;
@synthesize infoView = _infoView;
@synthesize audioView = _audioView;



- (BOOL)hidesBottomBarWhenPushed{
	return TRUE;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    // Do any additional setup after loading the view from its nib.
	self.hidesBottomBarWhenPushed = YES;
	self.navigationController.navigationBar.translucent = YES;
	//Setup ImageView
	pagingScrollView = [[MVPagingScollView alloc] initWithNibName:@"MVPagingScollView" bundle:nil];
	CGRect imageViewFrame = _imageView.frame;
	[_imageView insertSubview:pagingScrollView.view atIndex:0];
	pagingScrollView.view.frame = imageViewFrame;
	pagingScrollView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;	
	[pagingScrollView newImageSet:[_detailSpeci.images allObjects]];  
	pagingScrollView.delegate = self;
	
	
	//Display Web Content
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	//	NSLog([self constructHTML]);
    
	_detailWebView1.opaque = NO;
	_detailWebView1.backgroundColor = [UIColor clearColor];
	_detailWebView2.opaque = NO;
	_detailWebView2.backgroundColor = [UIColor clearColor];
	_detailWebView3.opaque = NO;
	_detailWebView3.backgroundColor = [UIColor clearColor];
	NSString *htmlPath1;
	NSString *htmlPath2;
	NSString *htmlPath3;
    BOOL html1Assigned = NO;
    BOOL html2Assigned = NO;
    BOOL html3Assigned = NO;
    
    //setup HTML Paths for templates
    NSMutableArray *tabBarSorted = [[_tabBar items] mutableCopy];
    [tabBarSorted removeAllObjects];
    NSLog(@"TabOne:%@",_detailSpeci.template.tabOne.tabName );
    if ([_detailSpeci.template.tabOne.tabName isEqualToString:@"images"] ) {
        [tabBarSorted insertObject:_imageTab atIndex:0];
        
    }else if ([_detailSpeci.template.tabOne.tabName isEqualToString: @"audio"]){
        [tabBarSorted insertObject:_audioTab atIndex:0];
    } else if (_detailSpeci.template.tabOne.tabName != nil){
        if (!html1Assigned) {
          	htmlPath1 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabOne.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            NSLog(@"html1 tabOne:");
            
            html1Assigned = YES;
             [tabBarSorted insertObject:_detailTab1 atIndex:0];
        } else if (!html2Assigned){
            htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabOne.tabTemplate stringByDeletingPathExtension] ofType:@"html"]; 
            html2Assigned =YES;
             [tabBarSorted insertObject:_detailTab2 atIndex:0];
        } else if (!html3Assigned){
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabOne.tabTemplate stringByDeletingPathExtension] ofType:@"html"];  
            html3Assigned = YES;
             [tabBarSorted insertObject:_detailTab3 atIndex:0];
        }
    }
    //tab2
       NSLog(@"Tab2:%@",_detailSpeci.template.tabTwo.tabName );
    if ([_detailSpeci.template.tabTwo.tabName isEqualToString: @"images"] ) {
        [tabBarSorted insertObject:_imageTab atIndex:1];
    }else if ([_detailSpeci.template.tabTwo.tabName isEqualToString: @"audio"]){
        [tabBarSorted insertObject:_audioTab atIndex:1];
    } else if (_detailSpeci.template.tabTwo.tabName != nil){
        if (!html1Assigned) {
          	htmlPath1 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabTwo.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html1Assigned = YES;
             [tabBarSorted insertObject:_detailTab1 atIndex:1];
             NSLog(@"html1 tabtwo:");
        } else if (!html2Assigned){
            NSLog(@"html2 tabtwo:");
            htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabTwo.tabTemplate stringByDeletingPathExtension] ofType:@"html"]; 
            html2Assigned =YES;
             [tabBarSorted insertObject:_detailTab2 atIndex:1];
        } else if (!html3Assigned){
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabTwo.tabTemplate stringByDeletingPathExtension] ofType:@"html"];  
            html3Assigned = YES;
             [tabBarSorted insertObject:_detailTab3 atIndex:1];
        }
    }    
    //tab3
        NSLog(@"Tab3:%@",_detailSpeci.template.tabThree.tabName );
    if ([_detailSpeci.template.tabThree.tabName isEqualToString: @"images"] ) {
        [tabBarSorted insertObject:_imageTab atIndex:2];
    }else if ([_detailSpeci.template.tabThree.tabName isEqualToString:@"audio"]){
        [tabBarSorted insertObject:_audioTab atIndex:2];
    } else if (_detailSpeci.template.tabThree.tabName != nil){
        if (!html1Assigned) {
          	htmlPath1 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabThree.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html1Assigned = YES;
             [tabBarSorted insertObject:_detailTab1 atIndex:2];
               NSLog(@"html2 tabThree:");
        } else if (!html2Assigned){
            htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabThree.tabTemplate stringByDeletingPathExtension] ofType:@"html"]; 
            html2Assigned =YES;
             [tabBarSorted insertObject:_detailTab2 atIndex:2];
               NSLog(@"html2 tabThree:");
        } else if (!html3Assigned){
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabThree.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            NSLog(@"html3 tabThree:");
            html3Assigned = YES;
             [tabBarSorted insertObject:_detailTab2 atIndex:2];
        }
    }   
    
    //tab 4
        NSLog(@"Ta4:%@",_detailSpeci.template.tabFour.tabName );
    if ([_detailSpeci.template.tabFour.tabName isEqualToString:@"images"] ) {
        [tabBarSorted insertObject:_imageTab atIndex:3];
    }else if ([_detailSpeci.template.tabFour.tabName isEqualToString:@"audio"]){
        [tabBarSorted insertObject:_audioTab atIndex:3];
    } else if (_detailSpeci.template.tabFour.tabName != nil){
        if (!html1Assigned) {
          	htmlPath1 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabFour.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            
            html1Assigned = YES;
            [tabBarSorted insertObject:_detailTab1 atIndex:3];
             NSLog(@"htm1 tab4:");
        } else if (!html2Assigned){
            htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabFour.tabTemplate stringByDeletingPathExtension] ofType:@"html"]; 
            html2Assigned =YES;
             [tabBarSorted insertObject:_detailTab2 atIndex:3];
              NSLog(@"htm2 tab4:");
        } else if (!html3Assigned){
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabFour.tabTemplate stringByDeletingPathExtension] ofType:@"html"];  
            NSLog(@"html3:%@",[_detailSpeci.template.tabFour.tabTemplate stringByDeletingPathExtension] );
            html3Assigned = YES;
             [tabBarSorted insertObject:_detailTab3 atIndex:3];
              NSLog(@"htm3 tab4:");
        }
    }     
    //tab 5
        NSLog(@"Tab5:%@",_detailSpeci.template.tabFive.tabName );
    if ([_detailSpeci.template.tabFive.tabName isEqualToString:@"images"] ) {
        [tabBarSorted insertObject:_imageTab atIndex:4];
    }else if ([_detailSpeci.template.tabFive.tabName isEqualToString: @"audio"]){
        [tabBarSorted insertObject:_audioTab atIndex:4];
          NSLog(@"Audio tab5:");
    } else if (_detailSpeci.template.tabFive.tabName != nil){
        if (!html1Assigned) {
          	htmlPath1 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabFive.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html1Assigned = YES;
             [tabBarSorted insertObject:_detailTab1 atIndex:4];
        } else if (!html2Assigned){
            htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabFive.tabTemplate stringByDeletingPathExtension] ofType:@"html"]; 
            html2Assigned =YES;
             [tabBarSorted insertObject:_detailTab2 atIndex:4];
        } else if (!html3Assigned){
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailSpeci.template.tabFive.tabTemplate stringByDeletingPathExtension] ofType:@"html"];  
            html3Assigned = YES;
             [tabBarSorted insertObject:_detailTab3 atIndex:4];
        }
    }     
    
    //step through the template tabs
/*
	htmlPath1 = [[NSBundle mainBundle] pathForResource:@"template-iphone-details" ofType:@"html"];
	htmlPath2 = [[NSBundle mainBundle] pathForResource:@"template-iphone-distribution" ofType:@"html"];
	htmlPath3 =[[NSBundle mainBundle] pathForResource:@"template-iphone-scarcity" ofType:@"html"];
  */  
	if (html1Assigned) {
 	details1HTMLCode= [[NSMutableString alloc] initWithContentsOfFile:htmlPath1 usedEncoding:nil error:NULL];
        NSLog(@"HTMLPath1:%@", htmlPath1);
    }
    if (html2Assigned) {
        details2HTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath2 usedEncoding:nil error:NULL];
        NSLog(@"HTMLPath2:%@", htmlPath2);
    }
	if (html3Assigned){
        details3HTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath3 usedEncoding:nil error:NULL];      
        NSLog(@"HTMLPath3:%@", htmlPath3);
    }

    
    //Replace occurances of <%label%> and <%sublabel%> to stop repetition in 
    [self htmlTemplate:details1HTMLCode keyString:@"label" replaceWith:_detailSpeci.label];
    [self htmlTemplate:details2HTMLCode keyString:@"label" replaceWith:_detailSpeci.label];
    [self htmlTemplate:details3HTMLCode keyString:@"label" replaceWith:_detailSpeci.label];
	[self htmlTemplate:details1HTMLCode keyString:@"sublabel" replaceWith:_detailSpeci.sublabel];
 	[self htmlTemplate:details2HTMLCode keyString:@"sublabel" replaceWith:_detailSpeci.sublabel];
    [self htmlTemplate:details3HTMLCode keyString:@"sublabel" replaceWith:_detailSpeci.sublabel];
    
    for (NSString *tmpKey in (NSDictionary *) _detailSpeci.details) {
        [self htmlTemplate:details1HTMLCode keyString:tmpKey replaceWith:[(NSDictionary*)_detailSpeci.details objectForKey:tmpKey]];
        [self htmlTemplate:details2HTMLCode keyString:tmpKey replaceWith:[(NSDictionary*)_detailSpeci.details objectForKey:tmpKey]];
        [self htmlTemplate:details3HTMLCode keyString:tmpKey replaceWith:[(NSDictionary*)_detailSpeci.details objectForKey:tmpKey]];
    }
	
	
	//NSString *baseHTMLCode = [[NSString alloc] initWithString:[self constructHTML]];
    
	[_detailWebView1 loadHTMLString:details1HTMLCode  baseURL:baseURL];
	[_detailWebView2  loadHTMLString:details2HTMLCode baseURL:baseURL];
	[_detailWebView3  loadHTMLString:details3HTMLCode baseURL:baseURL];
    
	
	//Disable audio Button if no audio
	if ([_detailSpeci.audios count] > 0) {
		//audioView.enabled = YES;
		_audioTab.enabled = YES;
		audioList = [[AudioListViewController alloc] initWithNibName:@"AudioListViewController" bundle:nil];
		audioList.audioFilesArray = (NSArray *)[_detailSpeci.audios allObjects];
	}else {
		//audioView.enabled = NO;
		_audioTab.enabled = NO;
	}
    
	//Set up initial state.
    _detailWebView1.hidden = YES;
	_detailWebView2.hidden = YES;
	_detailWebView3.hidden = YES;
	_tabBar.selectedItem = _imageTab;
    
    //Change tab order, remove extra tabitems
  //  _detailTab1.title = @"Painting";
  //  NSMutableArray *tabBarCopy = [[_tabBar items] mutableCopy];
  //  [tabBarCopy exchangeObjectAtIndex:0 withObjectAtIndex:1];
   // [tabBarCopy removeObject:_detailTab2];
    //[tabBarCopy removeObjectAtIndex:2];
  //  [_tabBar setItems:tabBarCopy];
   // [tabBarCopy release];
    
    [_tabBar setItems:tabBarSorted];
    [tabBarSorted release];
	
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
	[pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration  {
    
	[pagingScrollView willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
}

-(void) handleSingleTap:(UIGestureRecognizer *)sender{
	//if hidden, show,
    
	if (self.navigationController.navigationBarHidden == YES) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		_tabBar.hidden = NO;
		CGRect imageViewFrame = pagingScrollView.view.frame;
		imageViewFrame.origin.x = 0;
		imageViewFrame.origin.y = 0;
		imageViewFrame.size.height = imageViewFrame.size.height - 49;
		pagingScrollView.view.frame = imageViewFrame;
        //	NSLog(@"Navigation Bar Section");
	}else {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		_tabBar.hidden = YES;
		CGRect imageViewFrame = pagingScrollView.view.frame;
		imageViewFrame.origin.x = 0;
		imageViewFrame.origin.y = 0;
		imageViewFrame.size.height = imageViewFrame.size.height + 49;
		pagingScrollView.view.frame = imageViewFrame;	
	}
	
	
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request mainDocumentURL]];
		return NO;
	}
	
	return YES;
}
-(IBAction)toggleInfo:(id)sender{}
-(void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString{
    
    if (replacementString != nil && [replacementString length] > 0) {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@" " options:0 range:NSMakeRange(0, [templateString length])];
	}else {
		NSLog(@"keystring %@ is nil", stringToReplace);
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:@"" options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@"invisible" options:0 range:NSMakeRange(0, [templateString length])];
		
	}
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
	//NSString *path = [[NSBundle mainBundle] bundlePath];
	//NSURL *baseURL = [NSURL fileURLWithPath:path];
	
	if (item == _detailTab1) {
        self.navigationController.navigationBar.translucent = NO;
		//27/02 commented out remove from superview
		//	if (pagingScrollView.view.superview ==self.view ) {
        //		[pagingScrollView.view removeFromSuperview];
        //	}
		if (audioList.view.superview == self.view) {
			[audioList.view removeFromSuperview];
		}
		pagingScrollView.view.hidden = YES;
		_detailWebView2.hidden = YES;
		_detailWebView3.hidden = YES;
		_detailWebView1.hidden = NO;
		
	}else if (item == _imageTab) {
        if (audioList.view.superview == self.view) {
			[audioList.view removeFromSuperview];
		}
		self.navigationController.navigationBar.translucent = YES;
        
		pagingScrollView.view.hidden = NO;
		_detailWebView2.hidden = YES;
		_detailWebView3.hidden = YES;
		_detailWebView1.hidden = YES;
		
	} else if (item == _audioTab) {
        //	if (pagingScrollView.view.superview ==self.view ) {
        //		[pagingScrollView.view removeFromSuperview];
        //	}
		self.navigationController.navigationBar.translucent = NO;		 
        
		[self.view insertSubview:audioList.view atIndex:1];
		pagingScrollView.view.hidden = YES;
		_detailWebView2.hidden = YES;
		_detailWebView3.hidden = YES;
		_detailWebView1.hidden = YES;
		
	} else if (item == _detailTab2){
        self.navigationController.navigationBar.translucent = NO;
        
		if (audioList.view.superview == self.view) {
			[audioList.view removeFromSuperview];
		}
        
		pagingScrollView.view.hidden = YES;
		_detailWebView2.hidden = NO;
		_detailWebView3.hidden = YES;
		_detailWebView1.hidden = YES;
		
	}else if (item == _detailTab3){
        self.navigationController.navigationBar.translucent = NO;
        
		if (audioList.view.superview == self.view) {
			[audioList.view removeFromSuperview];
		}
        
		pagingScrollView.view.hidden = YES;
		_detailWebView2.hidden = YES;
		_detailWebView3.hidden = NO;
		_detailWebView1.hidden = YES;
		
	}
    
	
}




@end
