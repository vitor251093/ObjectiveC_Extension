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

#import "VMMComputerInformation.h"

@implementation NSFileManager (VMMFileManager)

-(BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath
{
    NSError* error;
    BOOL created = [self createSymbolicLinkAtPath:path withDestinationPath:destPath error:&error];
    
    if (error != nil)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while creating symbolic link: %@",nil), error.localizedDescription]];
    }
    
    return created;
}
-(BOOL)createDirectoryAtPath:(NSString*)path withIntermediateDirectories:(BOOL)interDirs
{
    NSError* error;
    BOOL created = [self createDirectoryAtPath:path withIntermediateDirectories:interDirs attributes:nil error:&error];
    
    if (error != nil)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while creating folder: %@",nil), error.localizedDescription]];
    }
    
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
    
    if (error != nil)
    {
        [NSAlert showAlertOfType:NSAlertTypeError
            withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while moving file: %@",nil), error.localizedDescription]];
    }
    
    return created;
}
-(BOOL)copyItemAtPath:(NSString*)path toPath:(NSString*)destination
{
    NSError* error;
    BOOL created = [self copyItemAtPath:path toPath:destination error:&error];
    
    if (error != nil)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while copying file: %@",nil), error.localizedDescription]];
    }
    
    return created;
}
-(BOOL)removeItemAtPath:(NSString*)path
{
    if ([self fileExistsAtPath:path] == false) return YES;
    
    NSError* error;
    BOOL created = [self removeItemAtPath:path error:&error];
    
    if (error != nil)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while removing file: %@",nil), error.localizedDescription]];
    }
    
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
-(NSArray<NSString*>*)contentsOfDirectoryAtPath:(NSString*)path
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
    
    if (error != nil)
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
    
    if (error != nil)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while retrieving symbolic link destination: %@",nil),error.localizedDescription]];
    }
    
    return destination;
}

-(NSString*)userReadablePathForItemAtPath:(NSString*)path joinedByString:(NSString*)join
{
    NSArray* components = [self componentsToDisplayForPath:path];
    
    if (([self fileExistsAtPath:path] == false) || (components == nil))
    {
        return [NSString stringWithFormat:@"%@%@%@",[self userReadablePathForItemAtPath:path.stringByDeletingLastPathComponent
                                                                         joinedByString:join], join, path.lastPathComponent];
    }
    
    return [components componentsJoinedByString:join];
}

-(unsigned long long int)sizeOfRegularFileAtPath:(NSString*)path
{
    unsigned long long int result = 0;
    
    @autoreleasepool
    {
        NSDictionary *fileDictionary = [self attributesOfItemAtPath:path error:nil];
        if (fileDictionary != nil) result = [fileDictionary[NSFileSize] unsignedLongLongValue];
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

-(NSString*)checksum:(NSChecksumType)checksum ofFileAtPath:(NSString*)file
{
    if (!file) return nil;
    
    NSString* result;
    
    @autoreleasepool
    {
        NSString* algorithm;
        
        switch (checksum)
        {
            case NSChecksumTypeGOSTMac:     algorithm = @"-gost-mac";    break;
            case NSChecksumTypeStreebog512: algorithm = @"-streebog512"; break;
            case NSChecksumTypeStreebog256: algorithm = @"-streebog256"; break;
            case NSChecksumTypeGOST94:      algorithm = @"-md_gost94";   break;
            case NSChecksumTypeMD4:         algorithm = @"-md4";         break;
            case NSChecksumTypeMD5:         algorithm = @"-md5";         break;
            case NSChecksumTypeRIPEMD160:   algorithm = @"-ripemd160";   break;
            case NSChecksumTypeSHA:         algorithm = @"-sha";         break;
            case NSChecksumTypeSHA1:        algorithm = @"-sha1";        break;
            case NSChecksumTypeSHA224:      algorithm = @"-sha224";      break;
            case NSChecksumTypeSHA256:      algorithm = @"-sha256";      break;
            case NSChecksumTypeSHA384:      algorithm = @"-sha384";      break;
            case NSChecksumTypeSHA512:      algorithm = @"-sha512";      break;
            case NSChecksumTypeWrirlpool:   algorithm = @"-whirlpool";   break;
            default: return nil;
        }
        
        NSString* output = [NSTask runCommand:@[@"openssl", @"dgst", algorithm, file]];
        if (!output) return nil;
        
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
    NSData* data = [NSData dataWithContentsOfFile:path];
    
    if (![data respondsToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        return [data base64Encoding];
    }
    
    return [data base64EncodedStringWithOptions:0];
}

@end
