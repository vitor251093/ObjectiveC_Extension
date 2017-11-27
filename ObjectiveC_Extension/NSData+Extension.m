//
//  NSData+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSData+Extension.h"

#import "SZJsonParser.h"

#import "NSAlert+Extension.h"

#import "VMMComputerInformation.h"

@implementation NSData (VMMData)
+(NSData*)dataWithContentsOfURL:(NSURL *)url timeoutInterval:(long long int)timeoutInterval
{
    NSData* stringData;
    
    @autoreleasepool
    {
        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:timeoutInterval];
        
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        stringData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error || response.statusCode < 200 || response.statusCode >= 300)
        {
            stringData = nil;
        }
    }
    
    return stringData;
}
+(NSData*)safeDataWithContentsOfFile:(NSString*)filePath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) return nil;
    
    NSData* data;
    
    @autoreleasepool
    {
        NSError *error = nil;
        data = [[NSData alloc] initWithContentsOfFile:filePath options:0 error:&error];
        
        if (error != nil)
        {
            [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while reading file data: %@",nil), error.localizedDescription]];
        }
    }
    
    return data;
}

+(NSString*)jsonStringWithObject:(id)object
{
    if (IsClassNSJSONSerializationAvailable == false)
    {
        @autoreleasepool
        {
            if ([object isKindOfClass:[NSString class]])
            {
                return [NSString stringWithFormat:@"\"%@\"",[[[(NSString*)object stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
                                                              stringByReplacingOccurrencesOfString:@"\n" withString:@"\\\n"]
                                                             stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"]];
            }
            
            if ([object isKindOfClass:[NSArray class]])
            {
                NSMutableArray* array = [[NSMutableArray alloc] init];
                for (id innerObject in (NSArray*)object)
                {
                    [array addObject:[self jsonStringWithObject:innerObject]];
                }
                return [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
            }
            
            if ([object isKindOfClass:[NSDictionary class]])
            {
                NSMutableArray* dict = [[NSMutableArray alloc] init];
                for (NSString* key in [(NSDictionary*)object allKeys])
                {
                    [dict addObject:[NSString stringWithFormat:@"%@:%@",[self jsonStringWithObject:key],
                                     [self jsonStringWithObject:[(NSDictionary*)object objectForKey:key]]]];
                }
                return [NSString stringWithFormat:@"{%@}",[dict componentsJoinedByString:@","]];
            }
            
            if ([object isKindOfClass:[NSNumber class]])
            {
                NSInteger integerValue = [(NSNumber*)object integerValue];
                double doubleValue = [(NSNumber*)object doubleValue];
                BOOL boolValue = [(NSNumber*)object boolValue];
                
                if (integerValue != doubleValue) return [NSString stringWithFormat:@"%lf",doubleValue];
                if (integerValue != boolValue)   return [NSString stringWithFormat:@"%ld",integerValue];
                return boolValue ? @"true" : @"false";
            }
            
            return @"";
        }
    }

    return [[NSString alloc] initWithData:[self jsonDataWithObject:object] encoding:NSUTF8StringEncoding];
}

+(NSData*)jsonDataWithObject:(id)object
{
    if (IsClassNSJSONSerializationAvailable == false)
    {
        @autoreleasepool
        {
            return [[self jsonStringWithObject:object] dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
}

-(id)objectWithJsonData
{
    if (IsClassNSJSONSerializationAvailable == false)
    {
        @autoreleasepool
        {
            @try
            {
                return [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] jsonObject];
            }
            @catch (NSException* exception)
            {
                return nil;
            }
        }
    }

    return [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
}

@end
