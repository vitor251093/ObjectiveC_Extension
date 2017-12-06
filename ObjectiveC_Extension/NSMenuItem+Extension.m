//
//  NSMenuItem+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 30/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSMenuItem+Extension.h"

@implementation NSMenuItem (VMMMenuItem)

+(nonnull NSMenuItem*)menuItemWithTitle:(nonnull NSString*)title andAction:(nullable SEL)action forTarget:(nullable id)target
{
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    [item setTarget:target];
    return item;
}

@end
