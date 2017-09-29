//
//  NSData+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSData_Extension_Class
#define NSData_Extension_Class

#import <Foundation/Foundation.h>

@interface NSData (VMMData)

+(NSData*)dataWithContentsOfURL:(NSURL *)url timeoutInterval:(long long int)timeoutInterval;
+(NSData*)safeDataWithContentsOfFile:(NSString*)filePath;

+(NSString*)jsonStringWithJsonObject:(id)object;
+(NSData*)dataWithJsonObject:(id)object;
-(id)jsonObject;

@end

#endif
