//
//  NSWorkspace+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 24/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSWorkspace (VMMWorkspace)

-(NSArray<NSRunningApplication*>*)runningApplicationsFromInsideBundle:(NSString*)bundlePath;

-(void)forceOpenURL:(NSURL*)url;

@end
