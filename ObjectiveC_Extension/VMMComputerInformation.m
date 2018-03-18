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
#import "VMMPropertyList.h"

#import "NSTask+Extension.h"
#import "NSArray+Extension.h"
#import "NSString+Extension.h"
#import "NSFileManager+Extension.h"
#import "NSMutableArray+Extension.h"

@implementation VMMComputerInformation

static unsigned int _systemProfilerRequestTimeOut = 15;
static unsigned int _appleSupportMacModelRequestTimeOut = 5;

static NSMutableDictionary* _hardwareDictionary;
static NSMutableArray<VMMVideoCard*>* _videoCards;

static NSString* _macModel;
static NSString* _processorNameAndSpeed;

static NSString* _macOsVersion;
static NSString* _macOsBuildVersion;
static NSArray* _userGroups;

static NSMutableDictionary* _macOsCompatibility;

+(NSMutableDictionary*)hardwareDictionaryFromSystemProfilerOutput:(NSString*)hardwareOutput
{
    NSArray* hardwareArray = [VMMPropertyList propertyListWithUnarchivedString:hardwareOutput];
    if (hardwareArray == nil)
    {
        return [[NSMutableDictionary alloc] init];
    }
    
    hardwareArray = hardwareArray[0][@"_items"];
    if (hardwareArray == nil)
    {
        return [[NSMutableDictionary alloc] init];
    }
    
    return [[hardwareArray firstObject] mutableCopy];
}
+(nullable NSDictionary*)hardwareDictionary
{
    @synchronized(_hardwareDictionary)
    {
        if (_hardwareDictionary)
        {
            return _hardwareDictionary;
        }
        
        @autoreleasepool
        {
            NSString* displayData;
            
            displayData = [NSTask runProgram:@"system_profiler" withFlags:@[@"-xml",@"SPHardwareDataType"]
                      waitingForTimeInterval:_systemProfilerRequestTimeOut];
            _hardwareDictionary = [self hardwareDictionaryFromSystemProfilerOutput:displayData];
            if (_hardwareDictionary.count == 0)
            {
                displayData = [NSTask runProgram:@"/usr/sbin/system_profiler" withFlags:@[@"-xml",@"SPHardwareDataType"]
                          waitingForTimeInterval:_systemProfilerRequestTimeOut];
                _hardwareDictionary = [self hardwareDictionaryFromSystemProfilerOutput:displayData];
            }
        }
        
        return _hardwareDictionary;
    }
}

+(NSString*)stringByRemovingSpacesInBegginingOfString:(NSString*)string
{
    while ([string hasPrefix:@" "]) string = [string substringFromIndex:1];
    return string;
}

+(long long int)hardDiskSize
{
    NSDictionary *hdAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:nil];
    long long int fileSystemSize = [[hdAttributes objectForKey:NSFileSystemSize] longLongValue];
    return fileSystemSize;
}
+(long long int)hardDiskFreeSize
{
    NSDictionary *hdAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:nil];
    long long int fileSystemFreeSize = [[hdAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    return fileSystemFreeSize;
}
+(long long int)hardDiskUsedSize
{
    return self.hardDiskSize - self.hardDiskFreeSize;
}
+(long long int)ramMemorySize
{
    return [[NSProcessInfo processInfo] physicalMemory];
}
+(long long int)ramMemoryFreeSize
{
    return self.ramMemorySize - self.ramMemoryUsedSize;
}
+(long long int)ramMemoryUsedSize
{
    // TODO: Not confirmed to be accurate yet
    
    NSString* vm_stat = [NSTask runCommand:@[@"vm_stat"]];
    
    int pageSize = getpagesize();
    NSString* activeSizeWithSpaces     = [vm_stat getFragmentAfter:@"Pages active:"                 andBefore:@"."];
    NSString* wiredSizeWithSpaces      = [vm_stat getFragmentAfter:@"Pages wired down:"             andBefore:@"."];
    NSString* purgeableSizeWithSpaces  = [vm_stat getFragmentAfter:@"Pages purgeable:"              andBefore:@"."];
    NSString* compressedSizeWithSpaces = [vm_stat getFragmentAfter:@"Pages occupied by compressor:" andBefore:@"."];
    
    if (activeSizeWithSpaces == nil)     activeSizeWithSpaces     = @"0";
    if (wiredSizeWithSpaces == nil)      wiredSizeWithSpaces      = @"0";
    if (purgeableSizeWithSpaces == nil)  purgeableSizeWithSpaces  = @"0";
    if (compressedSizeWithSpaces == nil) compressedSizeWithSpaces = @"0";
    
    activeSizeWithSpaces     = [self stringByRemovingSpacesInBegginingOfString:activeSizeWithSpaces];
    wiredSizeWithSpaces      = [self stringByRemovingSpacesInBegginingOfString:wiredSizeWithSpaces];
    purgeableSizeWithSpaces  = [self stringByRemovingSpacesInBegginingOfString:purgeableSizeWithSpaces];
    compressedSizeWithSpaces = [self stringByRemovingSpacesInBegginingOfString:compressedSizeWithSpaces];
    
    return ([activeSizeWithSpaces longLongValue]    + [wiredSizeWithSpaces longLongValue] +
            [purgeableSizeWithSpaces longLongValue] + [compressedSizeWithSpaces longLongValue])*pageSize;
}
+(nullable NSString*)processorNameAndSpeed
{
    @synchronized(_processorNameAndSpeed)
    {
        if (_processorNameAndSpeed != nil)
        {
            return _processorNameAndSpeed;
        }
        
        NSString* processorName  = self.hardwareDictionary[@"cpu_type"];
        NSString* processorSpeed = self.hardwareDictionary[@"current_processor_speed"];
        
        if (processorName != nil && processorName.length > 0)
        {
            _processorNameAndSpeed = [NSString stringWithFormat:@"%@ %@",processorName,processorSpeed];
            return _processorNameAndSpeed;
        }
        
        processorName = [NSTask runCommand:@[@"sysctl", @"-n", @"machdep.cpu.brand_string"]];
        
        if (processorName != nil && processorName.length > 0)
        {
            while ([processorName contains:@"  "])
            {
                processorName = [processorName stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            }
            
            _processorNameAndSpeed = processorName;
            return _processorNameAndSpeed;
        }
        
        _processorNameAndSpeed = processorSpeed;
        return _processorNameAndSpeed;
    }
}
+(double)processorUsage
{
    // TODO: Not confirmed to be accurate yet
    
    NSString* ps = [NSTask runCommand:@[@"ps", @"-A", @"-o" ,@"%cpu"]];
    ps = [ps stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    double cpuUsageSum = 0.0;
    for (NSString* process in [ps componentsSeparatedByString:@"\n"])
    {
        cpuUsageSum += [[self stringByRemovingSpacesInBegginingOfString:process] doubleValue];
    }
    
    NSString* numberOfCpus = [NSTask runCommand:@[@"sysctl", @"hw.physicalcpu"]];
    numberOfCpus = [numberOfCpus getFragmentAfter:@" " andBefore:nil];
    if (!numberOfCpus || numberOfCpus.intValue == 0) return -1;
    
    cpuUsageSum = cpuUsageSum/numberOfCpus.intValue;
    return cpuUsageSum / 100;
}
+(nullable NSString*)macModel
{
    @synchronized(_macModel)
    {
        if (_macModel != nil)
        {
            return _macModel;
        }
        
        @autoreleasepool
        {
            NSString* otherOption;
            
            NSString* sysProfFile = [NSString stringWithFormat:@"%@/Library/Preferences/com.apple.SystemProfiler.plist",NSHomeDirectory()];
            
            if ([[NSFileManager defaultManager] regularFileExistsAtPath:sysProfFile])
            {
                NSDictionary* sysProf = [NSDictionary dictionaryWithContentsOfFile:sysProfFile];
                
                if (sysProf != nil)
                {
                    NSDictionary* cpuNames = sysProf[@"CPU Names"];
                    
                    if (cpuNames != nil && [cpuNames isKindOfClass:[NSDictionary class]] && cpuNames.allKeys.count >= 1)
                    {
                        otherOption = cpuNames[cpuNames.allKeys.lastObject];
                        
                        for (NSString* cpuName in cpuNames.allValues)
                        {
                            if ([cpuName contains:@"inch"])
                            {
                                _macModel = cpuName;
                                return _macModel;
                            }
                        }
                    }
                }
            }
            
            NSString* macSerial = self.hardwareDictionary[@"serial_number"];
            
            if (macSerial != nil && macSerial.length >= 8)
            {
                // Depending on if your serial numer is 11 or 12 characters long; take the last 3 or 4 characters
                macSerial = [macSerial substringFromIndex:8];
                
                NSString* macInfoURL = [NSString stringWithFormat:@"http://support-sp.apple.com/sp/product?cc=%@",macSerial];
                NSString* macInfo = [NSString stringWithContentsOfURL:[NSURL URLWithString:macInfoURL] encoding:NSUTF8StringEncoding
                                                      timeoutInterval:_appleSupportMacModelRequestTimeOut];
                
                if (macInfo != nil && macInfo.length > 0)
                {
                    _macModel = [macInfo getFragmentAfter:@"<configCode>" andBefore:@"</configCode>"];
                    
                    if (_macModel != nil && _macModel.length > 0)
                    {
                        return _macModel;
                    }
                    else
                    {
                        _macModel = nil;
                    }
                }
            }
            
            if (otherOption != nil)
            {
                _macModel = otherOption;
                return _macModel;
            }
            
            _macModel = self.hardwareDictionary[@"machine_model"];
            return _macModel;
        }
        
        return nil;
    }
}


+(NSArray<VMMVideoCard*>* _Nullable)videoCardsFromSystemProfilerOutput:(NSString* _Nonnull)displayOutput
{
    NSArray* displayArray = [VMMPropertyList propertyListWithUnarchivedString:displayOutput];
    if (displayArray == nil)
    {
        return nil;
    }
    
    displayArray = displayArray[0][@"_items"];
    if (displayArray == nil)
    {
        return nil;
    }
    
    NSMutableArray* cards = [displayArray mutableCopy];
    
    [cards replaceObjectsWithVariation:^id _Nullable(NSDictionary*  _Nonnull object, NSUInteger index)
    {
        return [[VMMVideoCard alloc] initVideoCardWithDictionary:object];
    }];
    
    [cards removeObject:[NSNull null]];
    
    return cards;
}
+(NSArray<VMMVideoCard*>*)videoCardsFromIOServiceMatch
{
    NSMutableArray* graphicCardDicts = [[NSMutableArray alloc] init];
    
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
                NSMutableDictionary* graphicCardDict = [[NSMutableDictionary alloc] init];
                
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
                        graphicCardDict[VMMVideoCardNameKey] = [gpuModelString stringByReplacingOccurrencesOfString:@"\0"
                                                                                                         withString:@""];
                    }
                }
                
                NSData* deviceID = service[@"device-id"];
                if (deviceID != nil && [deviceID isKindOfClass:[NSData class]])
                {
                    NSString *deviceIDString = [[NSString alloc] initWithData:deviceID encoding:NSASCIIStringEncoding];
                    graphicCardDict[@"RawDeviceID"] = deviceIDString;
                    
                    deviceIDString = [deviceIDString hexadecimalUTF8String];
                    
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
                        vendorIDString = vendorIDString.lowercaseString;
                        if ([vendorIDString matchesWithRegex:@"0x[0-9a-f]{4}"])
                        {
                            graphicCardDict[VMMVideoCardVendorIDKey] = vendorIDString;
                            vendorIDString = nil;
                        }
                    }
                    
                    if (vendorIDString != nil)
                    {
                        graphicCardDict[VMMVideoCardVendorKey] = vendorIDString;
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
                    CFTypeID type = CFGetTypeID(vramSize);
                    if (type == CFDataGetTypeID())
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
                    else if (type == CFNumberGetTypeID()) CFNumberGetValue(vramSize, kCFNumberSInt64Type, &size);
                    
                    if (vramValueInBytes) size >>= 20;
                    
                    graphicCardDict[VMMVideoCardMemorySizeBuiltInKey] = [NSString stringWithFormat:@"%llu MB", size];
                }
                
                if (vramSize != NULL) CFRelease(vramSize);
                CFRelease(serviceDictionary);
                
                [graphicCardDicts addObject:graphicCardDict];
            }
            
            if (gpuName != NULL) CFRelease(gpuName);
            IOObjectRelease(regEntry);
        }
        
        IOObjectRelease(iterator);
    }
    
    [graphicCardDicts replaceObjectsWithVariation:^VMMVideoCard* _Nonnull(NSDictionary* _Nonnull object, NSUInteger index)
    {
        return [[VMMVideoCard alloc] initVideoCardWithDictionary:object];
    }];
    
    [graphicCardDicts removeObject:[NSNull null]];
    
    return graphicCardDicts;
}
+(nonnull NSArray<VMMVideoCard*>*)videoCards
{
    @synchronized(_videoCards)
    {
        if (_videoCards)
        {
            return _videoCards;
        }
        
        @autoreleasepool
        {
            NSString* displayData;
            
            displayData = [NSTask runProgram:@"system_profiler" withFlags:@[@"-xml",@"SPDisplaysDataType"]
                      waitingForTimeInterval:_systemProfilerRequestTimeOut];
            _videoCards = [[self videoCardsFromSystemProfilerOutput:displayData] mutableCopy];
            if (_videoCards == nil || _videoCards.count == 0)
            {
                displayData = [NSTask runProgram:@"/usr/sbin/system_profiler" withFlags:@[@"-xml",@"SPDisplaysDataType"]
                          waitingForTimeInterval:_systemProfilerRequestTimeOut];
                _videoCards = [[self videoCardsFromSystemProfilerOutput:displayData] mutableCopy];
            }
            
            if (_videoCards == nil || _videoCards.count == 0 || [self anyVideoCardDictionaryIsComplete] == false)
            {
                NSMutableArray* computerGraphicCardDictionary = [[self videoCardsFromIOServiceMatch] mutableCopy];
                if (_videoCards != nil) [computerGraphicCardDictionary addObjectsFromArray:_videoCards];
                _videoCards = computerGraphicCardDictionary;
            }
            
            
            NSArray* vendorIDOrder = @[VMMVideoCardVendorIDNVIDIA, VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDIntel];
            [_videoCards sortUsingComparator:^NSComparisonResult(VMMVideoCard*  _Nonnull obj1, VMMVideoCard*  _Nonnull obj2)
            {
                NSUInteger obj1ValueIndex = obj1.vendorID != nil ? [vendorIDOrder indexOfObject:obj1.vendorID] : -1;
                NSUInteger obj2ValueIndex = obj2.vendorID != nil ? [vendorIDOrder indexOfObject:obj2.vendorID] : -1;
                 
                if (obj1ValueIndex == -1 && obj2ValueIndex != -1) return NSOrderedDescending;
                if (obj1ValueIndex != -1 && obj2ValueIndex == -1) return NSOrderedAscending;
                if (obj1ValueIndex == -1 && obj2ValueIndex == -1) return NSOrderedSame;
                 
                if (obj1ValueIndex > obj2ValueIndex) return NSOrderedDescending;
                if (obj1ValueIndex < obj2ValueIndex) return NSOrderedAscending;
                return NSOrderedSame;
            }];
            
            NSArray* busOrder = @[VMMVideoCardBusPCIe, VMMVideoCardBusPCI, VMMVideoCardBusBuiltIn];
            [_videoCards sortUsingComparator:^NSComparisonResult(VMMVideoCard*  _Nonnull obj1, VMMVideoCard*  _Nonnull obj2)
            {
                NSUInteger obj1ValueIndex = obj1.bus != nil ? [busOrder indexOfObject:obj1.bus] : -1;
                NSUInteger obj2ValueIndex = obj2.bus != nil ? [busOrder indexOfObject:obj2.bus] : -1;
                 
                if (obj1ValueIndex == -1 && obj2ValueIndex != -1) return NSOrderedDescending;
                if (obj1ValueIndex != -1 && obj2ValueIndex == -1) return NSOrderedAscending;
                if (obj1ValueIndex == -1 && obj2ValueIndex == -1) return NSOrderedSame;
                 
                if (obj1ValueIndex > obj2ValueIndex) return NSOrderedDescending;
                if (obj1ValueIndex < obj2ValueIndex) return NSOrderedAscending;
                return NSOrderedSame;
            }];
        }
        
        return _videoCards;
    }
}

+(nullable VMMVideoCard*)mainVideoCard
{
    NSArray* videoCards = self.videoCards;
    return (videoCards != nil && videoCards.count > 0) ? videoCards.firstObject : nil;
}
+(BOOL)anyVideoCardDictionaryIsComplete
{
    for (VMMVideoCard* vc in _videoCards)
    {
        if (vc.isComplete) return true;
    }
    
    return false;
}

+(NSUInteger)videoCardMemorySizeInMegabytesFromAPI
{
    // Reference:
    // https://developer.apple.com/library/content/qa/qa1168/_index.html
    
    NSUInteger videoMemorySize = 0;
    
    GLint i, nrend = 0;
    CGLRendererInfoObj rend;
    const GLint displayMask = 0xFFFFFFFF;
    CGLQueryRendererInfo((GLuint)displayMask, &rend, &nrend);
    
    for (i = 0; i < nrend; i++)
    {
        GLint videoMemory = 0;
        CGLDescribeRenderer(rend, i, (IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR ? kCGLRPVideoMemoryMegabytes : kCGLRPVideoMemory), &videoMemory);
        if (videoMemory > videoMemorySize) videoMemorySize = videoMemory;
    }
    
    CGLDestroyRendererInfo(rend);
    return videoMemorySize;
}


+(nullable NSString*)macOsVersion
{
    NSString* completeMacOsVersion = [self completeMacOsVersion];
    if (completeMacOsVersion == nil) return nil;
    
    NSArray* components = [completeMacOsVersion componentsSeparatedByString:@"."];
    if (components.count < 2) return nil;
    
    return [NSString stringWithFormat:@"%@.%@",components[0],components[1]];
}
+(nullable NSString*)completeMacOsVersion
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
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(nonnull NSString*)version
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

+(nullable NSString*)macOsBuildVersion
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

+(BOOL)isUserMemberOfUserGroup:(VMMUserGroup)userGroup
{
    @synchronized(_userGroups)
    {
        @autoreleasepool
        {
            if (_userGroups == nil)
            {
                // Obtaining a string with the usergroups of the current user
                NSString* usergroupsString = [NSTask runCommand:@[@"id", @"-G"]];
                
                _userGroups = [usergroupsString componentsSeparatedByString:@" "];
            }
            
            return [_userGroups containsObject:[NSString stringWithFormat:@"%d",userGroup]];
        }
    }
    
    return NO;
}

@end

