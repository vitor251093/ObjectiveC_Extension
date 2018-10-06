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

#if IM_IMPORTING_THE_METAL_FRAMEWORK == true
    #import <Metal/Metal.h>
#else
    #import <dlfcn.h>
    #import "VMMLogUtility.h"
#endif

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


#if IM_IMPORTING_THE_METAL_FRAMEWORK == true
+(nonnull NSArray<id<MTLDevice>>*)metalDevices
{
    // References:
    // https://developer.apple.com/documentation/metal/fundamental_components/macos_devices/getting_different_types_of_gpus?language=objc
    // https://developer.apple.com/documentation/metal/1433367-mtlcopyalldevices?language=objc
    
    return MTLCopyAllDevices();
}
#else
#if USE_THE_METAL_FRAMEWORK_WHEN_AVAILABLE == true
+(nonnull NSArray<id<VMMMetalDevice>>*)metalDevices
{
    if (!IsFrameworkMetalAvailable) return @[];

    @autoreleasepool
    {
        // Loading a framework dinamically is not trivial... References:
        // Loading Objective-C Class:   https://stackoverflow.com/a/24266440/4370893
        // Loading C int function:      https://stackoverflow.com/a/21375580/4370893
        // Loading C/C++ void function: https://stackoverflow.com/a/1354569/4370893
        
        void *metalFramework = dlopen("System/Library/Frameworks/Metal.framework/Metal", RTLD_NOW);
        if (!metalFramework) return @[];
        
        NSArray<id>* (*metalCopyAllDevicesWithObserver)(void) = dlsym(metalFramework, "MTLCopyAllDevices");
        NSArray<id>* deviceList = metalCopyAllDevicesWithObserver();
        
        if (0 != dlclose(metalFramework)) {
            NSDebugLog(@"dlclose failed! %s\n", dlerror());
        }
        
        return deviceList;
    }

    return @[];
}
#endif
#endif

@end

