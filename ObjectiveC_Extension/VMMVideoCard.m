//
//  VMMVideoCard.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/03/18.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#import "VMMVideoCard.h"
#import "NSString+Extension.h"

@implementation VMMVideoCard

@synthesize dictionary = _dictionary;
@synthesize name = _name;
@synthesize type = _type;
@synthesize bus = _bus;
@synthesize deviceID = _deviceID;
@synthesize vendorID = _vendorID;
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
            NSString* graphicCardName = [VMMVideoCard typeForVideoCardWithName:self.name];
            if (graphicCardName != nil)
            {
                _type = graphicCardName;
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
            
            if ([memSize contains:@" MB"])
            {
                memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" MB"] intValue];
            }
            else if ([memSize contains:@" GB"])
            {
                memSizeInt = [[memSize getFragmentAfter:nil andBefore:@" GB"] intValue]*1024;
            }
            
            if (memSizeInt == 0 && [self.vendorID isEqualToString:VMMVideoCardVendorIDNVIDIA])
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
                
                return @(0);
            }
            
            if (memSizeInt == 0)
            {
                return @(memSizeInt);
            }
            
            if (memSizeInt == -1)
            {
                return nil;
            }
            
            _memorySizeInMegabytes = @(memSizeInt);
            return _memorySizeInMegabytes;
        }
    }
}

-(BOOL)isReal
{
    NSString* vendorID = self.vendorID;
    if (vendorID == nil) return false;
    
    return [@[VMMVideoCardVendorIDIntel, VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDNVIDIA] containsObject:vendorID];
}

-(BOOL)hasNameAndDeviceID
{
    if (self.name == nil) return false;
    if (_dictionary[VMMVideoCardDeviceIDKey] == nil) return false;
    return true;
}
-(BOOL)hasMemorySize
{
    NSNumber* memorySize = self.memorySizeInMegabytes;
    return memorySize != nil && memorySize.unsignedIntegerValue != 0;
}
-(BOOL)isComplete
{
    if (self.hasNameAndDeviceID == false) return false;
    if (self.hasMemorySize      == false) return false;
    return true;
}


@end
