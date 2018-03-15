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
static NSMutableDictionary* _computerGraphicCardDictionary;

static NSString* _macModel;
static NSString* _processorNameAndSpeed;

static NSString* _computerGraphicCardDeviceID;
static NSString* _computerGraphicCardName;
static NSString* _computerGraphicCardType;
static NSString* _computerGraphicCardVendorID;
static NSNumber* _computerGraphicCardMemorySizeInMegabytes;

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

+(NSMutableDictionary*)videoCardDictionaryFromSystemProfilerOutput:(NSString*)displayOutput
{
    NSArray* displayArray = [VMMPropertyList propertyListWithUnarchivedString:displayOutput];
    if (displayArray == nil)
    {
        return [[NSMutableDictionary alloc] init];
    }
    
    displayArray = displayArray[0][@"_items"];
    if (displayArray == nil)
    {
        return [[NSMutableDictionary alloc] init];
    }
    
    NSArray* cards = [displayArray sortedDictionariesArrayWithKey:VMMVideoCardBusKey
                                            orderingByValuesOrder:@[VMMVideoCardBusPCIe, VMMVideoCardBusPCI, VMMVideoCardBusBuiltIn]];
    return [[cards firstObject] mutableCopy];
}
+(NSMutableDictionary*)videoCardDictionaryFromIOServiceMatch
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
    
    if (graphicCardDicts.count == 0) return [[NSMutableDictionary alloc] init];
    if (graphicCardDicts.count == 1) return graphicCardDicts.firstObject;
    
    [graphicCardDicts replaceObjectsWithVariation:^NSDictionary* _Nullable(NSDictionary* _Nonnull object, NSUInteger index)
    {
        NSMutableDictionary* newDict = [object mutableCopy];
        if (newDict[VMMVideoCardVendorIDKey] == nil)
        {
            NSString* videoCardType = [self videoCardTypeFromVideoCardName:object[VMMVideoCardNameKey]];
            
            if ([@[VMMVideoCardTypeIntelIris, VMMVideoCardTypeIntelUHD,
                   VMMVideoCardTypeIntelHD,   VMMVideoCardTypeIntelGMA] containsObject:videoCardType])
            {
                newDict[VMMVideoCardVendorIDKey] = VMMVideoCardVendorIDIntel;
            }
            
            if ([VMMVideoCardTypeATIAMD isEqualToString:videoCardType])
            {
                newDict[VMMVideoCardVendorIDKey] = VMMVideoCardVendorIDATIAMD;
            }
            
            if ([VMMVideoCardTypeNVIDIA isEqualToString:videoCardType])
            {
                newDict[VMMVideoCardVendorIDKey] = VMMVideoCardVendorIDNVIDIA;
            }
        }
        return newDict;
    }];
    
    NSArray* orderedGraphicCardDicts = [graphicCardDicts sortedDictionariesArrayWithKey:VMMVideoCardVendorIDKey orderingByValuesOrder:@[VMMVideoCardVendorIDNVIDIA, VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDIntel]];
    
    return orderedGraphicCardDicts.firstObject;
}
+(nullable NSDictionary*)videoCardDictionary
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
            
            displayData = [NSTask runProgram:@"system_profiler" withFlags:@[@"-xml",@"SPDisplaysDataType"]
                                                   waitingForTimeInterval:_systemProfilerRequestTimeOut];
            _computerGraphicCardDictionary = [self videoCardDictionaryFromSystemProfilerOutput:displayData];
            if (_computerGraphicCardDictionary.count == 0)
            {
                displayData = [NSTask runProgram:@"/usr/sbin/system_profiler" withFlags:@[@"-xml",@"SPDisplaysDataType"]
                                                                 waitingForTimeInterval:_systemProfilerRequestTimeOut];
                _computerGraphicCardDictionary = [self videoCardDictionaryFromSystemProfilerOutput:displayData];
            }
            
            if (_computerGraphicCardDictionary.count == 0 || [self isGraphicCardDictionaryCompleteWithMemorySize:false] == false)
            {
                NSMutableDictionary* computerGraphicCardDictionary = [[self videoCardDictionaryFromIOServiceMatch] mutableCopy];
                [computerGraphicCardDictionary addEntriesFromDictionary:_computerGraphicCardDictionary];
                _computerGraphicCardDictionary = computerGraphicCardDictionary;
            }
        }
        
        return _computerGraphicCardDictionary;
    }
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
+(nullable NSString*)videoCardTypeFromVideoCardName:(NSString*)videoCardName
{
    NSString* graphicCardName = [videoCardName uppercaseString];
    if (graphicCardName == nil) return nil;
    
    NSArray* graphicCardNameComponents = [graphicCardName componentsSeparatedByString:@" "];
    
    if ([graphicCardNameComponents containsObject:@"INTEL"])
    {
        if ([graphicCardNameComponents containsObject:@"HD"])   return VMMVideoCardTypeIntelHD;
        if ([graphicCardNameComponents containsObject:@"UHD"])  return VMMVideoCardTypeIntelUHD;
        if ([graphicCardNameComponents containsObject:@"IRIS"]) return VMMVideoCardTypeIntelIris;
    }
    
    for (NSString* model in @[@"GMA"])
    {
        if ([graphicCardNameComponents containsObject:model]) return VMMVideoCardTypeIntelGMA;
    }
    
    for (NSString* model in @[@"AMD",@"ATI",@"RADEON"])
    {
        if ([graphicCardNameComponents containsObject:model]) return VMMVideoCardTypeATIAMD;
    }
    
    for (NSString* model in @[@"NVIDIA",@"GEFORCE",@"NVS",@"QUADRO"])
    {
        if ([graphicCardNameComponents containsObject:model]) return VMMVideoCardTypeNVIDIA;
    }
    
    return nil;
}


+(NSString*)videoCardVendorIDFromVendorAndVendorIDKeysOnly
{
    NSDictionary* localVideoCard = self.videoCardDictionary;
    
    NSString* localVendorID = localVideoCard[VMMVideoCardVendorIDKey];
    if (localVendorID != nil)
    {
        return localVendorID;
    }
    
    NSString* localVendor = localVideoCard[VMMVideoCardVendorKey]; // eg. 'NVIDIA (0x10de)' or 'sppci_vendor_Nvidia'
    if (localVendor == nil)
    {
        return nil;
    }
    
    if ([localVendor contains:@"("])
    {
        return [localVendor getFragmentAfter:@"(" andBefore:@")"];
    }
    
    if ([localVendor hasPrefix:@"sppci_vendor_"])
    {
        localVendor = [localVendor stringByReplacingOccurrencesOfString:@"sppci_vendor_" withString:@""];
        localVendor = localVendor.uppercaseString;
        
        if ([localVendor contains:@"NVIDIA"])
        {
            return VMMVideoCardVendorIDNVIDIA;
        }
        if ([localVendor contains:@"ATI"] || [localVendor contains:@"AMD"])
        {
            return VMMVideoCardVendorIDATIAMD;
        }
        if ([localVendor contains:@"INTEL"])
        {
            return VMMVideoCardVendorIDIntel;
        }
    }
    
    return nil;
}
+(nullable NSString*)videoCardDeviceID
{
    @synchronized(_computerGraphicCardDeviceID)
    {
        if (_computerGraphicCardDeviceID != nil)
        {
            return _computerGraphicCardDeviceID;
        }
        
        @autoreleasepool
        {
            _computerGraphicCardDeviceID = [self.videoCardDictionary[VMMVideoCardDeviceIDKey] lowercaseString];
            return _computerGraphicCardDeviceID;
        }
    }
}

+(nullable NSString*)videoCardName
{
    @synchronized(_computerGraphicCardName)
    {
        if (_computerGraphicCardName != nil)
        {
            return _computerGraphicCardName;
        }
        
        @autoreleasepool
        {
            NSDictionary* videoCardDictionary = self.videoCardDictionary;
            
            if (videoCardDictionary == nil)
            {
                return nil;
            }
            
            NSString* videoCardName = videoCardDictionary[VMMVideoCardNameKey];
            NSString* chipsetModel  = videoCardDictionary[VMMVideoCardRawNameKey];
            
            NSArray* invalidVideoCardNames = @[@"Display", @"Apple WiFi card", @"spdisplays_display"];
            BOOL validVideoCardName = (videoCardName != nil && [invalidVideoCardNames containsObject:videoCardName] == false);
            BOOL validChipsetModel  = (chipsetModel  != nil && [invalidVideoCardNames containsObject:chipsetModel]  == false);
            
            if (validVideoCardName == false)
            {
                videoCardName = nil;
            }
            
            if (validChipsetModel == true && validVideoCardName == false)
            {
                videoCardName = chipsetModel;
            }
            
            if (videoCardName == nil)
            {
                NSString* vendorID = [self videoCardVendorIDFromVendorAndVendorIDKeysOnly];
                NSString* deviceID = [self videoCardDeviceID];
                
                if (vendorID != nil)
                {
                    if ([vendorID isEqualToString:VMMVideoCardVendorIDVirtualBox] &&
                        [deviceID isEqualToString:VMMVideoCardDeviceIDVirtualBox])
                    {
                        videoCardName = VMMVideoCardNameVirtualBox;
                    }
                    
                    if ([vendorID isEqualToString:VMMVideoCardVendorIDVMware])
                    {
                        videoCardName = VMMVideoCardNameVMware;
                    }
                    
                    if ([vendorID isEqualToString:VMMVideoCardVendorIDParallelsDesktop])
                    {
                        videoCardName = VMMVideoCardNameParallelsDesktop;
                    }
                    
                    if ([vendorID isEqualToString:VMMVideoCardVendorIDMicrosoftRemoteDesktop])
                    {
                        videoCardName = VMMVideoCardNameMicrosoftRemoteDesktop;
                    }
                    
                    if ([vendorID isEqualToString:VMMVideoCardVendorIDQemu] &&
                        [deviceID isEqualToString:VMMVideoCardDeviceIDQemu])
                    {
                        videoCardName = VMMVideoCardNameQemu;
                    }
                }
            }
            
            _computerGraphicCardName = videoCardName;
            return _computerGraphicCardName;
        }
    }
}

+(BOOL)isGraphicCardDictionaryCompleteWithMemorySize:(BOOL)haveMemorySize
{
    if (self.videoCardName == nil) return false;
    
    if (_computerGraphicCardDictionary[VMMVideoCardDeviceIDKey] == nil) return false;
    
    if (haveMemorySize)
    {
        if (_computerGraphicCardDictionary[VMMVideoCardMemorySizePciOrPcieKey]        == nil &&
            _computerGraphicCardDictionary[VMMVideoCardMemorySizeBuiltInKey]          == nil &&
            _computerGraphicCardDictionary[VMMVideoCardMemorySizeBuiltInAlternateKey] == nil) return false;
    }
    
    return true;
}
+(nullable NSString*)videoCardType
{
    @synchronized(_computerGraphicCardType)
    {
        if (_computerGraphicCardType != nil)
        {
            return _computerGraphicCardType;
        }
        
        @autoreleasepool
        {
            NSString* graphicCardName = [self videoCardTypeFromVideoCardName:self.videoCardName];
            if (graphicCardName != nil)
            {
                _computerGraphicCardType = graphicCardName;
                return _computerGraphicCardType;
            }
            
            NSString* localVendorID = [self videoCardVendorIDFromVendorAndVendorIDKeysOnly];
            
            NSDictionary* vendorIDType = @{VMMVideoCardVendorIDATIAMD:                 VMMVideoCardTypeATIAMD,
                                           VMMVideoCardVendorIDNVIDIA:                 VMMVideoCardTypeNVIDIA,
                                           VMMVideoCardVendorIDVirtualBox:             VMMVideoCardTypeVirtualBox,
                                           VMMVideoCardVendorIDVMware:                 VMMVideoCardTypeVMware,
                                           VMMVideoCardVendorIDParallelsDesktop:       VMMVideoCardTypeParallelsDesktop,
                                           VMMVideoCardVendorIDMicrosoftRemoteDesktop: VMMVideoCardTypeMicrosoftRemoteDesktop,
                                           VMMVideoCardVendorIDQemu:                   VMMVideoCardTypeQemu };
            
            _computerGraphicCardType = vendorIDType[localVendorID];
        }
        
        return _computerGraphicCardType;
    }
    
    return nil;
}

+(nullable NSString*)videoCardVendorID
{
    @synchronized(_computerGraphicCardVendorID)
    {
        if (_computerGraphicCardVendorID != nil)
        {
            return _computerGraphicCardVendorID;
        }
        
        @autoreleasepool
        {
            NSString* localVendorID = [self videoCardVendorIDFromVendorAndVendorIDKeysOnly];
            if (localVendorID != nil)
            {
                if ([@[VMMVideoCardVendorIDIntel,      VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDNVIDIA,
                       VMMVideoCardVendorIDVirtualBox, VMMVideoCardVendorIDVMware, VMMVideoCardVendorIDParallelsDesktop,
                       VMMVideoCardVendorIDQemu,       VMMVideoCardVendorIDMicrosoftRemoteDesktop] containsObject:localVendorID])
                {
                    _computerGraphicCardVendorID = localVendorID;
                    return _computerGraphicCardVendorID;
                }
                
                // If the Vendor ID doesn't match with any of the above, it's a Hackintosh, using a fake video card vendor ID
                // https://www.tonymacx86.com/threads/problem-with-hd4000-graphics-only-3mb-ram-showing.242113/
                
                return nil;
            }
            
            NSString* videoCardType = [self videoCardType];
            if (videoCardType != nil)
            {
                if ([@[VMMVideoCardTypeIntelHD, VMMVideoCardTypeIntelUHD, VMMVideoCardTypeIntelIris, VMMVideoCardTypeIntelGMA] containsObject:videoCardType])
                {
                    _computerGraphicCardVendorID = VMMVideoCardVendorIDIntel; // Intel Vendor ID
                    return _computerGraphicCardVendorID;
                }
                
                if ([@[VMMVideoCardTypeATIAMD] containsObject:videoCardType])
                {
                    _computerGraphicCardVendorID = VMMVideoCardVendorIDATIAMD; // ATI/AMD Vendor ID
                    return _computerGraphicCardVendorID;
                }
                
                if ([@[VMMVideoCardTypeNVIDIA] containsObject:videoCardType])
                {
                    _computerGraphicCardVendorID = VMMVideoCardVendorIDNVIDIA; // NVIDIA Vendor ID
                    return _computerGraphicCardVendorID;
                }
            }
            
            return nil;
        }
    }
}

+(BOOL)isVideoCardReal
{
    NSString* vendorID = self.videoCardVendorID;
    if (vendorID == nil) return false;
    
    return [@[VMMVideoCardVendorIDIntel, VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDNVIDIA] containsObject:vendorID];
}
+(NSUInteger)videoCardMemorySizeInMegabytes
{
    @synchronized(_computerGraphicCardMemorySizeInMegabytes)
    {
        if (_computerGraphicCardMemorySizeInMegabytes != nil &&
            _computerGraphicCardMemorySizeInMegabytes.unsignedIntegerValue != 0 &&
            _computerGraphicCardMemorySizeInMegabytes.unsignedIntegerValue != -1)
        {
            return _computerGraphicCardMemorySizeInMegabytes.unsignedIntegerValue;
        }
        
        @autoreleasepool
        {
            int memSizeInt = -1;
            
            NSDictionary* gcDict = [self videoCardDictionary];
            if (gcDict != nil && gcDict.count > 0)
            {
                NSString* memSize = [gcDict[VMMVideoCardMemorySizePciOrPcieKey] uppercaseString];
                if (memSize == nil) memSize = [gcDict[VMMVideoCardMemorySizeBuiltInKey] uppercaseString];
                if (memSize == nil) memSize = [gcDict[VMMVideoCardMemorySizeBuiltInAlternateKey] uppercaseString];
                
                if ([memSize contains:@" MB"])
                {
                    memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" MB"] intValue];
                }
                else if ([memSize contains:@" GB"])
                {
                    memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" GB"] intValue]*1024;
                }
            }
            
            NSUInteger apiResult = [self videoCardMemorySizeInMegabytesFromAPI];
            if (apiResult != 0 && (memSizeInt == 0 || memSizeInt == -1 || apiResult > memSizeInt))
            {
                _computerGraphicCardMemorySizeInMegabytes = @(apiResult);
                return _computerGraphicCardMemorySizeInMegabytes.unsignedIntegerValue;
            }
            
            if (memSizeInt == 0 && [[self videoCardVendorID] isEqualToString:VMMVideoCardVendorIDNVIDIA])
            {
                //
                // Apparently, this is a common bug that happens with Hackintoshes that
                // use NVIDIA video cards that were badly configured. Considering that,
                // there is no use in fixing that manually, since it would require a manual
                // fix for every known NVIDIA video card that may have the issue.
                //
                // We can't detect the real video memory size with system_profiler or
                // IOServiceMatching("IOPCIDevice"), but we just implemented the API method,
                // which may detect the size correctly even on those cases (hopefully).
                //
                // The same bug may also happen in old legitimate Apple computers, and
                // it also seems to happen only with NVIDIA video cards.
                //
                // References:
                // https://www.tonymacx86.com/threads/graphics-card-0mb.138428/
                // https://www.tonymacx86.com/threads/gtx-770-show-vram-of-0-mb.138629/
                // https://www.reddit.com/r/hackintosh/comments/3e5bi1/gtx_970_vram_0_mb_help/
                // http://www.techsurvivors.net/forums/index.php?showtopic=22889
                // https://discussions.apple.com/thread/2494867?tstart=0
                //
                
                return 0;
            }
            
            if (memSizeInt == 0 || memSizeInt == -1)
            {
                return memSizeInt;
            }
            
            _computerGraphicCardMemorySizeInMegabytes = @(memSizeInt);
            return _computerGraphicCardMemorySizeInMegabytes.unsignedIntegerValue;
        }
    }
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

