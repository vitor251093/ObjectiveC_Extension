//
//  NSScreen+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 04/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSScreen+Extension.h"

#import "NSComputerInformation.h"

@implementation NSScreen (VMMScreen)

-(CGFloat)retinaScale
{
    return IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR ? self.backingScaleFactor : self.userSpaceScaleFactor;
}

@end
