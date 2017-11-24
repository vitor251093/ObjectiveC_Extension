//
//  VMMTextFileView.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 21/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMTextFileView.h"

#import "NSString+Extension.h"
#import "NSTimer+Extension.h"

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
    
    monitorTimer = [NSTimer scheduledTimerWithRunLoopMode:_runLoopMode timeInterval:interval target:self
                                                 selector:@selector(reloadTextFileForTimer:) userInfo:nil];
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