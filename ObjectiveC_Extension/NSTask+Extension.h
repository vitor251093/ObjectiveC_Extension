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

+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags;
+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags atRunPath:(NSString*)path wait:(BOOL)wait;
+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags withEnvironment:(NSDictionary*)env;
+(NSString*)runProgram:(NSString*)program withFlags:(NSArray*)flags timeout:(unsigned int)timeout;

@end

#endif
