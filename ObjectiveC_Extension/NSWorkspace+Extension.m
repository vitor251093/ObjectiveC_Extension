//
//  NSWorkspace+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 24/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSWorkspace+Extension.h"

#import "NSTask+Extension.h"

@implementation NSWorkspace (VMMWorkspace)

-(nonnull NSArray<NSRunningApplication*>*)runningApplicationsFromInsideBundle:(nonnull NSString*)bundlePath
{
    NSMutableArray* list = [[NSMutableArray alloc] init];
    
    for (NSRunningApplication* runningApp in [self runningApplications])
    {
        NSString* binLocalPath = [[runningApp executableURL] path];
        
        if (![binLocalPath hasPrefix:bundlePath] && [bundlePath hasPrefix:@"/private"])
        {
            binLocalPath = [@"/private" stringByAppendingString:binLocalPath];
        }
        
        if ([binLocalPath hasPrefix:bundlePath])
        {
            [list addObject:runningApp];
        }
    }
    
    return list;
}

-(void)forceOpenURL:(nonnull NSURL*)url
{
    BOOL opened = [self openURL:url];
    
    if (opened == false)
    {
        [NSTask runProgram:@"open" withFlags:@[url.absoluteString]];
    }
}

@end
