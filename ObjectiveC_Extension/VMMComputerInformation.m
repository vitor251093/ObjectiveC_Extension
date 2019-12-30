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
#import "NSMutableString+Extension.h"
#import "NSFileManager+Extension.h"
#import "NSMutableArray+Extension.h"

extern NSArray* MTLCopyAllDevices(void) __attribute__((weak_import));

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
    
    long long int result;
    
    @autoreleasepool
    {
        NSString* vm_stat = [NSTask runCommand:@[@"vm_stat"]];
        
        int pageSize = getpagesize();
        NSMutableString* activeSizeWithSpaces     = [[vm_stat getFragmentAfter:@"Pages active:"                 andBefore:@"."] mutableCopy];
        NSMutableString* wiredSizeWithSpaces      = [[vm_stat getFragmentAfter:@"Pages wired down:"             andBefore:@"."] mutableCopy];
        NSMutableString* purgeableSizeWithSpaces  = [[vm_stat getFragmentAfter:@"Pages purgeable:"              andBefore:@"."] mutableCopy];
        NSMutableString* compressedSizeWithSpaces = [[vm_stat getFragmentAfter:@"Pages occupied by compressor:" andBefore:@"."] mutableCopy];
        
        if (activeSizeWithSpaces == nil)     activeSizeWithSpaces     = [[NSMutableString alloc] initWithString:@"0"];
        if (wiredSizeWithSpaces == nil)      wiredSizeWithSpaces      = [[NSMutableString alloc] initWithString:@"0"];
        if (purgeableSizeWithSpaces == nil)  purgeableSizeWithSpaces  = [[NSMutableString alloc] initWithString:@"0"];
        if (compressedSizeWithSpaces == nil) compressedSizeWithSpaces = [[NSMutableString alloc] initWithString:@"0"];
        
        [activeSizeWithSpaces     trim];
        [wiredSizeWithSpaces      trim];
        [purgeableSizeWithSpaces  trim];
        [compressedSizeWithSpaces trim];
        
        result = ([activeSizeWithSpaces longLongValue]    + [wiredSizeWithSpaces longLongValue] +
                [purgeableSizeWithSpaces longLongValue] + [compressedSizeWithSpaces longLongValue])*pageSize;
    }
    
    return result;
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
    
    double cpuUsageSum = 0.0;
    
    @autoreleasepool
    {
        NSString* ps = [NSTask runCommand:@[@"ps", @"-A", @"-o" ,@"%cpu"]];
        ps = [ps stringByReplacingOccurrencesOfString:@"," withString:@"."];
        
        for (NSString* process in [ps componentsSeparatedByString:@"\n"])
        {
            cpuUsageSum += [[[process mutableCopy] trim] doubleValue];
        }
        
        NSString* numberOfCpus = [NSTask runCommand:@[@"sysctl", @"hw.physicalcpu"]];
        numberOfCpus = [numberOfCpus getFragmentAfter:@" " andBefore:nil];
        if (!numberOfCpus || numberOfCpus.intValue == 0) return -1;
        
        cpuUsageSum = cpuUsageSum/numberOfCpus.intValue;
    }
    
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
                    
                    __block NSString* macInfo = nil;
                    [NSString stringWithContentsOfURL:[NSURL URLWithString:macInfoURL] encoding:NSUTF8StringEncoding
                                      timeoutInterval:_appleSupportMacModelRequestTimeOut withCompletionHandler:
                     ^(NSUInteger statusCode, NSString *string, NSError *error)
                    {
                        if (!error && statusCode >= 200 && statusCode < 300)
                        {
                            macInfo = string;
                        }
                    }];
                    
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

+(nonnull NSArray*)metalDevices
{
    // References:
    // https://developer.apple.com/documentation/metal/fundamental_components/macos_devices/getting_different_types_of_gpus?language=objc
    // https://developer.apple.com/documentation/metal/1433367-mtlcopyalldevices?language=objc
    
    if (MTLCopyAllDevices != NULL) {
        return MTLCopyAllDevices();
    }
    
    return @[];
}

+(BOOL)isSystemIntegrityProtectionEnabled
{
    NSString* output = [NSTask runProgram:@"csrutil" withFlags:@[@"status"]];
    return [output contains:@" enabled."];
}

+(nonnull NSArray<NSDictionary*>*)thunderboltPorts
{
    NSMutableArray* thunderboltOutput = [[NSMutableArray alloc] init];
    
    CFMutableDictionaryRef matchDict = IOServiceMatching("AppleThunderboltHAL");
    
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
            [thunderboltOutput addObject:service];
            CFRelease(serviceDictionary);
            
            IOObjectRelease(regEntry);
        }
        
        IOObjectRelease(iterator);
    }
    
    return thunderboltOutput;
}

+(VMMExternalGPUCompatibilityWithMacOS)macOsCompatibilityWithExternalGPU
{
    if ([self isSystemMacOsEqualOrSuperiorTo:@"10.13.4"]) {
        // Full support
        // https://support.apple.com/en-us/HT208544
        return VMMExternalGPUCompatibilityWithMacOS_Supported;
    }
    if ([self isSystemMacOsEqualOrSuperiorTo:@"10.13"]) {
        // Partial support / needs a different kind of hack
        // https://github.com/learex/macOS-eGPU
        // https://egpu.io/macos-high-sierra-official-external-gpu/
        return VMMExternalGPUCompatibilityWithMacOS_MinorHack;
    }
    if ([self isSystemMacOsEqualOrSuperiorTo:@"10.9"]) {
        // No support, but works with hacks
        // http://forum.notebookreview.com/threads/diy-egpu-macos-experiences.660311/page-11
        // https://odd-one-out.serek.eu/projects/egpu-osx-maverick-nvidia-gtx-760-using-pe4l/
        // https://egpu.io/forums/mac-setup/automate-egpu-sh-is-reborn-with-amd-polaris-fiji-support-for-macos/
        // https://www.techinferno.com/index.php?/forums/topic/7657-guide-enabling-egpu-display-output-in-yosemite/
        // http://forum.netkas.org/index.php?topic=11140.0
        // https://egpu.io/setup-guide-external-graphics-card-mac/
        return VMMExternalGPUCompatibilityWithMacOS_MajorHack;
    }
    
    // No support and no hacks
    return VMMExternalGPUCompatibilityWithMacOS_None;
}

@end

