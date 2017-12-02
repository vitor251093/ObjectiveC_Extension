//
//  NSFileManager+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSFileManager_Extension_Class
#define NSFileManager_Extension_Class

#import <Foundation/Foundation.h>

typedef enum NSChecksumType
{
    NSChecksumTypeGOSTMac,
    NSChecksumTypeStreebog512,
    NSChecksumTypeStreebog256,
    NSChecksumTypeGOST94,
    NSChecksumTypeMD4,
    NSChecksumTypeMD5,
    NSChecksumTypeRIPEMD160,
    NSChecksumTypeSHA,
    NSChecksumTypeSHA1,
    NSChecksumTypeSHA224,
    NSChecksumTypeSHA256,
    NSChecksumTypeSHA384,
    NSChecksumTypeSHA512,
    NSChecksumTypeWrirlpool
} NSChecksumType;

@interface NSFileManager (VMMFileManager)

-(BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath;
-(BOOL)createDirectoryAtPath:(NSString*)path withIntermediateDirectories:(BOOL)interDirs;
-(BOOL)createEmptyFileAtPath:(NSString*)path;

-(BOOL)moveItemAtPath:(NSString*)path toPath:(NSString*)destination;
-(BOOL)copyItemAtPath:(NSString*)path toPath:(NSString*)destination;
-(BOOL)removeItemAtPath:(NSString*)path;
-(BOOL)directoryExistsAtPath:(NSString*)path;
-(BOOL)regularFileExistsAtPath:(NSString*)path;
-(NSArray<NSString*>*)contentsOfDirectoryAtPath:(NSString*)path;
-(NSArray<NSString*>*)subpathsAtPath:(NSString *)path ofFilesNamed:(NSString*)fileName;
-(NSString*)destinationOfSymbolicLinkAtPath:(NSString *)path;

-(NSString*)userReadablePathForItemAtPath:(NSString*)path joinedByString:(NSString*)join;

-(unsigned long long int)sizeOfRegularFileAtPath:(NSString*)path;
-(unsigned long long int)sizeOfDirectoryAtPath:(NSString*)path;

-(NSString*)checksum:(NSChecksumType)checksum ofFileAtPath:(NSString*)file;

-(NSString*)base64OfFileAtPath:(NSString*)path;

@end

#endif
