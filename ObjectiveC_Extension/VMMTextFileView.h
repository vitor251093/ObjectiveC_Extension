//
//  VMMTextFileView.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 21/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VMMTextFileView : NSTextView
{
    NSTimer *monitorTimer;
}

@property (nonatomic, strong) NSString* textFilePath;
@property (nonatomic) NSStringEncoding textFileEncoding;
@property (nonatomic) NSRunLoopMode runLoopMode;

-(void)showTextFileAtPath:(NSString*)filePath withEncoding:(NSStringEncoding)encoding updatingWithTimeInterval:(NSTimeInterval)interval;
-(void)stopRefreshing;

@end
