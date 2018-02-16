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

static NSString* _Nonnull const VMMParentalControlsAppDomainItunes            = @"com.apple.iTunes";
static NSString* _Nonnull const VMMParentalControlsAppDomainApplicationAccess = @"com.apple.applicationaccess.new";
static NSString* _Nonnull const VMMParentalControlsAppDomainContentFilter     = @"com.apple.familycontrols.contentfilter";

static NSString* _Nonnull const VMMParentalControlsItunesGamesAgeLimit                   = @"gamesLimit";
static NSString* _Nonnull const VMMParentalControlsApplicationAccessFamilyControlEnabled = @"familyControlsEnabled";
static NSString* _Nonnull const VMMParentalControlsApplicationAccessWhiteList            = @"whiteList";
static NSString* _Nonnull const VMMParentalControlsContentFilterWhiteListEnabled         = @"whitelistEnabled";
static NSString* _Nonnull const VMMParentalControlsContentFilterWhiteList                = @"siteWhitelist";
static NSString* _Nonnull const VMMParentalControlsContentFilterBlackList                = @"filterBlacklist";

static NSString* _Nonnull const VMMParentalControlsApplicationAccessWhiteListPath = @"path";
static NSString* _Nonnull const VMMParentalControlsContentFilterWhiteListAddress  = @"address";

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
        NSDictionary* dsclOutput;
        
        @try
        {
            dsclOutput = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:dsclOutputData];
        }
        @catch (NSException* exception)
        {
            return nil;
        }
        
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
    NSNumber* valueNumber = [self parentalControlsValueForAppWithDomain:VMMParentalControlsAppDomainItunes
                                                                keyName:VMMParentalControlsItunesGamesAgeLimit];
    if (valueNumber == nil || [valueNumber isKindOfClass:[NSNumber class]] == FALSE) return VMMParentalControlsItunesGamesAgeRestrictionNone;
    
    NSInteger value = valueNumber.integerValue;
    if (value == 0) return VMMParentalControlsItunesGamesAgeRestrictionNone;
    
    return (VMMParentalControlsItunesGamesAgeRestriction)value;
}

+(BOOL)isAppRestrictionEnabled
{
    NSNumber* valueNumber = [self parentalControlsValueForAppWithDomain:VMMParentalControlsAppDomainApplicationAccess
                                                                keyName:VMMParentalControlsApplicationAccessFamilyControlEnabled];
    if (valueNumber == nil || [valueNumber isKindOfClass:[NSNumber class]] == FALSE) return FALSE;
    
    return valueNumber.boolValue;
}
+(BOOL)isAppUseRestricted:(NSString*)appPath
{
    if ([self isAppRestrictionEnabled] == FALSE) return FALSE;
    
    NSArray* appsList = [self parentalControlsValueForAppWithDomain:VMMParentalControlsAppDomainApplicationAccess
                                                            keyName:VMMParentalControlsApplicationAccessWhiteList];
    
    for (NSDictionary* itemApp in appsList)
    {
        NSString* itemAppPath = itemApp[VMMParentalControlsApplicationAccessWhiteListPath];
        if ([itemAppPath isEqualToString:appPath]) return FALSE;
    }
    
    return TRUE;
}

+(BOOL)isInternetUseRestricted
{
    NSNumber* whiteListEnabled = [self parentalControlsValueForAppWithDomain:VMMParentalControlsAppDomainContentFilter
                                                                     keyName:VMMParentalControlsContentFilterWhiteListEnabled];
    if (whiteListEnabled == nil || [whiteListEnabled isKindOfClass:[NSNumber class]] == FALSE) return FALSE;
    
    return whiteListEnabled.boolValue;
}
+(BOOL)isWebsiteAllowed:(NSString*)websiteAddress
{
    if ([self isInternetUseRestricted] == FALSE) return TRUE;
    
    NSArray* whiteList = [self parentalControlsValueForAppWithDomain:VMMParentalControlsAppDomainContentFilter
                                                             keyName:VMMParentalControlsContentFilterWhiteList];
    if (whiteList == nil || [whiteList isKindOfClass:[NSArray class]] == FALSE) return TRUE;
    
    NSArray* blackList = [self parentalControlsValueForAppWithDomain:VMMParentalControlsAppDomainContentFilter
                                                             keyName:VMMParentalControlsContentFilterBlackList];
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
        NSString* whiteListItemAddress = whiteListItem[VMMParentalControlsContentFilterWhiteListAddress];
        if (whiteListItemAddress != nil && [websiteAddress hasPrefix:whiteListItemAddress])
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

@end
