//
//  NSTask+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSTask+Extension.h"

#import "NSAlert+Extension.h"
#import "NSFileManager+Extension.h"

#import "NSLogUtility.h"

@implementation NSTask (VMMTask)

static NSMutableDictionary* binaryPaths;

+(NSString*)runProgram:(NSString*)program atRunPath:(NSString*)path withFlags:(NSArray*)flags wait:(BOOL)wait
{
    return [self runProgram:program atRunPath:path withEnvironment:nil withFlags:flags wait:wait];
}
+(NSString*)runProgram:(NSString*)program withEnvironment:(NSDictionary*)env withFlags:(NSArray*)flags
{
    return [self runProgram:program atRunPath:@"/" withEnvironment:env withFlags:flags wait:YES];
}
+(NSString*)runProgram:(NSString*)program atRunPath:(NSString*)path withEnvironment:(NSDictionary*)env withFlags:(NSArray*)flags wait:(BOOL)wait
{
    if (program && ![program hasPrefix:@"/"])
    {
        NSString* newProgramPath = [self getPathOfProgram:program];
        
        if (!newProgramPath)
        {
            [NSAlert showAlertOfType:NSAlertTypeError
                         withMessage:[NSString stringWithFormat:NSLocalizedString(@"Path for %@ not found.",nil), program]];
            return @"";
        }
        
        program = newProgramPath;
    }
    
#ifdef DEBUG
    if (path && flags)        NSDebugLog(@"Running %@ at path %@ with flags %@",program,path,[flags componentsJoinedByString:@" "]);
    else if (path && !flags)  NSDebugLog(@"Running %@ at path %@",program,path);
    else if (!path && flags)  NSDebugLog(@"Running %@ with flags %@",program,[flags componentsJoinedByString:@" "]);
    else if (!path && !flags) NSDebugLog(@"Running %@",program);
#endif
    
    if (path && ![path hasSuffix:@"/"]) path = [path stringByAppendingString:@"/"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:program])
    {
        [NSAlert showAlertOfType:NSAlertTypeError
                     withMessage:[NSString stringWithFormat:NSLocalizedString(@"File %@ not found.",nil), program]];
        return @"";
    }
    
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:program])
    {
        [NSAlert showAlertOfType:NSAlertTypeError
                     withMessage:[NSString stringWithFormat:NSLocalizedString(@"File %@ not runnable.",nil), program]];
        return @"";
    }
    
    if (path && ![[NSFileManager defaultManager] directoryExistsAtPath:path])
    {
        [NSAlert showAlertOfType:NSAlertTypeError
                     withMessage:[NSString stringWithFormat:NSLocalizedString(@"Directory %@ does not exists.",nil), path]];
        return @"";
    }
    
    @autoreleasepool
    {
        @try
        {
            NSTask *server = [NSTask new];
            [server setLaunchPath:program];
            if (path)  [server setCurrentDirectoryPath:path];
            if (flags) [server setArguments:flags];
            if (env)   [server setEnvironment:env];
            
            NSFileHandle *errorFileHandle = [NSFileHandle fileHandleWithNullDevice];
            [server setStandardError:errorFileHandle];
            
            if (!wait)
            {
                [server setStandardInput:[NSPipe pipe]];
                [server launch];
                
                NSDebugLog(@"Instruction finished");
                return @"";
            }
            
            NSPipe *outputPipe = [NSPipe pipe];
            [server setStandardInput:[NSPipe pipe]];
            [server setStandardOutput:outputPipe];
            [server launch];
            [server waitUntilExit];
            
            NSFileHandle *file = [outputPipe fileHandleForReading];
            NSData *outputData = [file readDataToEndOfFile];
            [file closeFile];
            
            NSDebugLog(@"Instruction finished");
            return [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        }
        @catch (NSException* exception)
        {
            // Sometimes (very rarely) the app might fail to retrieve the output of a command; with that, your app won't stop
            
            NSDebugLog(@"Failed to retrieve instruction output");
            
            return @"";
        }
    }
}

+(NSString*)getPathOfProgram:(NSString*)programName
{
    if (!programName) return nil;
    if (binaryPaths && binaryPaths[programName]) return binaryPaths[programName];
    
    NSString* programPath;
    
    @autoreleasepool
    {
        if (!binaryPaths) binaryPaths = [[NSMutableDictionary alloc] init];
        
        programPath = [self runProgram:@"/usr/bin/type" atRunPath:nil withFlags:@[@"-a",programName] wait:YES];
        if (!programPath) return nil;
        
        programPath = [[programPath componentsSeparatedByString:@" "] lastObject];
        if (programPath.length == 0) return nil;
        
        programPath = [programPath substringToIndex:programPath.length-1];
    }
    
    if (programPath) binaryPaths[programName] = programPath;
    return programPath;
}

@end

