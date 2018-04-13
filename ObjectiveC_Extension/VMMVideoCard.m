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

#import "VMMVideoCard.h"
#import "NSString+Extension.h"
#import "VMMComputerInformation.h"

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
        _dictionary = dict;
    }
    return self;
}

+(nullable NSString*)typeForVideoCardWithName:(NSString*)videoCardName
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
    @synchronized(_deviceID)
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
    @synchronized(_bus)
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
    @synchronized(_name)
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
    @synchronized(_type)
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
    @synchronized(_vendorID)
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
    @synchronized(_vendor)
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
    @synchronized(_memorySizeInMegabytes)
    {
        if (_memorySizeInMegabytes != nil &&
            _memorySizeInMegabytes.unsignedIntegerValue != 0)
        {
            return _memorySizeInMegabytes;
        }
        
        @autoreleasepool
        {
            int memSizeInt = -1;
            
            NSString* memSize = [_dictionary[VMMVideoCardMemorySizePciOrPcieKey] uppercaseString];
            if (memSize == nil) memSize = [_dictionary[VMMVideoCardMemorySizeBuiltInKey] uppercaseString];
            if (memSize == nil) memSize = [_dictionary[VMMVideoCardMemorySizeBuiltInAlternateKey] uppercaseString];
            
            if (memSize != nil && [memSize contains:@" MB"])
            {
                memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" MB"] intValue];
            }
            else if (memSize != nil && [memSize contains:@" GB"])
            {
                memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" GB"] intValue]*1024;
            }
            
            if (memSizeInt < 64)
            {
                //
                // Intel video cards (and some old NVIDIAs) are integrated, and their
                // video memory size can be calculated, or even determined by their type.
                // Some computers reported a failure in detecting the video memory size
                // for those video cards, so this part is a manual fix.
                //
                // Reference: https://support.apple.com/en-us/HT204349
                //
                
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
                        NSInteger numberOfVideoCards = [VMMComputerInformation videoCards].count;
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
                // IOServiceMatching("IOPCIDevice"), and the API method wasn't perfect.
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
                if (memSizeInt < 64)
                {
                    return @(0);
                }
            }
            
            _memorySizeInMegabytes = @(memSizeInt);
            return _memorySizeInMegabytes;
        }
    }
}

-(NSString* _Nullable)metalSupport
{
    NSString* metalSupport = self.dictionary[VMMVideoCardMetalSupportKey];
    if (metalSupport == nil) return nil;
    
    return metalSupport;
    
    // spdisplays_supported
    // spdisplays_metalfeaturesetfamily12
    // spdisplays_metalfeaturesetfamily13
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
    return memorySize != nil && memorySize.unsignedIntegerValue != 0;
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

@end
