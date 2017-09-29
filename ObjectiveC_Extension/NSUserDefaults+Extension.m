//
//  NSUserDefaults+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 31/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSUserDefaults+Extension.h"

@implementation NSUserDefaults (VMMUserDefaults)

-(id)objectForKey:(NSString *)defaultName withDefaultValue:(id)value
{
    if (![self objectForKey:defaultName])
    {
        [self setObject:value forKey:defaultName];
    }
    
    return [self objectForKey:defaultName];
}

@end
