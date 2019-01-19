//
//  NSTimer+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 23/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSTimer+Extension.h"

@implementation NSTimer (VMMTimer)

+(nonnull NSTimer*)scheduledTimerWithRunLoopMode:(nonnull NSRunLoopMode)runLoopMode timeInterval:(NSTimeInterval)interval target:(nonnull id)target selector:(nonnull SEL)selector userInfo:(nullable id)userInfo
{
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:interval target:target selector:selector userInfo:userInfo repeats:YES];
    NSRunLoop* theRunLoop = [NSRunLoop currentRunLoop];
    [theRunLoop addTimer:timer forMode:runLoopMode];
    return timer;
}
+(nonnull NSTimer*)scheduledTimerWithRunLoopMode:(nonnull NSRunLoopMode)runLoopMode timeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer* timer))block
{
    NSTimer* timer = [NSTimer timerWithTimeInterval:interval repeats:repeats block:block];
    NSRunLoop* theRunLoop = [NSRunLoop currentRunLoop];
    [theRunLoop addTimer:timer forMode:runLoopMode];
    return timer;
}


@end
