//
//  NSUserDefaults+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 31/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSUserDefaults+Extension.h"

#import "VMMComputerInformation.h"
#import "VMMLogUtility.h"

@implementation NSUserDefaults (VMMUserDefaults)

-(nonnull id)objectForKey:(nonnull NSString *)key withDefaultValue:(nonnull id)value
{
    id actualValue = [self objectForKey:key];
    
    if (actualValue == nil)
    {
        [self setObject:value forKey:key];
        return value;
    }
    
    return actualValue;
}

-(BOOL)preferExternalGPU
{
    // Reference:
    // https://egpu.io/forums/mac-setup/potentially-accelerate-all-applications-on-egpu-macos-10-13-4/
    
    if ([VMMComputerInformation macOsCompatibilityWithExternalGPU] != VMMExternalGPUCompatibilityWithMacOS_Supported) {
        NSDebugLog(@"\"Prefer External GPU\" was not available prior to macOS 10.13.4. Using that probably wont't change anything.");
    }
    
    NSString* appReturn = [self objectForKey:@"GPUSelectionPolicy"];
    return appReturn != nil && [appReturn isKindOfClass:[NSString class]] && [appReturn isEqualToString:@"preferRemovable"];
}
-(void)setPreferExternalGPU:(BOOL)prefer
{
    if ([VMMComputerInformation macOsCompatibilityWithExternalGPU] != VMMExternalGPUCompatibilityWithMacOS_Supported) {
        NSDebugLog(@"\"Prefer External GPU\" was not available prior to macOS 10.13.4. Using that probably wont't change anything.");
    }
    
    if (prefer) {
        [self setObject:@"preferRemovable" forKey:@"GPUSelectionPolicy"];
    }
    else {
        [self removeObjectForKey:@"GPUSelectionPolicy"];
    }
}

@end
