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
#import "NSMutableString+Extension.h"

#import "VMMComputerInformation.h"
#import "VMMLocalizationUtility.h"

@implementation NSData (VMMData)

+(void)dataWithContentsOfURL:(nonnull NSURL *)url timeoutInterval:(long long int)timeoutInterval withCompletionHandler:(void (^)(NSUInteger statusCode, NSData* data, NSError* error))completion
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
        
        completion(response.statusCode, stringData, error);
    }
}
+(nullable NSData*)safeDataWithContentsOfFile:(nonnull NSString*)filePath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) return nil;
    
    NSData* data;
    
    @autoreleasepool
    {
        NSError *error = nil;
        data = [[NSData alloc] initWithContentsOfFile:filePath options:0 error:&error];
        
        if (error != nil)
        {
            [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:VMMLocalizedString(@"Error while loading file data: %@"), error.localizedDescription]];
        }
    }
    
    return data;
}

+(nullable NSString*)jsonStringWithObject:(nonnull id)object
{
    if (IsClassNSJSONSerializationAvailable == false)
    {
        @autoreleasepool
        {
            if ([object isKindOfClass:[NSString class]])
            {
                NSMutableString* stringObject = [(NSString*)object mutableCopy];
                [stringObject replaceOccurrencesOfString:@"\"" withString:@"\\\""];
                [stringObject replaceOccurrencesOfString:@"\n" withString:@"\\\n"];
                [stringObject replaceOccurrencesOfString:@"/"  withString:@"\\/" ];
                return [NSString stringWithFormat:@"\"%@\"",stringObject];
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

+(nullable NSData*)jsonDataWithObject:(nonnull id)object
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

-(nullable id)objectWithJsonData
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

-(nonnull NSString*)base64EncodedString
{
    if (![self respondsToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        return [self base64Encoding];
    }
    
    return [self base64EncodedStringWithOptions:0];
}

@end
