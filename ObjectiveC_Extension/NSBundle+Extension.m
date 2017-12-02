//
//  NSBundle+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 25/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSBundle+Extension.h"

#import "NSTask+Extension.h"
#import "NSFileManager+Extension.h"
#import "VMMComputerInformation.h"

#include <stdlib.h>

@implementation NSBundle (VMMBundle)

NSString* _bundleName;
NSString* _bundlePathBeforeAppTranslocation;

-(NSString*)bundleName
{
    if (_bundleName != nil) return _bundleName;
    
    _bundleName = [self objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    if (!_bundleName)
    {
        _bundleName = [self objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (!_bundleName)
    {
        // Reference:
        // https://stackoverflow.com/a/35322073/4370893
        
        _bundleName = [NSString stringWithUTF8String:getprogname()];
    }
    
    if (!_bundleName)
    {
        NSString* placeholder = @"App";
        NSString* bundlePath = [self bundlePath];
        _bundleName = bundlePath ? bundlePath.stringByDeletingPathExtension.lastPathComponent : placeholder;
    }
    
    return _bundleName;
}

-(BOOL)isAppTranslocationActive
{
    // App Translocation description:
    // http://lapcatsoftware.com/articles/app-translocation.html
    
    if (IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR == false) return false;
    
    if ([[self bundlePath] hasPrefix:@"/private/var/folders/"]) return true;
    
    return false;
}

-(BOOL)doesBundleAtPath:(NSString*)bundlePath executableMatchesWithMD5Checksum:(NSString*)checksum
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath] == false) return false;
    
    NSBundle* applicationInDesktopBundle = [[NSBundle alloc] initWithPath:bundlePath];
    NSString* applicationInDesktopExecutablePath = [applicationInDesktopBundle executablePath];
    NSString* applicationInDesktopBinaryChecksum = [[NSFileManager defaultManager] checksum:NSChecksumTypeMD5
                                                                               ofFileAtPath:applicationInDesktopExecutablePath];
    
    return [applicationInDesktopBinaryChecksum isEqualToString:checksum];
}
-(NSString*)bundlePathBeforeAppTranslocation
{
    if (_bundlePathBeforeAppTranslocation != nil && [[NSFileManager defaultManager] fileExistsAtPath:_bundlePathBeforeAppTranslocation])
    {
        return _bundlePathBeforeAppTranslocation;
    }
    
    NSString* appBinaryPath = [self executablePath];
    NSString* appBinaryChecksum = [[NSFileManager defaultManager] checksum:NSChecksumTypeMD5 ofFileAtPath:appBinaryPath];
    NSString* appBundleFileName = [[self bundlePath] lastPathComponent];
    if (!appBinaryChecksum && !appBundleFileName) return nil;
    
    NSString* applicationsFolderPath = @"/Applications/";
    NSString* desktopFolderPath = [NSString stringWithFormat:@"%@/Desktop/",NSHomeDirectory()];
    NSString* downloadsFolderPath = [NSString stringWithFormat:@"%@/Downloads/",NSHomeDirectory()];
    
    NSString* applicationInDesktopFolderPath = [desktopFolderPath stringByAppendingString:appBundleFileName];
    if ([self doesBundleAtPath:applicationInDesktopFolderPath executableMatchesWithMD5Checksum:appBinaryChecksum])
    {
        _bundlePathBeforeAppTranslocation = applicationInDesktopFolderPath;
        return _bundlePathBeforeAppTranslocation;
    }
    
    NSString* applicationInDownloadsFolderPath = [downloadsFolderPath stringByAppendingString:appBundleFileName];
    if ([self doesBundleAtPath:applicationInDownloadsFolderPath executableMatchesWithMD5Checksum:appBinaryChecksum])
    {
        _bundlePathBeforeAppTranslocation = applicationInDownloadsFolderPath;
        return _bundlePathBeforeAppTranslocation;
    }
    
    NSString* applicationInApplicationsFolderPath = [applicationsFolderPath stringByAppendingString:appBundleFileName];
    if ([self doesBundleAtPath:applicationInApplicationsFolderPath executableMatchesWithMD5Checksum:appBinaryChecksum])
    {
        _bundlePathBeforeAppTranslocation = applicationInApplicationsFolderPath;
        return _bundlePathBeforeAppTranslocation;
    }
    
    NSArray* desktopFilesMatches = [[NSFileManager defaultManager] subpathsAtPath:desktopFolderPath ofFilesNamed:appBundleFileName];
    for (NSString* desktopFilesMatch in desktopFilesMatches)
    {
        if ([self doesBundleAtPath:desktopFilesMatch executableMatchesWithMD5Checksum:appBinaryChecksum])
        {
            _bundlePathBeforeAppTranslocation = desktopFilesMatch;
            return _bundlePathBeforeAppTranslocation;
        }
    }
    
    NSArray* downloadsFilesMatches = [[NSFileManager defaultManager] subpathsAtPath:downloadsFolderPath ofFilesNamed:appBundleFileName];
    for (NSString* downloadsFilesMatch in downloadsFilesMatches)
    {
        if ([self doesBundleAtPath:downloadsFilesMatch executableMatchesWithMD5Checksum:appBinaryChecksum])
        {
            _bundlePathBeforeAppTranslocation = downloadsFilesMatch;
            return _bundlePathBeforeAppTranslocation;
        }
    }
    
    NSArray* applicationsFilesMatches = [[NSFileManager defaultManager] subpathsAtPath:applicationsFolderPath ofFilesNamed:appBundleFileName];
    for (NSString* applicationsFilesMatch in applicationsFilesMatches)
    {
        if ([self doesBundleAtPath:applicationsFilesMatch executableMatchesWithMD5Checksum:appBinaryChecksum])
        {
            _bundlePathBeforeAppTranslocation = applicationsFilesMatch;
            return _bundlePathBeforeAppTranslocation;
        }
    }
    
    return nil;
}

+(NSBundle*)originalMainBundle
{
    if ([[NSBundle mainBundle] isAppTranslocationActive])
    {
        NSString* originalPath = [[NSBundle mainBundle] bundlePathBeforeAppTranslocation];
        
        [NSTask runProgram:@"xattr" withFlags:@[@"-r",@"-d",@"com.apple.quarantine",originalPath]];
        
        return [[NSBundle alloc] initWithPath:originalPath];
    }
    
    return [NSBundle mainBundle];
}

@end
