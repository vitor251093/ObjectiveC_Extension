//
//  NSTimer+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 23/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (VMMTimer)

+(NSTimer*)scheduledTimerWithRunLoopMode:(NSRunLoopMode)runLoopMode timeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo;

@end
