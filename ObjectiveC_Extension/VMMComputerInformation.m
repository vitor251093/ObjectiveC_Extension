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

+(nullable NSArray<NSDictionary*>*)systemProfilerItemsForDataType:(nonnull NSString*)dataType
{
    NSString* displayOutput = [NSTask runProgram:@"/usr/sbin/system_profiler" withFlags:@[@"-xml", @"-detailLevel", @"full", dataType]
                          waitingForTimeInterval:_systemProfilerRequestTimeOut];
    
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
    
    return displayArray;
}
    
+(NSDictionary*)systemProfilerHardwareDictionary
{
    NSArray* hardwareArray = [self systemProfilerItemsForDataType:SPHardwareDataType];
    
    if (hardwareArray == nil)
    {
        return @{};
    }
    
    return [hardwareArray firstObject];
}
+(nullable NSDictionary*)hardwareDictionary
{
    static NSDictionary* hardwareDictionary = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        hardwareDictionary = [self systemProfilerHardwareDictionary];
    });
    
    return hardwareDictionary;
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
    static NSString *processorNameAndSpeed = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSString* processorName  = self.hardwareDictionary[@"cpu_type"];
        NSString* processorSpeed = self.hardwareDictionary[@"current_processor_speed"];
        
        if (processorName != nil && processorName.length > 0)
        {
            processorNameAndSpeed = [NSString stringWithFormat:@"%@ %@",processorName,processorSpeed];
        }
        else
        {
            processorName = [NSTask runCommand:@[@"sysctl", @"-n", @"machdep.cpu.brand_string"]];
            
            if (processorName != nil && processorName.length > 0)
            {
                while ([processorName contains:@"  "])
                {
                    processorName = [processorName stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                }
                
                processorNameAndSpeed = processorName;
            }
            else
            {
                processorNameAndSpeed = processorSpeed;
            }
        }
    });
    
    return processorNameAndSpeed;
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
    static NSString *macModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
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
                                macModel = cpuName;
                                break;
                            }
                        }
                    }
                }
            }
            
            if (macModel == nil)
            {
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
                        macModel = [macInfo getFragmentAfter:@"<configCode>" andBefore:@"</configCode>"];
                        
                        if (macModel.length == 0)
                        {
                            macModel = nil;
                        }
                    }
                }
            }
                
            if (macModel == nil)
            {
                if (otherOption != nil)
                {
                    macModel = otherOption;
                }
                else
                {
                    macModel = self.hardwareDictionary[@"machine_model"];
                }
            }
        }
    });
    
    return macModel;
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
    static NSString *macOsVersion = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        @autoreleasepool
        {
            if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)])
            {
                NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
                if (version.majorVersion >= 10)
                {
                    macOsVersion = [NSString stringWithFormat:@"%ld.%ld.%ld",
                                    version.majorVersion, version.minorVersion, version.patchVersion];
                }
            }
            
            // Gestalt shouldn't be used, even in older systems. It may bring the wrong value.
            // Reference: https://discussions.apple.com/thread/6686435
            
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
        }
    });
    
    return macOsVersion;
}
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(nonnull NSString*)version
{
    static NSMutableDictionary *macOsCompatibility = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        macOsCompatibility = [[NSMutableDictionary alloc] init];
    });
    
    if (macOsCompatibility[version] != nil)
    {
        return [macOsCompatibility[version] boolValue];
    }
    
    BOOL compatible = [VMMVersion compareVersionString:version withVersionString:self.macOsVersion] != VMMVersionCompareFirstIsNewest;
    macOsCompatibility[version] = @(compatible);
    return compatible;
}

+(nullable NSString*)macOsBuildVersion
{
    static NSString *macOsBuildVersion = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        @autoreleasepool
        {
            macOsBuildVersion = [NSTask runCommand:@[@"sw_vers", @"-buildVersion"]];
            
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
        }
    });
    
    return macOsBuildVersion;
}

+(BOOL)isUserMemberOfUserGroup:(VMMUserGroup)userGroup
{
    static NSArray *userGroups = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        // Obtaining a string with the usergroups of the current user
        NSString* usergroupsString = [NSTask runCommand:@[@"id", @"-G"]];
        userGroups = [usergroupsString componentsSeparatedByString:@" "];
    });
    
    return [userGroups containsObject:[NSString stringWithFormat:@"%d",userGroup]];
}


+(NSArray<VMMVideoCard*>* _Nullable)systemProfilerVideoCards
{
    NSArray* displayOutput = [self systemProfilerItemsForDataType:SPDisplaysDataType];
    
    if (displayOutput == nil)
    {
        return nil;
    }
    
    NSMutableArray* cards = [displayOutput mutableCopy];
    
    [cards replaceObjectsWithVariation:^id _Nullable(NSDictionary*  _Nonnull object, NSUInteger index)
    {
        return [[VMMVideoCard alloc] initVideoCardWithDictionary:object];
    }];
    
    [cards removeObject:[NSNull null]];
    
    return cards;
}

+(NSString*)stringWithCFString:(CFStringRef)cf_string {
    char * buffer;
    CFIndex len = CFStringGetLength(cf_string);
    buffer = (char *) malloc(sizeof(char) * len + 1);
    CFStringGetCString(cf_string, buffer, len + 1,
                       CFStringGetSystemEncoding());
    NSString* string = [NSString stringWithUTF8String:buffer];
    free(buffer);
    return string;
}
+(NSString*)stringWithCFNumber:(CFNumberRef)cf_number {
    int number;
    CFNumberGetValue(cf_number, kCFNumberIntType, &number);
    return [NSString stringWithFormat:@"%d",number];
}
+(NSString*)stringWithCFType:(CFTypeRef)cf_type {
    CFTypeID type_id;
    
    type_id = (CFTypeID) CFGetTypeID(cf_type);
    if (type_id == CFStringGetTypeID())
    {
        return [self stringWithCFString:cf_type];
    }
    else if (type_id == CFNumberGetTypeID())
    {
        return [self stringWithCFNumber:cf_type];
    }
    else
    {
        CFStringRef typeIdDescription = CFCopyTypeIDDescription(type_id);
        NSString* string = [self stringWithCFString:typeIdDescription];
        CFRelease(typeIdDescription);
        return [NSString stringWithFormat:@"<%@>",string];
    }
}
+(NSMutableArray<VMMVideoCard*>* _Nonnull)videoCardsFromIOServiceMatch
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
                    CFRelease(gpuName);
                    continue;
                }
                NSMutableDictionary* service = (__bridge NSMutableDictionary*)serviceDictionary;
                
                NSData* gpuModel = service[@"model"];
                if (gpuModel != nil && [gpuModel isKindOfClass:[NSData class]])
                {
                    NSString *gpuModelString = [[NSString alloc] initWithData:gpuModel encoding:NSASCIIStringEncoding];
                    if (gpuModelString != nil)
                    {
                        gpuModelString = [gpuModelString stringByReplacingOccurrencesOfString:@"\0" withString:@" "];
                        gpuModelString = [gpuModelString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                        graphicCardDict[VMMVideoCardNameKey] = gpuModelString;
                    }
                }
                
                NSData* deviceID = service[@"device-id"];
                if (deviceID != nil && [deviceID isKindOfClass:[NSData class]])
                {
                    NSString* hexDeviceIDString = [NSString stringWithFormat:@"%@",deviceID];
                    if (hexDeviceIDString.length > 5)
                    {
                        NSString* firstPart  = [hexDeviceIDString substringWithRange:NSMakeRange(3, 2)];
                        NSString* secondPart = [hexDeviceIDString substringWithRange:NSMakeRange(1, 2)];
                        hexDeviceIDString = [NSString stringWithFormat:@"0x%@%@",firstPart,secondPart];
                        hexDeviceIDString = hexDeviceIDString.lowercaseString;
                        
                        if ([hexDeviceIDString matchesWithRegex:@"0x[0-9a-f]{4}"])
                        {
                            graphicCardDict[VMMVideoCardDeviceIDKey] = hexDeviceIDString;
                        }
                    }
                }
                
                NSData* vendorID = service[@"vendor-id"];
                if (vendorID != nil && [vendorID isKindOfClass:[NSData class]])
                {
                    NSString* vendorIDString = [NSString stringWithFormat:@"%@",vendorID];
                    if (vendorIDString.length > 5)
                    {
                        NSString* firstPart  = [vendorIDString substringWithRange:NSMakeRange(3, 2)];
                        NSString* secondPart = [vendorIDString substringWithRange:NSMakeRange(1, 2)];
                        vendorIDString = [NSString stringWithFormat:@"0x%@%@",firstPart,secondPart];
                        vendorIDString = vendorIDString.lowercaseString;
                        
                        if ([vendorIDString matchesWithRegex:@"0x[0-9a-f]{4}"])
                        {
                            graphicCardDict[VMMVideoCardVendorIDKey] = vendorIDString;
                        }
                    }
                }
                
                graphicCardDict[VMMVideoCardBusKey] = VMMVideoCardBusPCI;
                NSData* hdaGfx = service[@"hda-gfx"];
                if (hdaGfx != nil && [hdaGfx isKindOfClass:[NSData class]])
                {
                    NSString* hdaGfxString = [[NSString alloc] initWithData:hdaGfx encoding:NSASCIIStringEncoding];
                    if (hdaGfxString != nil && [hdaGfxString isEqualToString:@"onboard-1"])
                    {
                        graphicCardDict[VMMVideoCardBusKey] = VMMVideoCardBusBuiltIn;
                    }
                }
                
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
                    else
                    {
                        if (type == CFNumberGetTypeID())
                        {
                            CFNumberGetValue(vramSize, kCFNumberSInt64Type, &size);
                        }
                    }
                    
                    if (vramValueInBytes) size >>= 20;
                    
                    graphicCardDict[VMMVideoCardMemorySizeBuiltInKey] = [NSString stringWithFormat:@"%llu MB", size];
                }
                else
                {
                    // Reference:
                    // https://gist.github.com/JonnyJD/6126680
                    
                    NSMutableArray* regEntryKeys = [[NSMutableArray alloc] init];
                    CFMutableDictionaryRef properties;
                    CFIndex count;
                    CFTypeRef *keys;
                    CFTypeRef *values;
                    int i;
                    
                    IORegistryEntryCreateCFProperties(regEntry, &properties, kCFAllocatorDefault, kNilOptions);
                    count = CFDictionaryGetCount(properties);
                    keys = (CFTypeRef *) malloc(sizeof(CFTypeRef) * count);
                    values = (CFTypeRef *) malloc(sizeof(CFTypeRef) * count);
                    CFDictionaryGetKeysAndValues(properties, (const void **) keys, (const void **) values);
                    free(values);
                    for (i = 0; i < count; i++)
                    {
                        CFTypeRef cf_type = keys[i];
                        NSString* key = [self stringWithCFType:cf_type];
                        [regEntryKeys addObject:key];
                    }
                    free(keys);
                    
                    graphicCardDict[VMMVideoCardTemporaryKeyRegKeys] = [regEntryKeys componentsJoinedByString:@", "];
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
        VMMVideoCard* vc = [[VMMVideoCard alloc] initVideoCardWithDictionary:object];
        if (vc != nil && [vc.vendorID isEqualToString:VMMVideoCardVendorIDIntel] && [vc.deviceID isEqualToString:@"0x27a6"])
        {
            // This video card should be ignored:
            // Intel Corporation Mobile 945GM/GMS/GME, 943/940GML Express Integrated Graphics Controller
            // https://steamcommunity.com/app/259680/discussions/1/405692224243163860/
            // https://www.overclockers.com/forums/showthread.php/656895-can-this-intel-core-2-duo-processor-be-oc
            // https://ubuntuforums.org/archive/index.php/t-1287852.html
            // https://lists.opensuse.org/opensuse/2009-06/msg00099.html
            
            return nil;
        }
        return vc;
    }];
    
    [graphicCardDicts removeObject:[NSNull null]];
    
    return graphicCardDicts;
}
+(NSArray<VMMVideoCard*>* _Nonnull)videoCards
{
    static NSMutableArray<VMMVideoCard*>* videoCards = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        @autoreleasepool
        {
            NSArray<VMMVideoCard*>* systemProfilerVideoCards = [self systemProfilerVideoCards];
            
            if (systemProfilerVideoCards == nil || systemProfilerVideoCards.count == 0 ||
                [self anyVideoCardDictionaryIsCompleteInArray:systemProfilerVideoCards] == false)
            {
                NSMutableArray<VMMVideoCard*>* computerGraphicCardDictionary = [self videoCardsFromIOServiceMatch];
                if (systemProfilerVideoCards != nil) [computerGraphicCardDictionary addObjectsFromArray:systemProfilerVideoCards];
                videoCards = computerGraphicCardDictionary;
            }
            else
            {
                videoCards = [systemProfilerVideoCards mutableCopy];
            }
            
            [videoCards sortBySelector:@selector(vendorID)
                                inOrder:@[VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDNVIDIA, VMMVideoCardVendorIDIntel]];
            [videoCards sortBySelector:@selector(bus)
                                inOrder:@[VMMVideoCardBusPCIe, VMMVideoCardBusPCI, VMMVideoCardBusBuiltIn]];
        }
    });
    
    return videoCards;
}

+(VMMVideoCard* _Nullable)mainVideoCard
{
    NSArray* videoCards = [self videoCards];
    if (videoCards == nil || videoCards.count == 0) return nil;
    return videoCards.firstObject;
}
+(BOOL)anyVideoCardDictionaryIsCompleteInArray:(NSArray<VMMVideoCard*>* _Nonnull)videoCards
{
    for (VMMVideoCard* vc in videoCards)
    {
        if (vc.isComplete) return true;
    }
    
    return false;
}

@end

