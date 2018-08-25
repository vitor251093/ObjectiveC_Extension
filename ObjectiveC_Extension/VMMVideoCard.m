//
//  VMMVideoCard.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/03/18.
//  Copyright © 2018 VitorMM. All rights reserved.
//
//  TODO: May be a good adition in the future:
//  https://github.com/codykrieger/gfxCardStatus
//

#import <OpenGL/OpenGL.h>
#import <dlfcn.h>

#import "VMMVideoCard.h"
#import "ObjCExtensionConfig.h"
#import "NSString+Extension.h"
#import "VMMComputerInformation.h"
#import "VMMLogUtility.h"

#if I_WANT_TO_BE_RELEASED_IN_APPLE_STORE == FALSE

@protocol VMMVideoCardMetalDevice

// Equivalent to MTLDevice created to support it in macOS 10.6+
// https://developer.apple.com/documentation/metal/mtldevice?language=objc

@property(readonly, getter=isHeadless)  BOOL headless;
@property(readonly, getter=isLowPower)  BOOL lowPower;
@property(readonly, getter=isRemovable) BOOL removable;
@property(readonly) uint64_t registryID;
@property(readonly) NSString *name;

-(BOOL)supportsFeatureSet:(VMMVideoCardMetalFeatureSet)featureSet;

@end

#endif


@implementation VMMVideoCard

@synthesize dictionary = _dictionary;
@synthesize name = _name;
@synthesize type = _type;
@synthesize bus = _bus;
@synthesize deviceID = _deviceID;
@synthesize vendorID = _vendorID;
@synthesize vendor = _vendor;
@synthesize memorySizeInMegabytes = _memorySizeInMegabytes;

-(instancetype)initVideoCardWithDictionary:(NSDictionary*)dict
{
    if (dict.count == 0) return nil;
    
    self = [super init];
    if (self)
    {
        NSMutableDictionary* newDict = [dict mutableCopy];
        newDict[VMMVideoCardTemporaryKeyOpenGlApiMemorySizes] = [VMMVideoCard videoCardMemorySizesInMegabytesFromOpenGLAPI];
        //newDict[VMMVideoCardTemporaryKeyMetalApiMemorySizes]  = [VMMVideoCard videoCardMemorySizesInMegabytesFromMetalAPI];
        _dictionary = newDict;
        
        nameLock                  = [[NSLock alloc] init];
        typeLock                  = [[NSLock alloc] init];
        busLock                   = [[NSLock alloc] init];
        deviceIDLock              = [[NSLock alloc] init];
        vendorIDLock              = [[NSLock alloc] init];
        vendorLock                = [[NSLock alloc] init];
        memorySizeInMegabytesLock = [[NSLock alloc] init];
    }
    return self;
}

+(nullable NSString*)typeForVideoCardWithName:(NSString*)videoCardName
{
    NSString* graphicCardName = [videoCardName uppercaseString];
    if (graphicCardName == nil) return nil;
    
    NSArray<NSString*>* graphicCardNameComponents = [graphicCardName componentsSeparatedByString:@" "];
    
    if ([graphicCardNameComponents containsObject:@"INTEL"])
    {
        if ([graphicCardNameComponents containsObject:@"HD"])   return VMMVideoCardTypeIntelHD;
        if ([graphicCardNameComponents containsObject:@"UHD"])  return VMMVideoCardTypeIntelUHD;
        if ([graphicCardNameComponents containsObject:@"IRIS"]) return VMMVideoCardTypeIntelIris;
        
        for (NSString* component in graphicCardNameComponents)
        {
            if ([component hasPrefix:@"GM"] && [[component substringFromIndex:2] intValue] != 0) return VMMVideoCardTypeIntelGMA;
        }
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

+(NSArray<NSNumber*>*)videoCardMemorySizesInMegabytesFromOpenGLAPI
{
    // Reference:
    // https://developer.apple.com/library/content/qa/qa1168/_index.html

    GLint i, nrend = 0;
    CGLRendererInfoObj rend;
    const GLint displayMask = 0xFFFFFFFF;
    CGLQueryRendererInfo((GLuint)displayMask, &rend, &nrend);

    NSMutableArray<NSNumber*>* list = [[NSMutableArray alloc] init];
    for (i = 0; i < nrend; i++)
    {
        GLint videoMemory = 0;
        CGLDescribeRenderer(rend, i, (IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR ? kCGLRPVideoMemoryMegabytes : kCGLRPVideoMemory), &videoMemory);
        if (videoMemory != 0) [list addObject:@(videoMemory)];
    }
    
    CGLDestroyRendererInfo(rend);
    
    [list sortUsingComparator:^NSComparisonResult(NSNumber*  _Nonnull obj1, NSNumber*  _Nonnull obj2) {
        NSInteger value1 = obj1.integerValue;
        NSInteger value2 = obj2.integerValue;
        if (value1 > value2) return NSOrderedAscending;
        if (value1 < value2) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    return list;
}

+(NSArray<id<VMMVideoCardMetalDevice>>*)metalDevices
{
#if I_WANT_TO_BE_RELEASED_IN_APPLE_STORE == FALSE
    @autoreleasepool
    {
        // Loading a framework dinamically is not trivial...
        
        // References:
        // https://stackoverflow.com/a/24266440/4370893
        // https://stackoverflow.com/a/21375580/4370893
        // https://stackoverflow.com/a/1354569/4370893
        // https://developer.apple.com/documentation/metal/fundamental_components/macos_devices/getting_different_types_of_gpus?language=objc
        // https://developer.apple.com/documentation/metal/1433367-mtlcopyalldevices?language=objc
        
        void *metalFramework = dlopen("System/Library/Frameworks/Metal.framework/Metal", RTLD_NOW);
        if (!metalFramework) return @[];
        
        NSArray<id>* (*metalCopyAllDevicesWithObserver)(void) = dlsym(metalFramework, "MTLCopyAllDevices");
        NSArray<id>* deviceList = metalCopyAllDevicesWithObserver();
        
        if (0 != dlclose(metalFramework)) {
            NSDebugLog(@"dlclose failed! %s\n", dlerror());
        }
        
        return deviceList;
    }
#else
    return @[];
#endif
}
+(NSDictionary*)videoCardMemorySizesInMegabytesFromMetalAPI
{
    NSDictionary* noResults = @{};
    
    // MTLCopyAllDevicesWithObserver only exists in macOS 10.13+
    if (!IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR) return noResults;
    
    NSMutableDictionary* results = [[NSMutableDictionary alloc] init];
    
    NSArray<id<VMMVideoCardMetalDevice>>* deviceList = self.metalDevices;
    if (deviceList.count == 0) return noResults;
    
    for (id<VMMVideoCardMetalDevice> device in deviceList)
    {
        NSString* deviceName = device.name;
        results[deviceName] = @(0);
    }
    
    return results;
}

-(NSString*)vendorIDFromVendorAndVendorIDKeysOnly
{
    NSDictionary* localVideoCard = _dictionary;
    
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
-(nullable NSString*)deviceID
{
    @synchronized(deviceIDLock)
    {
        if (_deviceID != nil)
        {
            return _deviceID;
        }
        
        @autoreleasepool
        {
            _deviceID = [_dictionary[VMMVideoCardDeviceIDKey] lowercaseString];
            return _deviceID;
        }
    }
}
-(nullable NSString*)bus
{
    @synchronized(busLock)
    {
        if (_bus != nil)
        {
            return _bus;
        }
        
        _bus = _dictionary[VMMVideoCardBusKey];
        return _bus;
    }
}

-(nullable NSString*)name
{
    @synchronized(nameLock)
    {
        if (_name != nil)
        {
            return _name;
        }
        
        @autoreleasepool
        {
            NSString* videoCardName = _dictionary[VMMVideoCardNameKey];
            NSString* chipsetModel  = _dictionary[VMMVideoCardRawNameKey];
            
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
                NSString* vendorID = [self vendorIDFromVendorAndVendorIDKeysOnly];
                NSString* deviceID = [self deviceID];
                
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
            
            // TODO: Maybe this link can be used in the future to improve detection of the name
            // http://pci-ids.ucw.cz/
            
            _name = videoCardName;
            return _name;
        }
    }
}

-(nullable NSString*)type
{
    @synchronized(typeLock)
    {
        if (_type != nil)
        {
            return _type;
        }
        
        @autoreleasepool
        {
            NSString* videoCardType = [VMMVideoCard typeForVideoCardWithName:self.name];
            if (videoCardType != nil)
            {
                _type = videoCardType;
                return _type;
            }
            
            NSString* localVendorID = [self vendorIDFromVendorAndVendorIDKeysOnly];
            
            NSDictionary* vendorIDType = @{VMMVideoCardVendorIDATIAMD:                 VMMVideoCardTypeATIAMD,
                                           VMMVideoCardVendorIDNVIDIA:                 VMMVideoCardTypeNVIDIA,
                                           VMMVideoCardVendorIDVirtualBox:             VMMVideoCardTypeVirtualBox,
                                           VMMVideoCardVendorIDVMware:                 VMMVideoCardTypeVMware,
                                           VMMVideoCardVendorIDParallelsDesktop:       VMMVideoCardTypeParallelsDesktop,
                                           VMMVideoCardVendorIDMicrosoftRemoteDesktop: VMMVideoCardTypeMicrosoftRemoteDesktop,
                                           VMMVideoCardVendorIDQemu:                   VMMVideoCardTypeQemu };
            
            _type = vendorIDType[localVendorID];
        }
        
        return _type;
    }
    
    return nil;
}

-(nullable NSString*)vendorID
{
    @synchronized(vendorIDLock)
    {
        if (_vendorID != nil)
        {
            return _vendorID;
        }
        
        @autoreleasepool
        {
            NSString* localVendorID = [self vendorIDFromVendorAndVendorIDKeysOnly];
            if (localVendorID != nil)
            {
                if ([@[VMMVideoCardVendorIDIntel,      VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDNVIDIA,
                       VMMVideoCardVendorIDVirtualBox, VMMVideoCardVendorIDVMware, VMMVideoCardVendorIDParallelsDesktop,
                       VMMVideoCardVendorIDQemu,       VMMVideoCardVendorIDMicrosoftRemoteDesktop] containsObject:localVendorID])
                {
                    _vendorID = localVendorID;
                    return _vendorID;
                }
                
                // If the Vendor ID doesn't match with any of the above, it's a Hackintosh, using a fake video card vendor ID
                // https://www.tonymacx86.com/threads/problem-with-hd4000-graphics-only-3mb-ram-showing.242113/
                
                return nil;
            }
            
            NSString* videoCardType = self.type;
            if (videoCardType != nil)
            {
                if ([@[VMMVideoCardTypeIntelHD, VMMVideoCardTypeIntelUHD, VMMVideoCardTypeIntelIris, VMMVideoCardTypeIntelGMA] containsObject:videoCardType])
                {
                    _vendorID = VMMVideoCardVendorIDIntel; // Intel Vendor ID
                    return _vendorID;
                }
                
                if ([@[VMMVideoCardTypeATIAMD] containsObject:videoCardType])
                {
                    _vendorID = VMMVideoCardVendorIDATIAMD; // ATI/AMD Vendor ID
                    return _vendorID;
                }
                
                if ([@[VMMVideoCardTypeNVIDIA] containsObject:videoCardType])
                {
                    _vendorID = VMMVideoCardVendorIDNVIDIA; // NVIDIA Vendor ID
                    return _vendorID;
                }
            }
            
            return nil;
        }
    }
}
-(NSString*)vendor
{
    @synchronized(vendorLock)
    {
        if (_vendor != nil)
        {
            return _vendor;
        }
        
        @autoreleasepool
        {
            NSString* vendorID = self.vendorID;
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDIntel])
            {
                _vendor = VMMVideoCardVendorIntel;
                return _vendor;
            }
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDNVIDIA])
            {
                _vendor = VMMVideoCardVendorNVIDIA;
                return _vendor;
            }
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDATIAMD])
            {
                _vendor = VMMVideoCardVendorATIAMD;
                return _vendor;
            }
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDVirtualBox])
            {
                _vendor = VMMVideoCardVendorVirtualBox;
                return _vendor;
            }
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDVMware])
            {
                _vendor = VMMVideoCardVendorVMware;
                return _vendor;
            }
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDParallelsDesktop])
            {
                _vendor = VMMVideoCardVendorParallelsDesktop;
                return _vendor;
            }
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDMicrosoftRemoteDesktop])
            {
                _vendor = VMMVideoCardVendorMicrosoftRemoteDesktop;
                return _vendor;
            }
            
            if ([vendorID isEqualToString:VMMVideoCardVendorIDQemu])
            {
                _vendor = VMMVideoCardVendorQemu;
                return _vendor;
            }
            
            return nil;
        }
    }
}

-(NSNumber*)memorySizeInMegabytes
{
    @synchronized(memorySizeInMegabytesLock)
    {
        if (_memorySizeInMegabytes != nil &&
            _memorySizeInMegabytes.unsignedIntegerValue >= VMMVideoCardMemoryMinimumSize)
        {
            return _memorySizeInMegabytes;
        }
        
        @autoreleasepool
        {
            int memSizeInt = -1;
            
            NSString* memSize = [_dictionary[VMMVideoCardMemorySizePciOrPcieKey] uppercaseString];
            if (memSize == nil || memSize.length == 0) memSize = [_dictionary[VMMVideoCardMemorySizeBuiltInKey] uppercaseString];
            if (memSize == nil || memSize.length == 0) memSize = [_dictionary[VMMVideoCardMemorySizeBuiltInAlternateKey] uppercaseString];
            
            if (memSize != nil && [memSize contains:@" MB"])
            {
                memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" MB"] intValue];
            }
            else if (memSize != nil && [memSize contains:@" GB"])
            {
                memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" GB"] intValue]*1024;
            }
            
            if (memSizeInt < VMMVideoCardMemoryMinimumSize)
            {
                NSInteger numberOfVideoCards = [VMMComputerInformation videoCards].count;
                if (numberOfVideoCards == 1)
                {
                    NSArray<NSNumber*>* apiValues = _dictionary[VMMVideoCardTemporaryKeyOpenGlApiMemorySizes];
                    if (apiValues.count > 0 && [[apiValues firstObject] intValue] >= VMMVideoCardMemoryMinimumSize)
                    {
                        memSizeInt = [[apiValues firstObject] intValue];
                    }
                }
                
                //
                // Intel video cards (and some old NVIDIAs) are integrated, and their
                // video memory size can be calculated, or even determined by their type.
                // Some computers reported a failure in detecting the video memory size
                // for those video cards, so the part below is a manual fix.
                //
                // Reference: https://support.apple.com/en-us/HT204349
                //
                
                if (memSizeInt < VMMVideoCardMemoryMinimumSize)
                {
                    NSString* type = self.type ? self.type : @"";
                    NSString* deviceID = self.deviceID ? self.deviceID : @"";
                    long long int ramMemoryGbSize = ((([VMMComputerInformation ramMemorySize]/1024)/1024)/1024);
                    
                    if ([type isEqualToString:VMMVideoCardTypeIntelIris])
                    {
                        memSizeInt = 1536;
                    }
                    
                    if ([type isEqualToString:VMMVideoCardTypeIntelHD])
                    {
                        memSizeInt = 1536;
                        
                        if ([deviceID isEqualToString:VMMVideoCardDeviceIDIntelHDGraphics4000])
                        {
                            if (numberOfVideoCards > 1) memSizeInt = 1024;
                            
                            // TODO: Check the details about the afirmation below.
                            // "Mac computers using the Intel HD Graphics 4000 as the primary
                            //  or secondary GPU reserve 384MB–1024MB of system memory."
                        }
                        
                        if ([deviceID isEqualToString:VMMVideoCardDeviceIDIntelHDGraphics3000])
                        {
                            if (ramMemoryGbSize == 2) memSizeInt = 256;
                            if (ramMemoryGbSize == 4) memSizeInt = 384;
                            if (ramMemoryGbSize == 8) memSizeInt = 512;
                            
                            // TODO: Exception: In the computers below, the video memory size is 384 even with 8Gb of RAM.
                            // MacBook Pro (15-inch, Late 2011)
                            // MacBook Pro (17-inch, Late 2011)
                            // MacBook Pro (15-inch, Early 2011)
                            // MacBook Pro (17-inch, Early 2011)
                        }
                        
                        if ([deviceID isEqualToString:VMMVideoCardDeviceIDIntelHDGraphics])
                        {
                            memSizeInt = 256;
                        }
                    }
                    
                    if ([type isEqualToString:VMMVideoCardTypeNVIDIA])
                    {
                        if ([@[VMMVideoCardDeviceIDNVIDIAGeForce320M_1,
                               VMMVideoCardDeviceIDNVIDIAGeForce320M_2,
                               VMMVideoCardDeviceIDNVIDIAGeForce320M_3,
                               VMMVideoCardDeviceIDNVIDIAGeForce320M_4,
                               VMMVideoCardDeviceIDNVIDIAGeForce320M_5] containsObject:deviceID])
                        {
                            memSizeInt = 256;
                        }
                        
                        if ([deviceID isEqualToString:VMMVideoCardDeviceIDNVIDIAGeForce9400M])
                        {
                            memSizeInt = 256;
                            if (ramMemoryGbSize == 1) memSizeInt = 128;
                        }
                    }
                }
                
                
                //
                // TODO: Fix video cards with no video memory size, or unrealistic memory size.
                //
                // This is common issue with Hackintoshes, but it may happen with
                // old computers as well.
                //
                //
                //  Specific case:
                //  -> memSizeInt == 0 AND vendor == NVIDIA
                //
                // Apparently, this is a common bug that happens with Hackintoshes that
                // use NVIDIA video cards that were badly configured. Considering that,
                // there is no use in fixing that manually, since it would require a manual
                // fix for every known NVIDIA video card that may have the issue.
                //
                // We can't detect the real video memory size with system_profiler or
                // IOServiceMatching("IOPCIDevice"), and the API method may fail if there
                // are two video cards or more.
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
                
                if (memSizeInt == -1)
                {
                    return nil;
                }
                if (memSizeInt < VMMVideoCardMemoryMinimumSize)
                {
                    return @(memSizeInt);
                }
            }
            
            _memorySizeInMegabytes = @(memSizeInt);
            return _memorySizeInMegabytes;
        }
    }
}

-(BOOL)supportsMetal
{
    // TODO: Metal is only supported in macOS 10.11+. This should be added here?
    // Reference:
    // https://support.apple.com/en-us/HT205073
    
    NSString* metalSupport = self.dictionary[VMMVideoCardMetalSupportKey];
    if (metalSupport == nil) return false;
    
    return true;
}
-(VMMVideoCardMetalFeatureSet)metalFeatureSet
{
    NSString* metalSupport = self.dictionary[VMMVideoCardMetalSupportKey];
    if (metalSupport == nil) return VMMVideoCardMetalFeatureSet_macOS_GPUFamilyNone;
    
    if ([metalSupport isEqualToString:@"spdisplays_supported"]) { 
        return VMMVideoCardMetalFeatureSet_macOS_GPUFamily1_v1;
    }
    if ([metalSupport isEqualToString:@"spdisplays_metalfeaturesetfamily12"]) {
        return VMMVideoCardMetalFeatureSet_macOS_GPUFamily1_v2;
    }
    if ([metalSupport isEqualToString:@"spdisplays_metalfeaturesetfamily13"]) {
        return VMMVideoCardMetalFeatureSet_macOS_GPUFamily1_v3;
    }
    if ([metalSupport isEqualToString:@"spdisplays_metalfeaturesetfamily14"]) {
        return VMMVideoCardMetalFeatureSet_macOS_GPUFamily1_v4;
    }
    if ([metalSupport isEqualToString:@"spdisplays_metalfeaturesetfamily21"]) {
        return VMMVideoCardMetalFeatureSet_macOS_GPUFamily2_v1;
    }
    
    return VMMVideoCardMetalFeatureSet_macOS_GPUFamilyUnknown;
}

-(NSString* _Nonnull)descriptorName
{
    NSString* graphicCard = self.name;
    if (graphicCard == nil)
    {
        NSString* type = self.type;
        if (type == nil) type = self.vendor;
        if (type == nil) type = self.vendorID;
        graphicCard = [NSString stringWithFormat:@"%@ %@",type,self.deviceID];
    }
    
    NSNumber* graphicCardSizeNumber = self.memorySizeInMegabytes;
    if (graphicCardSizeNumber != nil)
    {
        NSUInteger graphicCardSize = graphicCardSizeNumber.unsignedIntegerValue;
        graphicCard = [NSString stringWithFormat:@"%@ (%lu MB)",graphicCard,graphicCardSize];
    }
    
    return graphicCard;
}

-(BOOL)isReal
{
    NSString* vendorID = self.vendorID;
    if (vendorID == nil) return false;
    
    NSArray* validVendorIDs = @[VMMVideoCardVendorIDIntel, VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDNVIDIA];
    return [validVendorIDs containsObject:vendorID];
}

-(BOOL)hasMemorySize
{
    NSNumber* memorySize = self.memorySizeInMegabytes;
    return memorySize != nil && memorySize.unsignedIntegerValue >= VMMVideoCardMemoryMinimumSize;
}
-(BOOL)isComplete
{
    if (self.name          == nil)   return false;
    if (self.deviceID      == nil)   return false;
    if (self.hasMemorySize == false) return false;
    return true;
}
-(BOOL)isVirtualMachineVideoCard
{
    NSString* type = self.type;
    if (type == nil) return false;
    
    NSArray* vms = @[VMMVideoCardTypeVirtualBox, VMMVideoCardTypeVMware, VMMVideoCardTypeParallelsDesktop, VMMVideoCardTypeQemu];
    return [vms containsObject:type];
}

-(NSString*)description
{
    NSMutableArray* data = [[NSMutableArray alloc] init];
    [data addObject:[NSString stringWithFormat:@"Name: %@",self.name]];
    [data addObject:[NSString stringWithFormat:@"Type: %@",self.type]];
    [data addObject:[NSString stringWithFormat:@"Bus: %@",self.bus]];
    [data addObject:[NSString stringWithFormat:@"Device ID: %@",self.deviceID]];
    [data addObject:[NSString stringWithFormat:@"Vendor ID: %@",self.vendorID]];
    [data addObject:[NSString stringWithFormat:@"Vendor: %@",self.vendor]];
    [data addObject:[NSString stringWithFormat:@"Memory size: %@",self.memorySizeInMegabytes]];
    [data addObject:[NSString stringWithFormat:@"Data: %@",self.dictionary]];
    NSString* string = [data componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"{%@}",string];
}

@end
