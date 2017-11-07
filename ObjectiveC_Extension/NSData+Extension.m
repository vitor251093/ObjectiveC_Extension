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
        
        if (error)
        {
            [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while reading file data: %@",nil), error.localizedDescription]];
        }
    }
    
    return data;
}

+(NSString*)jsonStringWithJsonObject:(id)object
{
    if (IsClassAvailable(@"NSJSONSerialization"))
    {
        NSString* jsonString;
        
        @autoreleasepool
        {
            jsonString = [[NSString alloc] initWithData:[self dataWithJsonObject:object] encoding:NSUTF8StringEncoding];
        }
        
        return jsonString;
    }

    if ([object isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"\"%@\"",
                [[[(NSString*)object stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
                                     stringByReplacingOccurrencesOfString:@"\n" withString:@"\\\n"]
                                     stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"]];
    }
    
    if ([object isKindOfClass:[NSArray class]])
    {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for (id innerObject in (NSArray*)object)
        {
            [array addObject:[self jsonStringWithJsonObject:innerObject]];
        }
        return [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
    }
    
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray* dict = [[NSMutableArray alloc] init];
        for (NSString* key in [(NSDictionary*)object allKeys])
        {
            [dict addObject:[NSString stringWithFormat:@"%@:%@",[self jsonStringWithJsonObject:key],
                                        [self jsonStringWithJsonObject:[(NSDictionary*)object objectForKey:key]]]];
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

+(NSData*)dataWithJsonObject:(id)object
{
    if (IsClassAvailable(@"NSJSONSerialization"))
    {
        return [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    }

    @autoreleasepool
    {
        return [[self jsonStringWithJsonObject:object] dataUsingEncoding:NSUTF8StringEncoding];
    }
}

-(id)jsonObject
{
    if (IsClassAvailable(@"NSJSONSerialization"))
    {
        return [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
    }

    @autoreleasepool
    {
        NSString* returnedString = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
        return [returnedString jsonObject];
    }
}

@end
