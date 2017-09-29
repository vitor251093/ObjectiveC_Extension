//
//  NSSavePanel+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSSavePanel+Extension.h"

#import "NSThread+Extension.h"

#import "NSComputerInformation.h"

@implementation NSOpenPanel (VMMOpenPanel)

+(NSArray<NSURL*>*)runThreadSafeModalWithOpenPanel:(void (^)(NSOpenPanel* openPanel))optionsForPanel
{
    __block NSArray<NSURL*>* urlsList;
    
    if ([NSThread isMainThread])
    {
        NSOpenPanel* openPanel = [NSOpenPanel openPanel];
        optionsForPanel(openPanel);
        
        NSUInteger result = [openPanel runModal];
        if (result == NSOKButton)
        {
            urlsList = [openPanel URLs];
        }
    }
    else
    {
        NSCondition* lock = [[NSCondition alloc] init];
        __block NSUInteger value;
        
        [NSThread dispatchBlockInMainQueue:^
        {
            NSOpenPanel* openPanel = [NSOpenPanel openPanel];
            optionsForPanel(openPanel);
            
            value = [openPanel runModal];
            if (value == NSOKButton)
            {
                urlsList = [openPanel URLs];
            }
             
            [lock signal];
        }];
        
        [lock lock];
        [lock wait];
        [lock unlock];
    }
    
    return urlsList;
}

@end

@implementation NSSavePanel (VMMSavePanel)

+(NSURL*)runThreadSafeModalWithSavePanel:(void (^)(NSSavePanel* savePanel))optionsForPanel
{
    __block NSURL* url;
    
    if ([NSThread isMainThread])
    {
        NSSavePanel* savePanel = [NSSavePanel savePanel];
        optionsForPanel(savePanel);
        
        NSUInteger result = [savePanel runModal];
        if (result == NSOKButton)
        {
            url = [savePanel URL];
        }
    }
    else
    {
        NSCondition* lock = [[NSCondition alloc] init];
        __block NSUInteger value;
        
        [NSThread dispatchBlockInMainQueue:^
        {
            NSSavePanel* savePanel = [NSSavePanel savePanel];
            optionsForPanel(savePanel);
            
            value = [savePanel runModal];
            if (value == NSOKButton)
            {
                url = [savePanel URL];
            }
             
            [lock signal];
        }];
        
        [lock lock];
        [lock wait];
        [lock unlock];
    }
    
    return url;
}

-(void)setInitialDirectory:(NSString*)path
{
    [self setDirectoryURL:[NSURL fileURLWithPath:path isDirectory:YES]];
}

-(void)setWindowTitle:(NSString*)string
{
    if ([self isKindOfClass:[NSOpenPanel class]])
    {
        if (IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR)
        {
            [self setMessage:string];
        }
        else
        {
            [self setTitle:string];
        }
    }
    else
    {
        [self setTitle:string];
    }
}

@end
