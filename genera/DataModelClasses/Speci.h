//
//  Speci.h
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

@class Audio, Group, Image, Template;

@interface Speci : NSManagedObject

@property (nonatomic, retain) id details;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * labelStyle;
@property (nonatomic, retain) NSString * searchText;
@property (nonatomic, retain) NSString * squareThumbnail;
@property (nonatomic, retain) NSString * subgroup;
@property (nonatomic, retain) NSString * sublabel;
@property (nonatomic, retain) NSString * sublabelStyle;
@property (nonatomic, retain) NSSet *audios;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Template *template;
@end

@interface Speci (CoreDataGeneratedAccessors)

- (void)addAudiosObject:(Audio *)value;
- (void)removeAudiosObject:(Audio *)value;
- (void)addAudios:(NSSet *)values;
- (void)removeAudios:(NSSet *)values;
- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;
@end
