//
//  DetailViewController.h
//  genera
//
//  Created by Simon Sherrin on 3/01/12.
/* Copyright (c) 2012 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
//

#import <UIKit/UIKit.h>
@class MVPagingScollView;
@class Speci;
@class AudioListViewController;
@class CustomSearchViewController;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>
{

BOOL detailsViewRaised;
int detailsTopLeft;
int imageViewBottomLeft;
    UIPopoverController *_audioPopoverController;
	AudioListViewController *_audioPopoverViewController;
    UIPopoverController *_searchPopoverController;
    CustomSearchViewController *_searchViewController;

}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (strong, nonatomic) IBOutlet UIWebView *detailsWebView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIView *imageView;
@property (strong, nonatomic) MVPagingScollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UIWebView *aboutView;
@property (strong, nonatomic) IBOutlet UIWebView *welcomeView;
@property (strong, nonatomic) IBOutlet UIView *startButtonView;


//Tool Bar Properties
@property (strong, nonatomic) IBOutlet UIToolbar *detailToolbar;
@property (strong, nonatomic) IBOutlet UILabel *titleBarLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *imageTextLayoutControl;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *audioPopoverButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *aboutPopoverButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *searchPopoverButton;
@property (nonatomic, retain) Speci *detailSpeci;
@property (nonatomic, retain) NSString *currentGroupLabel;

//Start up properties
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property  BOOL orientationLock;


//Where the magic Happens
-(void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString;
-(void) dismissAllPopovers;
- (void) touchToBegin:(id)sender;

-(void) showWelcomeView;
- (IBAction)toggleAboutView:(id)sender;
- (IBAction)showAudio:(id)sender;
-(IBAction)showSearch:(id)sender;
-(IBAction)layoutControlChanged:(id)sender;
-(void) makeToolbarButtonsInactive;
-(void) makeToolbarButtonsActive;
-(void) hideProgress;
-(void) updateProgressBar:(float)loadprogress;
@end
