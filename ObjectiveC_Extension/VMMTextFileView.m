//
//  VMMTextFileView.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 21/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMTextFileView.h"

#import "NSString+Extension.h"
#import "NSText+Extension.h"
#import "NSTimer+Extension.h"

@implementation VMMTextFileView

-(void)awakeFromNib
{
    _runLoopMode = NSDefaultRunLoopMode;
}

-(NSString* _Nullable)textFileContents
{
    return [NSString stringWithContentsOfFile:_textFilePath encoding:_textFileEncoding];
}
-(void)reloadTextFileForTimer:(NSTimer*)timer
{
    NSString* wineLog = [self textFileContents];
    NSRange priorSelectedRange = wineLog.length >= self.string.length ? self.selectedRange : NSMakeRange(0, 0);
    [self deselectText];
    
    if (wineLog != nil)
    {
        @try
        {
            [self setString:wineLog];
            [self setSelectedRange:priorSelectedRange];
        }
        @catch (NSException* exception)
        {
            [self setString:@""];
            [self setSelectedRange:NSMakeRange(0, 0)];
        }
    }
    
    [self scrollToBottom];
}
-(void)startReloadingTextFileWithTimeInterval:(NSTimeInterval)interval
{
    [self setSelectedRangeAsTheBeginOfTheField];
    [self setString:@""];
    
    monitorTimer = [NSTimer scheduledTimerWithRunLoopMode:_runLoopMode timeInterval:interval target:self
                                                 selector:@selector(reloadTextFileForTimer:) userInfo:nil];
}
-(void)showTextFileAtPath:(nonnull NSString*)filePath withEncoding:(NSStringEncoding)encoding refreshingWithTimeInterval:(NSTimeInterval)interval
{
    _textFilePath = filePath;
    _textFileEncoding = encoding;
    
    if (interval == 0)
    {
        [self reloadTextFileForTimer:nil];
    }
    else
    {
        [self startReloadingTextFileWithTimeInterval:interval];
    }
}
-(void)stopRefreshing
{
    if (monitorTimer == nil) return;
    
    [monitorTimer invalidate];
    [self reloadTextFileForTimer:nil];
}

@end
