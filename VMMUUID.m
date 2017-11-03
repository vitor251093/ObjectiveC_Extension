//
//  VMMUUID.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 03/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMUUID.h"

#import "NSComputerInformation.h"

@implementation VMMUUID

+(NSString*)newUUIDString
{
    if (IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR)
    {
        return [[NSUUID UUID] UUIDString];
    }
    
    CFUUIDRef udid = CFUUIDCreate(NULL);
    NSString* newUUID = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
    return newUUID;
}

@end
