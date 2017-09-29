//
//  NSComputerInformation.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSComputerInformation.h"

#import "NSVersion.h"

#import "NSTask+Extension.h"
#import "NSArray+Extension.h"
#import "NSString+Extension.h"

#define GRAPHIC_CARD_NAME_KEY           @"Graphic card name"
#define CHIPSET_MODEL_KEY               @"Chipset Model"
#define BUS_KEY                         @"Bus"
#define BUILTIN_VIDEO_CARD_VRAM_KEY     @"VRAM (Dynamic, Max)"
#define PCI_OR_PCIE_VIDEO_CARD_VRAM_KEY @"VRAM (Total)"
#define VENDOR_KEY                      @"Vendor"
#define VENDOR_ID_KEY                   @"Vendor ID"
#define DEVICE_ID_KEY                   @"Device ID"

#define STAFF_GROUP_MEMBER_CODE @"20"

@implementation NSComputerInformation

static NSMutableDictionary* _computerGraphicCardDictionary;
static NSString* _computerGraphicCardType;
static NSString* _macOsVersion;
static NSNumber* _userIsMemberOfStaff;

+(NSString*)countryCode
{
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return countryCode ? countryCode : @"--";
}

+(NSDictionary*)graphicCardDictionary
{
    @synchronized(_computerGraphicCardDictionary)
    {
        if (_computerGraphicCardDictionary)
        {
            return _computerGraphicCardDictionary;
        }
        
        @autoreleasepool
        {
            NSMutableArray* graphicCards = [[NSMutableArray alloc] init];
            NSString* graphicCardName;
            int spacesCounter = 0;
            BOOL firstInput = YES;
            
            NSString* displayData = [NSTask runProgram:@"system_profiler" atRunPath:nil withFlags:@[@"SPDisplaysDataType"] wait:YES];
            if (!displayData) return nil;
            
            NSMutableDictionary* lastGraphicCardDict = [[NSMutableDictionary alloc] init];
            
            for (NSString* displayLine in [displayData componentsSeparatedByString:@"\n"])
            {
                spacesCounter = 0;
                NSString* displayLineNoSpaces = [displayLine copy];
                while ([displayLineNoSpaces hasPrefix:@" "])
                {
                    spacesCounter++;
                    displayLineNoSpaces = [displayLineNoSpaces substringFromIndex:1];
                }
                
                if (displayLineNoSpaces.length > 0 && spacesCounter < 8)
                {
                    if (spacesCounter == 6)
                    {
                        // Getting a graphic card attribute
                        NSArray* attr = [displayLineNoSpaces componentsSeparatedByString:@": "];
                        if (attr.count > 1) [lastGraphicCardDict setObject:attr[1] forKey:attr[0]];
                    }
                    
                    if (spacesCounter == 4)
                    {
                        // Adding a graphic card to the list
                        if (!firstInput) [graphicCards addObject:lastGraphicCardDict];
                        firstInput = NO;
                        
                        graphicCardName = [displayLineNoSpaces getFragmentAfter:nil andBefore:@":"];
                        lastGraphicCardDict = [[NSMutableDictionary alloc] init];
                        lastGraphicCardDict[GRAPHIC_CARD_NAME_KEY] = graphicCardName;
                    }
                }
            }
            
            // Adding last graphic card to the list
            [graphicCards addObject:lastGraphicCardDict];
            
            NSArray* cards = [graphicCards sortedDictionariesArrayWithKey:BUS_KEY
                                                    orderingByValuesOrder:@[@"PCIe",@"PCI",@"Built-In"]];
            _computerGraphicCardDictionary = [cards firstObject];
        }
        
        return _computerGraphicCardDictionary;
    }
    
    // to avoid compiler warning
    return nil;
}
+(NSString*)graphicCardModel
{
    NSDictionary* graphicCardDictionary = self.graphicCardDictionary;
    
    if (!graphicCardDictionary)
    {
        return nil;
    }
    
    NSString* videoCardName = graphicCardDictionary[GRAPHIC_CARD_NAME_KEY];
    NSString* chipsetModel  = graphicCardDictionary[CHIPSET_MODEL_KEY];
    
    if (!videoCardName || videoCardName.length < chipsetModel.length)
    {
        videoCardName = chipsetModel;
    }
    
    return chipsetModel;
}
+(NSString*)graphicCardType
{
    @synchronized(_computerGraphicCardType)
    {
        if (_computerGraphicCardType)
        {
            return _computerGraphicCardType;
        }
        
        @autoreleasepool
        {
            NSString* graphicCardModel = [self.graphicCardModel uppercaseString];
            
            if (!graphicCardModel) return nil;
            
            for (NSString* model in @[@"AMD",@"ATI",@"RADEON"])
            {
                if ([graphicCardModel contains:model]) _computerGraphicCardType = @"ATi/AMD";
            }
            
            for (NSString* model in @[@"NVIDIA",@"GEFORCE"])
            {
                if ([graphicCardModel contains:model]) _computerGraphicCardType = @"NVIDIA";
            }
            
            for (NSString* model in @[@"INTEL HD"])
            {
                if ([graphicCardModel contains:model]) _computerGraphicCardType = @"Intel HD";
            }
            
            for (NSString* model in @[@"INTEL IRIS"])
            {
                if ([graphicCardModel contains:model]) _computerGraphicCardType = @"Intel Iris";
            }
            
            for (NSString* model in @[@"GMA"])
            {
                if ([graphicCardModel contains:model]) _computerGraphicCardType = @"Intel GMA";
            }
        }
        
        return _computerGraphicCardType;
    }
    
    return nil;
}

+(NSString*)graphicCardDeviceID
{
    return self.graphicCardDictionary[DEVICE_ID_KEY];
}
+(NSString*)graphicCardVendorID
{
    NSDictionary* localVideoCard = self.graphicCardDictionary;
    NSString* localVendorID = localVideoCard[VENDOR_ID_KEY]; // eg. 0x10de
    
    if (!localVendorID)
    {
        localVendorID = localVideoCard[VENDOR_KEY]; // eg. NVIDIA (0x10de)
        if (localVendorID && [localVendorID contains:@"("])
        {
            localVendorID = [localVendorID getFragmentAfter:@"(" andBefore:@")"];
        }
    }
    
    return localVendorID;
}
+(NSString*)graphicCardMemorySize
{
    NSDictionary* gcDict = [self graphicCardDictionary];
    if (!gcDict) return nil;
    
    NSString* memSize = gcDict[PCI_OR_PCIE_VIDEO_CARD_VRAM_KEY];
    if (!memSize) memSize = gcDict[BUILTIN_VIDEO_CARD_VRAM_KEY];
    
    return memSize;
}

+(NSString*)macOsVersion
{
    @synchronized(_macOsVersion)
    {
        if (_macOsVersion)
        {
            return _macOsVersion;
        }
        
        @autoreleasepool
        {
            NSString* plistFile = @"/System/Library/CoreServices/SystemVersion.plist";
            NSDictionary *systemVersionDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
            NSString* version = systemVersionDictionary[@"ProductVersion"];
            
            if (!version)
            {
                _macOsVersion = [NSTask runProgram:@"sw_vers" atRunPath:nil withFlags:@[@"-productVersion"] wait:YES];
            }
            
            if (!version)
            {
                version = @"";
            }
            
            _macOsVersion = version;
        }
        
        return _macOsVersion;
    }
    return nil;
}
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(NSString*)version
{
    return [NSVersion compareVersionString:version withVersionString:self.macOsVersion] != NSOrderedAscending;
}

+(BOOL)isUserStaffGroupMember
{
    @synchronized([self class])
    {
        if (!_userIsMemberOfStaff)
        {
            @autoreleasepool
            {
                // Obtaining a string with the actual user groups
                NSString* usergroupsString = [NSTask runProgram:@"id" atRunPath:nil withFlags:@[@"-G"] wait:YES];
                
                // Turning the string into an array
                NSArray*  usergroupsArray  = [usergroupsString componentsSeparatedByString:@" "];
                
                // 20 is the ID of the Staff Group, so if it has 20, it's a staff member
                _userIsMemberOfStaff = @([usergroupsArray containsObject:STAFF_GROUP_MEMBER_CODE]);
            }
        }
        
        return [_userIsMemberOfStaff boolValue];
    }
    return NO;
}

@end

