//
//  NSRunningApplication+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 23/09/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSRunningApplication (VMMRunningApplication)

-(NSArray<NSDictionary*>*)visibleWindows;

-(BOOL)isVisible;

-(NSArray<NSDictionary*>*)visibleWindowsSizes;
-(NSDictionary*)windowWithSize:(NSSize)size;
-(BOOL)hasWindowWithSize:(NSSize)size;

-(void)bringWindowsToFront;

@end
