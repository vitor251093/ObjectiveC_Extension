//
//  NSTask+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSTask_Extension_Class
#define NSTask_Extension_Class

#import <Foundation/Foundation.h>

@interface NSTask (VMMTask)

+(NSString*)runCommand:(NSArray*)programAndFlags;
+(NSString*)runCommand:(NSArray*)programAndFlags atRunPath:(NSString*)path;

+(void)runAsynchronousCommand:(NSArray*)programAndFlags;

+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags;
+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags atRunPath:(NSString*)path andWaiting:(BOOL)wait;
+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags withEnvironment:(NSDictionary*)env;
+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags waitingForTimeInterval:(unsigned int)timeout;

+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags atRunPath:(NSString*)path withEnvironment:(NSDictionary*)env andWaiting:(BOOL)wait forTimeInterval:(unsigned int)timeout;

@end

#endif
