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

-(void)trim {
    while ([self hasPrefix:@" "] || [self hasPrefix:@"\n"] || [self hasPrefix:@"\t"])
        [self replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
    while ([self hasSuffix:@" "] || [self hasSuffix:@"\n"] || [self hasSuffix:@"\t"])
        [self replaceCharactersInRange:NSMakeRange(self.length-1, 1) withString:@""];
}

@end
