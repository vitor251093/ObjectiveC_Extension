//
//  NSUserDefaults+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 31/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSUserDefaults+Extension.h"

@implementation NSUserDefaults (VMMUserDefaults)

-(id)objectForKey:(NSString *)key withDefaultValue:(id)value
{
    id actualValue = [self objectForKey:key];
    
    if (actualValue == nil)
    {
        [self setObject:value forKey:key];
        return value;
    }
    
    return actualValue;
}

@end
