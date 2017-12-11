//
//  VMMUUID.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 03/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMUUID.h"

#import "VMMComputerInformation.h"

@implementation VMMUUID

+(nonnull NSString*)newUUIDString
{
    @autoreleasepool
    {    
        if (IsClassNSUUIDAvailable == false)
        {
            @autoreleasepool
            {
                CFUUIDRef udid = CFUUIDCreate(NULL);
                NSString* newUUID = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
                CFRelease(udid);
                return newUUID;
            }
        }
        
        return [[NSUUID UUID] UUIDString];
    }
}

@end
