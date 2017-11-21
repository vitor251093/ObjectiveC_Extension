//
//  VMMTextFileView.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 21/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMTextFileView.h"

#import "NSString+Extension.h"

@implementation VMMTextFileView

-(void)awakeFromNib
{
    _runLoopMode = NSDefaultRunLoopMode;
}

-(void)reloadTextFileForTimer:(NSTimer*)timer
{
    NSString* wineLog = [NSString stringWithContentsOfFile:_textFilePath encoding:_textFileEncoding];
    [self setString:(wineLog != nil) ? wineLog : @""];
}
-(void)startReloadingTextFileWithTimeInterval:(NSTimeInterval)interval
{
    [self setString:@""];
    
    monitorTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self
                                                  selector:@selector(reloadTextFileForTimer:) userInfo:nil repeats:YES];
    NSRunLoop* theRunLoop = [NSRunLoop currentRunLoop];
    [theRunLoop addTimer:monitorTimer forMode:_runLoopMode];
}
-(void)showTextFileAtPath:(NSString*)filePath withEncoding:(NSStringEncoding)encoding refreshingWithTimeInterval:(NSTimeInterval)interval
{
    _textFilePath = filePath;
    _textFileEncoding = encoding;
    
    [self startReloadingTextFileWithTimeInterval:interval];
}
-(void)stopRefreshing
{
    if (monitorTimer == nil) return;
    
    [monitorTimer invalidate];
    [self reloadTextFileForTimer:nil];
}

@end
