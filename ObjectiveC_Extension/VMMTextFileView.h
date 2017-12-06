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

@property (nonatomic, strong, nullable) NSString* textFilePath;
@property (nonatomic) NSStringEncoding textFileEncoding;
@property (nonatomic, nullable) NSRunLoopMode runLoopMode;

-(void)showTextFileAtPath:(nonnull NSString*)filePath withEncoding:(NSStringEncoding)encoding refreshingWithTimeInterval:(NSTimeInterval)interval;
-(void)stopRefreshing;

@end
