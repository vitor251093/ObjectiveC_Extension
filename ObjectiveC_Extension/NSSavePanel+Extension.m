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

#import "NSModals.h"

@implementation NSOpenPanel (VMMOpenPanel)

+(void)runThreadSafeModalWithOpenPanel:(void (^)(NSOpenPanel* openPanel))optionsForPanel completionHandler:(void (^) (NSArray<NSURL*>* selectedUrls))completionHandler
{
    if ([NSThread isMainThread])
    {
        [self runMainThreadModalWithOpenPanel:optionsForPanel completionHandler:completionHandler];
    }
    else
    {
        NSArray* selectedUrls = [self runBackgroundThreadModalWithOpenPanel:optionsForPanel];
        completionHandler(selectedUrls);
    }
}
+(void)runMainThreadModalWithOpenPanel:(void (^)(NSOpenPanel* openPanel))optionsForPanel completionHandler:(void (^) (NSArray<NSURL*>* selectedUrls))completionHandler
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    optionsForPanel(openPanel);
    
    NSWindow* window = [NSModals modalsWindow];
    if (window)
    {
        [openPanel beginSheetModalForWindow:window completionHandler:^(NSModalResponse result)
        {
            [openPanel orderOut:nil];
             
            if (result == NSOKButton)
            {
                completionHandler([openPanel URLs]);
            }
        }];
    }
    else
    {
        if ([openPanel runModal] == NSOKButton)
        {
            completionHandler([openPanel URLs]);
        }
    }
}
+(NSArray<NSURL*>*)runBackgroundThreadModalWithOpenPanel:(void (^)(NSOpenPanel* openPanel))optionsForPanel
{
    __block NSArray<NSURL*>* urlsList;
    
    NSCondition* lock = [[NSCondition alloc] init];
    __block NSUInteger value;
    
    [NSThread dispatchBlockInMainQueue:^
    {
        NSOpenPanel* openPanel = [NSOpenPanel openPanel];
        optionsForPanel(openPanel);
        
        [NSThread dispatchQueueWithName:"open-panel-background-thread" priority:DISPATCH_QUEUE_PRIORITY_DEFAULT concurrent:NO withBlock:^
        {
            value = [openPanel runBackgroundThreadModalWithWindow];
            if (value == NSOKButton)
            {
                urlsList = [openPanel URLs];
            }
             
            [lock signal];
        }];
    }];
    
    [lock lock];
    [lock wait];
    [lock unlock];
    
    return urlsList;
}

@end

@implementation NSSavePanel (VMMSavePanel)

-(NSUInteger)runBackgroundThreadModalWithWindow
{
    NSWindow* window = [NSModals modalsWindow];
    
    __block NSUInteger value;
    NSCondition* lock = [[NSCondition alloc] init];
    
    [NSThread dispatchBlockInMainQueue:^
    {
        if (window)
        {
            [self beginSheetModalForWindow:window completionHandler:^(NSModalResponse result)
            {
                [self orderOut:nil];
                value = result;
                [lock signal];
            }];
        }
        else
        {
            value = [self runModal];
            [lock signal];
        }
    }];
    
    [lock lock];
    [lock wait];
    [lock unlock];
    
    return value;
}

+(void)runThreadSafeModalWithSavePanel:(void (^)(NSSavePanel* savePanel))optionsForPanel completionHandler:(void (^) (NSURL* selectedUrl))completionHandler
{
    if ([NSThread isMainThread])
    {
        [self runMainThreadModalWithSavePanel:optionsForPanel completionHandler:completionHandler];
    }
    else
    {
        NSURL* selectedUrl = [self runBackgroundThreadModalWithSavePanel:optionsForPanel];
        completionHandler(selectedUrl);
    }
}
+(void)runMainThreadModalWithSavePanel:(void (^)(NSSavePanel* savePanel))optionsForPanel completionHandler:(void (^) (NSURL* selectedUrl))completionHandler
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    optionsForPanel(savePanel);
    
    NSWindow* window = [NSModals modalsWindow];
    if (window)
    {
        [savePanel beginSheetModalForWindow:window completionHandler:^(NSModalResponse result)
        {
            [savePanel orderOut:nil];
            
            if (result == NSOKButton)
            {
                completionHandler([savePanel URL]);
            }
        }];
    }
    else
    {
        [savePanel runModal];
        completionHandler([savePanel URL]);
    }
}
+(NSURL*)runBackgroundThreadModalWithSavePanel:(void (^)(NSSavePanel* savePanel))optionsForPanel
{
    __block NSURL* url;
    
    NSCondition* lock = [[NSCondition alloc] init];
    __block NSUInteger value;
    
    [NSThread dispatchBlockInMainQueue:^
    {
        NSSavePanel* savePanel = [NSSavePanel savePanel];
        optionsForPanel(savePanel);
        
        [NSThread dispatchQueueWithName:"save-panel-background-thread" priority:DISPATCH_QUEUE_PRIORITY_DEFAULT concurrent:NO withBlock:^
        {
            value = [savePanel runBackgroundThreadModalWithWindow];
            if (value == NSOKButton)
            {
                url = [savePanel URL];
            }
            
            [lock signal];
        }];
    }];
    
    [lock lock];
    [lock wait];
    [lock unlock];
    
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
