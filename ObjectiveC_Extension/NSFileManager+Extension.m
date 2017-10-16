//
//  NSFileManager+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSFileManager+Extension.h"

#import "NSAlert+Extension.h"
#import "NSTask+Extension.h"
#import "NSString+Extension.h"
#import "NSThread+Extension.h"

#import "NSComputerInformation.h"

@implementation NSFileManager (VMMFileManager)

-(BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath
{
    NSError* error;
    BOOL created = [self createSymbolicLinkAtPath:path withDestinationPath:destPath error:&error];
    
    if (error)
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while creating symbolic link: %@",nil), error.localizedDescription]];
    
    return created;
}
-(BOOL)createDirectoryAtPath:(NSString*)path withIntermediateDirectories:(BOOL)interDirs
{
    NSError* error;
    BOOL created = [self createDirectoryAtPath:path withIntermediateDirectories:interDirs attributes:nil error:&error];
    
    if (error)
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while creating folder: %@",nil), error.localizedDescription]];
    
    return created;
}
-(BOOL)createEmptyFileAtPath:(NSString*)path
{
    return [self createFileAtPath:path contents:nil attributes:nil];
}

-(BOOL)moveItemAtPath:(NSString*)path toPath:(NSString*)destination
{
    NSError* error;
    BOOL created = [self moveItemAtPath:path toPath:destination error:&error];
    
    if (error)
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while moving file: %@",nil),
                                                               error.localizedDescription]];
    
    return created;
}
-(BOOL)copyItemAtPath:(NSString*)path toPath:(NSString*)destination
{
    NSError* error;
    BOOL created = [self copyItemAtPath:path toPath:destination error:&error];
    
    if (error)
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while copying file: %@",nil), error.localizedDescription]];
    
    return created;
}
-(BOOL)removeItemAtPath:(NSString*)path
{
    if (![self fileExistsAtPath:path]) return YES;
    
    NSError* error;
    BOOL created = [self removeItemAtPath:path error:&error];
    
    if (error)
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while removing file: %@",nil), error.localizedDescription]];
    
    return created;
}
-(BOOL)directoryExistsAtPath:(NSString*)path
{
    BOOL isDir = NO;
    return [self fileExistsAtPath:path isDirectory:&isDir] && isDir;
}
-(BOOL)regularFileExistsAtPath:(NSString*)path
{
    BOOL isDir = NO;
    return [self fileExistsAtPath:path isDirectory:&isDir] && !isDir;
}
-(NSArray*)contentsOfDirectoryAtPath:(NSString*)path
{
    if (![self fileExistsAtPath:path])
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while listing folder contents: %@ doesn't exist.",nil), path.lastPathComponent]];
        return @[];
    }
    
    if (![self directoryExistsAtPath:path])
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while listing folder contents: %@ is not a folder.",nil), path.lastPathComponent]];
        return @[];
    }
    
    NSError* error;
    NSArray* created = [self contentsOfDirectoryAtPath:path error:&error];
    
    if (error)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while listing folder contents: %@",nil), error.localizedDescription]];
        return @[];
    }
    
    NSMutableArray* createdMutable = [created mutableCopy];
    [createdMutable removeObject:@".DS_Store"];
    
    return createdMutable;
}
-(NSString*)destinationOfSymbolicLinkAtPath:(NSString *)path
{
    NSError* error;
    NSString* destination = [self destinationOfSymbolicLinkAtPath:path error:&error];
    
    if (error)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while retrieving symbolic link destination: %@",nil),error.localizedDescription]];
    }
    
    return destination;
}

-(unsigned long long int)sizeOfRegularFileAtPath:(NSString*)path
{
    unsigned long long int result = 0;
    
    @autoreleasepool
    {
        NSDictionary *fileDictionary = [self attributesOfItemAtPath:path error:nil];
        if (fileDictionary) result = [fileDictionary[NSFileSize] unsignedLongLongValue];
    }
    
    return result;
}
-(unsigned long long int)sizeOfDirectoryAtPath:(NSString*)path
{
    unsigned long long int fileSize = 0;
    
    @autoreleasepool
    {
        NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
        
        for (NSString* file in filesArray)
        {
            NSString* filePath = [path stringByAppendingPathComponent:file];
            
            if (![self destinationOfSymbolicLinkAtPath:filePath error:nil])
            {
                fileSize += [self sizeOfRegularFileAtPath:filePath];
            }
        }
    }
    
    return fileSize;
}

-(NSString*)checksum:(NSString*)checksum ofFileAtPath:(NSString*)file
{
    if (!file) return nil;
    
    NSString* result;
    
    @autoreleasepool
    {
        NSArray* flags = [checksum isEqualToString:@"sha256"] ? @[@"dgst", @"-sha256", file] : @[checksum,file];
        
        NSString* output = [NSTask runProgram:@"openssl" withFlags:flags];
        NSRange lastSpaceRange = [output rangeOfString:@" " options:NSBackwardsSearch];
        if (lastSpaceRange.location == NSNotFound) return nil;
        
        CGFloat checkSumWithSkipLineStartLocation = lastSpaceRange.location + lastSpaceRange.length;
        NSRange checkSumWithSkipLineStartRange = NSMakeRange(checkSumWithSkipLineStartLocation, output.length - checkSumWithSkipLineStartLocation);
        
        NSRange checkSumWithSkipLineEndRange = [output rangeOfString:@"\n" options:0 range:checkSumWithSkipLineStartRange];
        CGFloat checkSumWithSkipLineLength = checkSumWithSkipLineEndRange.location - checkSumWithSkipLineStartLocation;
        
        result = [output substringWithRange:NSMakeRange(checkSumWithSkipLineStartLocation, checkSumWithSkipLineLength)];
    }
    
    return result;
}

-(NSString*)base64OfFileAtPath:(NSString*)path
{
    if (IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR)
    {
        NSData* data = [NSData dataWithContentsOfFile:path];
        return [data base64EncodedStringWithOptions:0];
    }
    
    __block NSString* output;
    
    [NSThread runThreadSafeBlock:^
    {
        NSString* tempFileOutputPath = [NSTemporaryDirectory() stringByAppendingString:@"tempFileOutput"];
        
        [self removeItemAtPath:tempFileOutputPath];
        [NSTask runCommand:@[@"openssl", @"base64", @"-in", path, @"-out", tempFileOutputPath, @"-A"]];
        
        output = [NSString stringWithContentsOfFile:tempFileOutputPath encoding:NSASCIIStringEncoding];
        [self removeItemAtPath:tempFileOutputPath];
    }];
    
    return output;
}

@end
