//
//  NSMutableString+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 04/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSMutableString+Extension.h"

@implementation NSMutableString (VMMMutableString)

-(void)replaceOccurrencesOfString:(nonnull NSString *)target withString:(nonnull NSString *)replacement
{
    [self replaceOccurrencesOfString:target withString:replacement options:0 range:NSMakeRange(0, self.length)];
}

@end
