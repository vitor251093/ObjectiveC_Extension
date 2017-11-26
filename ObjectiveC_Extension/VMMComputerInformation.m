//
//  VMMComputerInformation.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMComputerInformation.h"

#import "VMMVersion.h"

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

#define BUS_VALUE_PCIE     @"PCIe"
#define BUS_VALUE_PCI      @"PCI"
#define BUS_VALUE_BUILT_IN @"Built-In"

#define STAFF_GROUP_MEMBER_CODE @"20"

@implementation VMMComputerInformation

static NSMutableDictionary* _computerGraphicCardDictionary;
static NSString* _computerGraphicCardType;
static NSString* _macOsVersion;
static NSString* _macOsBuildVersion;
static NSNumber* _userIsMemberOfStaff;

static NSMutableDictionary* _macOsCompatibility;

+(NSMutableDictionary*)graphicCardDictionaryFromSystemProfilerOutput:(NSString*)displayData
{
    NSMutableArray* graphicCards = [[NSMutableArray alloc] init];
    NSString* graphicCardName;
    int spacesCounter = 0;
    BOOL firstInput = YES;
    
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
                                            orderingByValuesOrder:@[BUS_VALUE_PCIE, BUS_VALUE_PCI, BUS_VALUE_BUILT_IN]];
    return [cards firstObject];
}
+(NSMutableDictionary*)graphicCardDictionaryFromIOServiceMatch
{
    NSMutableDictionary* graphicCardDict = [[NSMutableDictionary alloc] init];
    
    CFMutableDictionaryRef matchDict = IOServiceMatching("IOPCIDevice");
    
    io_iterator_t iterator;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault,matchDict,&iterator) == kIOReturnSuccess)
    {
        io_registry_entry_t regEntry;
        while ((regEntry = IOIteratorNext(iterator)))
        {
            CFMutableDictionaryRef serviceDictionary;
            if (IORegistryEntryCreateCFProperties(regEntry, &serviceDictionary, kCFAllocatorDefault, kNilOptions) != kIOReturnSuccess)
            {
                IOObjectRelease(regEntry);
                continue;
            }
            
            NSMutableDictionary* service = (__bridge NSMutableDictionary*)serviceDictionary;
            
            if (service[@"model"] != nil && service[@"device-id"] != nil && service[@"vendor-id"] != nil)
            {
                NSData* gpuModel = service[@"model"];
                if (gpuModel != nil && [gpuModel isKindOfClass:[NSData class]])
                {
                    NSString *gpuModelString = [[NSString alloc] initWithData:gpuModel encoding:NSASCIIStringEncoding];
                    if (gpuModelString != nil)
                    {
                        graphicCardDict[GRAPHIC_CARD_NAME_KEY] = [gpuModelString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    }
                }
                
                NSData* deviceID = service[@"device-id"];
                if (deviceID != nil && [deviceID isKindOfClass:[NSData class]])
                {
                    NSString *deviceIDString = [[NSString alloc] initWithData:deviceID encoding:NSASCIIStringEncoding];
                    deviceIDString = [deviceIDString hexadecimalString];
                    
                    if (deviceIDString.length == 4)
                    {
                        deviceIDString = [NSString stringWithFormat:@"0x%@%@",[deviceIDString substringFromIndex:2],
                                          [deviceIDString substringToIndex:2]];
                        graphicCardDict[DEVICE_ID_KEY] = deviceIDString;
                    }
                }
                
                NSData* vendorID = service[@"vendor-id"];
                if (vendorID != nil && [vendorID isKindOfClass:[NSData class]])
                {
                    NSString *vendorIDString = [NSString stringWithFormat:@"%@",vendorID];
                    if (vendorIDString.length > 5)
                    {
                        vendorIDString = [vendorIDString substringWithRange:NSMakeRange(1, 4)];
                        vendorIDString = [NSString stringWithFormat:@"0x%@%@",[vendorIDString substringFromIndex:2],
                                          [vendorIDString substringToIndex:2]];
                        graphicCardDict[VENDOR_ID_KEY] = vendorIDString;
                    }
                }
                
                graphicCardDict[BUS_KEY] = BUS_VALUE_PCIE;
                NSData* hdaGfx = service[@"hda-gfx"];
                if (hdaGfx != nil && [hdaGfx isKindOfClass:[NSData class]])
                {
                    NSString* hdaGfxString = [[NSString alloc] initWithData:hdaGfx encoding:NSASCIIStringEncoding];
                    
                    if (hdaGfxString != nil)
                    {
                        graphicCardDict[BUS_KEY] = hdaGfxString;
                        
                        if ([hdaGfxString hasPrefix:@"onboard"])
                        {
                            graphicCardDict[BUS_KEY] = BUS_VALUE_BUILT_IN;
                        }
                    }
                }
            }
            
            CFRelease(serviceDictionary);
            IOObjectRelease(regEntry);
        }
        
        IOObjectRelease(iterator);
    }
    
    return graphicCardDict;
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
            NSString* displayData;
            
            displayData = [NSTask runCommand:@[@"system_profiler", @"SPDisplaysDataType"]];
            _computerGraphicCardDictionary = [self graphicCardDictionaryFromSystemProfilerOutput:displayData];
            if (_computerGraphicCardDictionary.count == 0)
            {
                displayData = [NSTask runCommand:@[@"/usr/sbin/system_profiler", @"SPDisplaysDataType"]];
                _computerGraphicCardDictionary = [self graphicCardDictionaryFromSystemProfilerOutput:displayData];
            }
            
            if (_computerGraphicCardDictionary.count == 0 || [self isGraphicCardDictionaryCompleteWithMemorySize:false] == false)
            {
                NSDictionary* computerGraphicCardDictionary = [self graphicCardDictionaryFromIOServiceMatch];
                [_computerGraphicCardDictionary addEntriesFromDictionary:computerGraphicCardDictionary];
            }
        }
        
        return _computerGraphicCardDictionary;
    }
    
    // to avoid compiler warning
    return nil;
}

+(BOOL)isGraphicCardDictionaryCompleteWithMemorySize:(BOOL)haveMemorySize
{
    if (self.graphicCardName == nil) return false;
    
    if (_computerGraphicCardDictionary[DEVICE_ID_KEY] == nil) return false;
    
    if (haveMemorySize)
    {
        if (_computerGraphicCardDictionary[PCI_OR_PCIE_VIDEO_CARD_VRAM_KEY] == nil &&
            _computerGraphicCardDictionary[BUILTIN_VIDEO_CARD_VRAM_KEY]     == nil) return false;
    }
    
    return true;
}

+(NSString*)graphicCardName
{
    NSDictionary* graphicCardDictionary = self.graphicCardDictionary;
    
    if (graphicCardDictionary == nil)
    {
        return nil;
    }
    
    NSString* videoCardName = graphicCardDictionary[GRAPHIC_CARD_NAME_KEY];
    NSString* chipsetModel  = graphicCardDictionary[CHIPSET_MODEL_KEY];
    
    if (!videoCardName || videoCardName.length < chipsetModel.length)
    {
        videoCardName = chipsetModel;
    }
    
    if ([videoCardName isEqualToString:@"Display"]) return nil;
    return videoCardName;
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
            NSString* graphicCardModel = [self.graphicCardName uppercaseString];
            if (graphicCardModel == nil) return nil;
            
            NSArray* graphicCardModelComponents = [graphicCardModel componentsSeparatedByString:@" "];
            
            if ([graphicCardModelComponents containsObject:@"INTEL"])
            {
                if ([graphicCardModelComponents containsObject:@"HD"])   _computerGraphicCardType = VMMGraphicCardTypeIntelHD;
                if ([graphicCardModelComponents containsObject:@"IRIS"]) _computerGraphicCardType = VMMGraphicCardTypeIntelIris;
            }
            
            if ([graphicCardModelComponents containsObject:@"GMA"]) _computerGraphicCardType = VMMGraphicCardTypeIntelGMA;
            
            for (NSString* model in @[@"AMD",@"ATI",@"RADEON"])
            {
                if ([graphicCardModelComponents containsObject:model]) _computerGraphicCardType = VMMGraphicCardTypeATiAMD;
            }
            
            for (NSString* model in @[@"NVIDIA",@"GEFORCE",@"NVS",@"QUADRO"])
            {
                if ([graphicCardModelComponents containsObject:model]) _computerGraphicCardType = VMMGraphicCardTypeNVIDIA;
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
    
    if (localVendorID == nil)
    {
        NSString* localVendor = localVideoCard[VENDOR_KEY]; // eg. NVIDIA (0x10de)
        if (localVendor && [localVendor contains:@"("])
        {
            localVendorID = [localVendor getFragmentAfter:@"(" andBefore:@")"];
        }
    }
    
    if (localVendorID == nil)
    {
        NSString* graphicCardType = [self graphicCardType];
        if (graphicCardType != nil)
        {
            if ([@[VMMGraphicCardTypeIntelHD, VMMGraphicCardTypeIntelIris, VMMGraphicCardTypeIntelGMA] containsObject:graphicCardType])
            {
                localVendorID = @"0x8086"; // Intel Vendor ID
            }
            
            if ([@[VMMGraphicCardTypeATiAMD] containsObject:graphicCardType])
            {
                localVendorID = @"0x1002"; // ATi/AMD Vendor ID
            }
            
            if ([@[VMMGraphicCardTypeNVIDIA] containsObject:graphicCardType])
            {
                localVendorID = @"0x10de"; // NVIDIA Vendor ID
            }
        }
    }
    
    return localVendorID;
}
+(NSUInteger)graphicCardMemorySizeInMegabytes
{
    NSDictionary* gcDict = [self graphicCardDictionary];
    if (!gcDict || gcDict.count == 0) return 0;
    
    NSString* memSize = [gcDict[PCI_OR_PCIE_VIDEO_CARD_VRAM_KEY] uppercaseString];
    if (memSize == nil) memSize = [gcDict[BUILTIN_VIDEO_CARD_VRAM_KEY] uppercaseString];
    
    int memSizeInt = 0;
    
    if ([memSize contains:@" MB"])
    {
        memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" MB"] intValue];
    }
    else if ([memSize contains:@" GB"])
    {
        memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" GB"] intValue]*1024;
    }
    
    return memSizeInt;
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
            NSString* macOsVersion;
            
            if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)])
            {
                NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
                if (version.majorVersion >= 10)
                {
                    macOsVersion = [NSString stringWithFormat:@"%ld.%ld.%ld",
                                    version.majorVersion, version.minorVersion, version.patchVersion];
                }
            }
            
            if (macOsVersion == nil)
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                SInt32 versMaj, versMin, versBugFix;
                Gestalt(gestaltSystemVersionMajor, &versMaj);
                Gestalt(gestaltSystemVersionMinor, &versMin);
                Gestalt(gestaltSystemVersionBugFix, &versBugFix);
                if (versMaj >= 10)
                {
                    macOsVersion = [NSString stringWithFormat:@"%d.%d.%d", versMaj, versMin, versBugFix];
                }
#pragma clang diagnostic pop
            }
            
            if (macOsVersion == nil)
            {
                macOsVersion = [NSTask runCommand:@[@"sw_vers", @"-productVersion"]];
            }
            
            if (macOsVersion == nil)
            {
                NSString* plistFile = @"/System/Library/CoreServices/SystemVersion.plist";
                NSDictionary *systemVersionDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
                macOsVersion = systemVersionDictionary[@"ProductVersion"];
            }
            
            if (macOsVersion == nil)
            {
                macOsVersion = @"";
            }
            
            _macOsVersion = macOsVersion;
        }
        
        return _macOsVersion;
    }
    
    return nil;
}
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(NSString*)version
{
    @synchronized (_macOsCompatibility)
    {
        if (_macOsCompatibility == nil)
        {
            _macOsCompatibility = [[NSMutableDictionary alloc] init];
        }
        
        if (_macOsCompatibility[version] != nil)
        {
            return [_macOsCompatibility[version] boolValue];
        }
        
        BOOL compatible = [VMMVersion compareVersionString:version withVersionString:self.macOsVersion] != VMMVersionCompareFirstIsNewest;
        _macOsCompatibility[version] = @(compatible);
        return compatible;
    }
    
    return false;
}

+(NSString*)macOsBuildVersion
{
    @synchronized(_macOsBuildVersion)
    {
        if (_macOsBuildVersion)
        {
            return _macOsBuildVersion;
        }
        
        @autoreleasepool
        {
            NSString* macOsBuildVersion = [NSTask runCommand:@[@"sw_vers", @"-buildVersion"]];
            
            if (macOsBuildVersion == nil)
            {
                NSString* plistFile = @"/System/Library/CoreServices/SystemVersion.plist";
                NSDictionary *systemVersionDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
                macOsBuildVersion = systemVersionDictionary[@"ProductBuildVersion"];
            }
            
            if (macOsBuildVersion == nil)
            {
                macOsBuildVersion = @"";
            }
            
            _macOsBuildVersion = macOsBuildVersion;
        }
        
        return _macOsBuildVersion;
    }
    
    return nil;
}

+(BOOL)isUserStaffGroupMember
{
    @synchronized(_userIsMemberOfStaff)
    {
        if (_userIsMemberOfStaff == nil)
        {
            @autoreleasepool
            {
                // Obtaining a string with the usergroups of the current user
                NSString* usergroupsString = [NSTask runCommand:@[@"id", @"-G"]];
                
                NSArray* usergroups = [usergroupsString componentsSeparatedByString:@" "];
                _userIsMemberOfStaff = @([usergroups containsObject:STAFF_GROUP_MEMBER_CODE]);
            }
        }
        
        return [_userIsMemberOfStaff boolValue];
    }
    
    return NO;
}

@end

