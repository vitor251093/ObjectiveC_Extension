//
//  VMMComputerInformation.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//
//
//  Obtaining VRAM with the API:
//  https://gist.github.com/ScrimpyCat/8043890
//

#import "VMMComputerInformation.h"

#import "VMMVersion.h"

#import "NSTask+Extension.h"
#import "NSArray+Extension.h"
#import "NSString+Extension.h"

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
                lastGraphicCardDict[VMMVideoCardNameKey] = graphicCardName;
            }
        }
    }
    
    // Adding last graphic card to the list
    [graphicCards addObject:lastGraphicCardDict];
    
    NSArray* cards = [graphicCards sortedDictionariesArrayWithKey:VMMVideoCardBusKey
                                            orderingByValuesOrder:@[VMMVideoCardBusPCIe, VMMVideoCardBusPCI, VMMVideoCardBusBuiltIn]];
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
            CFStringRef gpuName = IORegistryEntrySearchCFProperty(regEntry, kIOServicePlane, CFSTR("IOName"),
                                                                  kCFAllocatorDefault, kNilOptions);
            if (gpuName && CFStringCompare(gpuName, CFSTR("display"), 0) == kCFCompareEqualTo)
            {
                CFMutableDictionaryRef serviceDictionary;
                if (IORegistryEntryCreateCFProperties(regEntry, &serviceDictionary, kCFAllocatorDefault, kNilOptions) != kIOReturnSuccess)
                {
                    IOObjectRelease(regEntry);
                    continue;
                }
                NSMutableDictionary* service = (__bridge NSMutableDictionary*)serviceDictionary;
                
                NSData* gpuModel = service[@"model"];
                if (gpuModel != nil && [gpuModel isKindOfClass:[NSData class]])
                {
                    NSString *gpuModelString = [[NSString alloc] initWithData:gpuModel encoding:NSASCIIStringEncoding];
                    if (gpuModelString != nil)
                    {
                        graphicCardDict[VMMVideoCardChipsetModelKey] = [gpuModelString stringByReplacingOccurrencesOfString:@"\0"
                                                                                                                 withString:@""];
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
                        graphicCardDict[VMMVideoCardDeviceIDKey] = deviceIDString;
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
                        graphicCardDict[VMMVideoCardVendorIDKey] = vendorIDString;
                    }
                }
                
                graphicCardDict[VMMVideoCardBusKey] = VMMVideoCardBusBuiltIn;
                
                
                _Bool vramValueInBytes = TRUE;
                CFTypeRef vramSize = IORegistryEntrySearchCFProperty(regEntry, kIOServicePlane, CFSTR("VRAM,totalsize"),
                                                                     kCFAllocatorDefault, kIORegistryIterateRecursively);
                if (!vramSize)
                {
                    vramValueInBytes = FALSE;
                    vramSize = IORegistryEntrySearchCFProperty(regEntry, kIOServicePlane, CFSTR("VRAM,totalMB"),
                                                               kCFAllocatorDefault, kIORegistryIterateRecursively);
                }
                
                if (vramSize)
                {
                    mach_vm_size_t size = 0;
                    CFTypeID Type = CFGetTypeID(vramSize);
                    if (Type == CFDataGetTypeID())
                    {
                        if (CFDataGetLength(vramSize) == sizeof(uint32_t))
                        {
                            size = (mach_vm_size_t)*(const uint32_t*)CFDataGetBytePtr(vramSize);
                        }
                        else
                        {
                            size = *(const uint64_t*)CFDataGetBytePtr(vramSize);
                        }
                    }
                    else if (Type == CFNumberGetTypeID()) CFNumberGetValue(vramSize, kCFNumberSInt64Type, &size);
                    
                    if (vramValueInBytes) size >>= 20;
                    
                    graphicCardDict[VMMVideoCardMemorySizeBuiltInKey] = [NSString stringWithFormat:@"%llu MB", size];
                }
                
                CFRelease(serviceDictionary);
            }
            
            CFRelease(gpuName);
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
                NSMutableDictionary* computerGraphicCardDictionary = [[self graphicCardDictionaryFromIOServiceMatch] mutableCopy];
                [computerGraphicCardDictionary addEntriesFromDictionary:_computerGraphicCardDictionary];
                _computerGraphicCardDictionary = computerGraphicCardDictionary;
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
    
    if (_computerGraphicCardDictionary[VMMVideoCardDeviceIDKey] == nil) return false;
    
    if (haveMemorySize)
    {
        if (_computerGraphicCardDictionary[VMMVideoCardMemorySizePciOrPcieKey] == nil &&
            _computerGraphicCardDictionary[VMMVideoCardMemorySizeBuiltInKey]   == nil) return false;
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
    
    NSString* videoCardName = graphicCardDictionary[VMMVideoCardNameKey];
    NSString* chipsetModel  = graphicCardDictionary[VMMVideoCardChipsetModelKey];
    BOOL validVideoCardName = (videoCardName != nil && [videoCardName isEqualToString:@"Display"] == false);
    BOOL validChipsetModel  = (chipsetModel  != nil && [chipsetModel  isEqualToString:@"Display"] == false);
    
    if (validVideoCardName == false)
    {
        videoCardName = nil;
    }
    
    if (validChipsetModel == true && (validVideoCardName == false || videoCardName.length < chipsetModel.length))
    {
        videoCardName = chipsetModel;
    }
    
    return videoCardName;
}
+(NSString*)graphicCardType
{
    @synchronized(_computerGraphicCardType)
    {
        if (_computerGraphicCardType != nil)
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
                if ([graphicCardModelComponents containsObject:@"HD"])   _computerGraphicCardType = VMMVideoCardTypeIntelHD;
                if ([graphicCardModelComponents containsObject:@"IRIS"]) _computerGraphicCardType = VMMVideoCardTypeIntelIris;
            }
            
            if ([graphicCardModelComponents containsObject:@"GMA"]) _computerGraphicCardType = VMMVideoCardTypeIntelGMA;
            
            for (NSString* model in @[@"AMD",@"ATI",@"RADEON"])
            {
                if ([graphicCardModelComponents containsObject:model]) _computerGraphicCardType = VMMVideoCardTypeATiAMD;
            }
            
            for (NSString* model in @[@"NVIDIA",@"GEFORCE",@"NVS",@"QUADRO"])
            {
                if ([graphicCardModelComponents containsObject:model]) _computerGraphicCardType = VMMVideoCardTypeNVIDIA;
            }
            
            if (_computerGraphicCardType == nil)
            {
                NSString* localVendorID = [self graphicCardVendorIDFromVendorAndVendorIDKeysOnly];
                if ([localVendorID isEqualToString:@"0x1002"]) _computerGraphicCardType = VMMVideoCardTypeATiAMD;
                if ([localVendorID isEqualToString:@"0x10de"]) _computerGraphicCardType = VMMVideoCardTypeNVIDIA;
            }
        }
        
        return _computerGraphicCardType;
    }
    
    return nil;
}

+(NSString*)graphicCardDeviceID
{
    return self.graphicCardDictionary[VMMVideoCardDeviceIDKey];
}

+(NSString*)graphicCardVendorIDFromVendorAndVendorIDKeysOnly
{
    NSDictionary* localVideoCard = self.graphicCardDictionary;
    
    NSString* localVendorID = localVideoCard[VMMVideoCardVendorIDKey]; // eg. 0x10de
    
    if (localVendorID == nil)
    {
        NSString* localVendor = localVideoCard[VMMVideoCardVendorKey]; // eg. NVIDIA (0x10de)
        if (localVendor && [localVendor contains:@"("])
        {
            localVendorID = [localVendor getFragmentAfter:@"(" andBefore:@")"];
        }
    }
    
    return localVendorID;
}
+(NSString*)graphicCardVendorID
{
    NSString* localVendorID = [self graphicCardVendorIDFromVendorAndVendorIDKeysOnly];
    
    if (localVendorID == nil)
    {
        NSString* graphicCardType = [self graphicCardType];
        if (graphicCardType != nil)
        {
            if ([@[VMMVideoCardTypeIntelHD, VMMVideoCardTypeIntelIris, VMMVideoCardTypeIntelGMA] containsObject:graphicCardType])
            {
                localVendorID = @"0x8086"; // Intel Vendor ID
            }
            
            if ([@[VMMVideoCardTypeATiAMD] containsObject:graphicCardType])
            {
                localVendorID = @"0x1002"; // ATi/AMD Vendor ID
            }
            
            if ([@[VMMVideoCardTypeNVIDIA] containsObject:graphicCardType])
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
    
    NSString* memSize = [gcDict[VMMVideoCardMemorySizePciOrPcieKey] uppercaseString];
    if (memSize == nil) memSize = [gcDict[VMMVideoCardMemorySizeBuiltInKey] uppercaseString];
    
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

