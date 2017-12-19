//
//  NSException+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 19/12/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSException+Extension.h"

NSException* exception(NSString* name, NSString* reason)
{
    return [NSException exceptionWithName:name reason:reason userInfo:nil];
}

@implementation NSException (VMMException)

@end
