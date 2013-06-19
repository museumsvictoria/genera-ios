//
//  TemplateTab.h
//  genera
//
//  Created by Simon Sherrin on 8/01/12.
/* Copyright (c) 2012 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Template;

@interface TemplateTab : NSManagedObject

@property (nonatomic, retain) NSString * tabTemplate;
@property (nonatomic, retain) NSString * tabIcon;
@property (nonatomic, retain) NSString * tabLabel;
@property (nonatomic, retain) NSString * tabName;
@property (nonatomic, retain) NSSet *fifthTabs;
@property (nonatomic, retain) NSSet *firstTabs;
@property (nonatomic, retain) NSSet *fourthTabs;
@property (nonatomic, retain) NSSet *secondTabs;
@property (nonatomic, retain) NSSet *thirdTabs;
@end

@interface TemplateTab (CoreDataGeneratedAccessors)

- (void)addFifthTabsObject:(Template *)value;
- (void)removeFifthTabsObject:(Template *)value;
- (void)addFifthTabs:(NSSet *)values;
- (void)removeFifthTabs:(NSSet *)values;
- (void)addFirstTabsObject:(Template *)value;
- (void)removeFirstTabsObject:(Template *)value;
- (void)addFirstTabs:(NSSet *)values;
- (void)removeFirstTabs:(NSSet *)values;
- (void)addFourthTabsObject:(Template *)value;
- (void)removeFourthTabsObject:(Template *)value;
- (void)addFourthTabs:(NSSet *)values;
- (void)removeFourthTabs:(NSSet *)values;
- (void)addSecondTabsObject:(Template *)value;
- (void)removeSecondTabsObject:(Template *)value;
- (void)addSecondTabs:(NSSet *)values;
- (void)removeSecondTabs:(NSSet *)values;
- (void)addThirdTabsObject:(Template *)value;
- (void)removeThirdTabsObject:(Template *)value;
- (void)addThirdTabs:(NSSet *)values;
- (void)removeThirdTabs:(NSSet *)values;
@end
