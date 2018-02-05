//
//  VMMUserAuthorization.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 05/02/2018.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#import "VMMParentalControls.h"

#import "NSBundle+Extension.h"
#import "NSString+Extension.h"
#import "NSTask+Extension.h"

@implementation VMMParentalControls

+(BOOL)isEnabled
{
    @autoreleasepool
    {
        NSString* dsclOutputString = [NSTask runProgram:@"dscl" withFlags:@[@".", @"mcxexport", NSHomeDirectory()]];
        if (dsclOutputString == nil || dsclOutputString.length == 0) return FALSE;
    }
    
    return TRUE;
}

+(id)parentalControlsValueForAppWithDomain:(NSString*)appDomain keyName:(NSString*)keyName
{
    // Reference:
    // https://real-world-systems.com/docs/dslocal.db.html
    
    @autoreleasepool
    {
        NSString* dsclOutputString = [NSTask runProgram:@"dscl" withFlags:@[@".", @"mcxexport", NSHomeDirectory(), appDomain, keyName]];
        if (dsclOutputString == nil || dsclOutputString.length == 0) return nil;
        
        NSData* dsclOutputData = [dsclOutputString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dsclOutput = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:dsclOutputData];
        if ([dsclOutput isKindOfClass:[NSDictionary class]] == FALSE) return nil;
        
        NSDictionary* dict = dsclOutput[appDomain][keyName];
        if (dict == nil) return nil;
        
        return dict[@"value"];
    }
}

+(BOOL)iTunesMatureGamesAllowed
{
    VMMParentalControlsItunesGamesAgeRestriction value = [self iTunesAgeRestrictionForGames];
    return value == VMMParentalControlsItunesGamesAgeRestrictionNone ||
           value == VMMParentalControlsItunesGamesAgeRestriction17;
}
+(VMMParentalControlsItunesGamesAgeRestriction)iTunesAgeRestrictionForGames
{
    NSNumber* valueNumber = [self parentalControlsValueForAppWithDomain:@"com.apple.iTunes" keyName:@"gamesLimit"];
    if (valueNumber == nil || [valueNumber isKindOfClass:[NSNumber class]] == FALSE) return VMMParentalControlsItunesGamesAgeRestrictionNone;
    
    NSInteger value = valueNumber.integerValue;
    if (value == 0) return VMMParentalControlsItunesGamesAgeRestrictionNone;
    
    return (VMMParentalControlsItunesGamesAgeRestriction)value;
}

+(BOOL)isAppRestrictionEnabled
{
    NSNumber* valueNumber = [self parentalControlsValueForAppWithDomain:@"com.apple.applicationaccess.new" keyName:@"familyControlsEnabled"];
    if (valueNumber == nil || [valueNumber isKindOfClass:[NSNumber class]] == FALSE) return FALSE;
    
    return valueNumber.boolValue;
}
+(BOOL)isAppUseRestricted:(NSString*)appPath
{
    if ([self isAppRestrictionEnabled] == FALSE) return FALSE;
    
    NSArray* appsList = [self parentalControlsValueForAppWithDomain:@"com.apple.applicationaccess.new" keyName:@"whiteList"];
    
    for (NSDictionary* itemApp in appsList)
    {
        NSString* itemAppPath = itemApp[@"path"];
        if ([itemAppPath isEqualToString:appPath]) return FALSE;
    }
    
    return TRUE;
}

+(BOOL)isInternetUseRestricted
{
    NSNumber* whiteListEnabled = [self parentalControlsValueForAppWithDomain:@"com.apple.familycontrols.contentfilter"
                                                                     keyName:@"whitelistEnabled"];
    if (whiteListEnabled == nil || [whiteListEnabled isKindOfClass:[NSNumber class]] == FALSE) return FALSE;
    
    return whiteListEnabled.boolValue;
}
+(BOOL)isWebsiteAllowed:(NSString*)websiteAddress
{
    if ([self isInternetUseRestricted] == FALSE) return TRUE;
    
    NSArray* whiteList = [self parentalControlsValueForAppWithDomain:@"com.apple.familycontrols.contentfilter" keyName:@"siteWhitelist"];
    if (whiteList == nil || [whiteList isKindOfClass:[NSArray class]] == FALSE) return TRUE;
    
    NSArray* blackList = [self parentalControlsValueForAppWithDomain:@"com.apple.familycontrols.contentfilter" keyName:@"filterBlacklist"];
    if (blackList == nil || [blackList isKindOfClass:[NSArray class]] == FALSE) return TRUE;
    
    for (NSString* blackListItemAddress in blackList)
    {
        if ([websiteAddress hasPrefix:blackListItemAddress])
        {
            return FALSE;
        }
    }
    
    for (NSDictionary* whiteListItem in whiteList)
    {
        NSString* whiteListItemAddress = whiteListItem[@"address"];
        if (whiteListItemAddress != nil && [websiteAddress hasPrefix:whiteListItemAddress])
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

@end
