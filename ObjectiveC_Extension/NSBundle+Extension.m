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

@interface NSBundle (VMMBundle_Interface)
@property (nonatomic, strong) NSString* _bundleName;
@property (nonatomic, strong) NSString* _bundlePathBeforeAppTranslocation;
@end

@implementation NSBundle (VMMBundle)

NSBundle* _originalMainBundle;

-(nonnull NSString*)bundleName
{
    if (self._bundleName != nil) return self._bundleName;
    
    self._bundleName = [self objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    if (!self._bundleName)
    {
        self._bundleName = [self objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (!self._bundleName)
    {
        // Reference:
        // https://stackoverflow.com/a/35322073/4370893
        
        self._bundleName = [NSString stringWithUTF8String:getprogname()];
    }
    
    if (!self._bundleName)
    {
        NSString* placeholder = @"App";
        NSString* bundlePath = [self bundlePath];
        self._bundleName = bundlePath ? bundlePath.stringByDeletingPathExtension.lastPathComponent : placeholder;
    }
    
    return self._bundleName;
}

-(BOOL)isAppTranslocationActive
{
    // App Translocation description:
    // http://lapcatsoftware.com/articles/app-translocation.html
    
    return IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR && [[self bundlePath] hasPrefix:@"/private/var/folders/"];
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
    if (self._bundlePathBeforeAppTranslocation != nil &&
        [[NSFileManager defaultManager] fileExistsAtPath:self._bundlePathBeforeAppTranslocation])
    {
        return self._bundlePathBeforeAppTranslocation;
    }
    
    NSString* appBinaryPath = [self executablePath];
    NSString* appBinaryChecksum = [[NSFileManager defaultManager] checksum:NSChecksumTypeMD5 ofFileAtPath:appBinaryPath];
    NSString* appBundleFileName = [[self bundlePath] lastPathComponent];
    if (!appBinaryChecksum || !appBundleFileName) return nil;
    
    NSString* applicationsFolderPath = @"/Applications/";
    NSString* desktopFolderPath = [NSString stringWithFormat:@"%@/Desktop/",NSHomeDirectory()];
    NSString* downloadsFolderPath = [NSString stringWithFormat:@"%@/Downloads/",NSHomeDirectory()];
    
    NSString* applicationInDesktopFolderPath = [desktopFolderPath stringByAppendingString:appBundleFileName];
    if ([self doesBundleAtPath:applicationInDesktopFolderPath executableMatchesWithMD5Checksum:appBinaryChecksum])
    {
        self._bundlePathBeforeAppTranslocation = applicationInDesktopFolderPath;
        return self._bundlePathBeforeAppTranslocation;
    }
    
    NSString* applicationInDownloadsFolderPath = [downloadsFolderPath stringByAppendingString:appBundleFileName];
    if ([self doesBundleAtPath:applicationInDownloadsFolderPath executableMatchesWithMD5Checksum:appBinaryChecksum])
    {
        self._bundlePathBeforeAppTranslocation = applicationInDownloadsFolderPath;
        return self._bundlePathBeforeAppTranslocation;
    }
    
    NSString* applicationInApplicationsFolderPath = [applicationsFolderPath stringByAppendingString:appBundleFileName];
    if ([self doesBundleAtPath:applicationInApplicationsFolderPath executableMatchesWithMD5Checksum:appBinaryChecksum])
    {
        self._bundlePathBeforeAppTranslocation = applicationInApplicationsFolderPath;
        return self._bundlePathBeforeAppTranslocation;
    }
    
    NSArray* desktopFilesMatches = [[NSFileManager defaultManager] subpathsAtPath:desktopFolderPath ofFilesNamed:appBundleFileName];
    for (NSString* desktopFilesMatch in desktopFilesMatches)
    {
        if ([self doesBundleAtPath:desktopFilesMatch executableMatchesWithMD5Checksum:appBinaryChecksum])
        {
            self._bundlePathBeforeAppTranslocation = desktopFilesMatch;
            return self._bundlePathBeforeAppTranslocation;
        }
    }
    
    NSArray* downloadsFilesMatches = [[NSFileManager defaultManager] subpathsAtPath:downloadsFolderPath ofFilesNamed:appBundleFileName];
    for (NSString* downloadsFilesMatch in downloadsFilesMatches)
    {
        if ([self doesBundleAtPath:downloadsFilesMatch executableMatchesWithMD5Checksum:appBinaryChecksum])
        {
            self._bundlePathBeforeAppTranslocation = downloadsFilesMatch;
            return self._bundlePathBeforeAppTranslocation;
        }
    }
    
    NSArray* applicationsFilesMatches = [[NSFileManager defaultManager] subpathsAtPath:applicationsFolderPath ofFilesNamed:appBundleFileName];
    for (NSString* applicationsFilesMatch in applicationsFilesMatches)
    {
        if ([self doesBundleAtPath:applicationsFilesMatch executableMatchesWithMD5Checksum:appBinaryChecksum])
        {
            self._bundlePathBeforeAppTranslocation = applicationsFilesMatch;
            return self._bundlePathBeforeAppTranslocation;
        }
    }
    
    return nil;
}

+(nullable NSBundle*)originalMainBundle
{
    if ([[NSBundle mainBundle] isAppTranslocationActive])
    {
        if (_originalMainBundle != nil && [[NSFileManager defaultManager] fileExistsAtPath:_originalMainBundle.bundlePath])
        {
            return _originalMainBundle;
        }
        
        NSString* originalPath = [[NSBundle mainBundle] bundlePathBeforeAppTranslocation];
        if (originalPath == nil)
        {
            return nil;
        }
        
        [NSTask runProgram:@"xattr" withFlags:@[@"-r",@"-d",@"com.apple.quarantine",originalPath]];
        
        _originalMainBundle = [NSBundle bundleWithPath:originalPath];
        return _originalMainBundle;
    }
    
    return [NSBundle mainBundle];
}

@end
