//
//  NSMutableURLRequest+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSMutableURLRequest+Extension.h"

#define RFC2822_STANDARD             @"EEE, dd MMM yyyy HH:mm:ss Z"
#define RFC2822_LOCALE               @"en_US_POSIX"
#define IF_MODIFIED_SINCE_HEADER     @"If-Modified-Since"

@implementation NSMutableURLRequest (VMMMutableURLRequest)

-(void)ifModifiedSince:(NSDate*)modificationDate
{
    NSString *dateString;
    
    @autoreleasepool
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:RFC2822_LOCALE];
        dateFormatter.dateFormat = RFC2822_STANDARD;
        dateString = [dateFormatter stringFromDate:modificationDate];
    }
    
    [self addValue:dateString forHTTPHeaderField:IF_MODIFIED_SINCE_HEADER];
}

@end

