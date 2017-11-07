//
//  NSScreen+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 04/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSScreen+Extension.h"

@implementation NSScreen (VMMScreen)

-(CGFloat)retinaScale
{
    return [self respondsToSelector:@selector(backingScaleFactor)] ? self.backingScaleFactor : self.userSpaceScaleFactor;
}

@end
