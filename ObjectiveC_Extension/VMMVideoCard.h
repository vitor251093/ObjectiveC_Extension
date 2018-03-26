//
//  VMMVideoCard.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/03/18.
//  Copyright © 2018 VitorMM. All rights reserved.
//
//  References:
//  https://lists.denx.de/pipermail/u-boot/2015-May/215147.html
//
//  TODO: Support eGPUs
//  https://github.com/goalque/automate-eGPU
//

#import <Foundation/Foundation.h>

static NSString * _Nonnull const VMMVideoCardNameKey =                       @"sppci_model";
static NSString * _Nonnull const VMMVideoCardRawNameKey =                    @"_name";
static NSString * _Nonnull const VMMVideoCardTypeKey =                       @"sppci_device_type";
static NSString * _Nonnull const VMMVideoCardBusKey =                        @"sppci_bus";
static NSString * _Nonnull const VMMVideoCardMemorySizeBuiltInAlternateKey = @"_spdisplays_vram";
static NSString * _Nonnull const VMMVideoCardMemorySizeBuiltInKey =          @"spdisplays_vram_shared";
static NSString * _Nonnull const VMMVideoCardMemorySizePciOrPcieKey =        @"spdisplays_vram";
static NSString * _Nonnull const VMMVideoCardVendorIDKey =                   @"spdisplays_vendor-id";
static NSString * _Nonnull const VMMVideoCardVendorKey =                     @"spdisplays_vendor";
static NSString * _Nonnull const VMMVideoCardDeviceIDKey =                   @"spdisplays_device-id";

static NSString * _Nonnull const VMMVideoCardTypeIntelHD =    @"Intel HD";
static NSString * _Nonnull const VMMVideoCardTypeIntelUHD =   @"Intel UHD";
static NSString * _Nonnull const VMMVideoCardTypeIntelIris =  @"Intel Iris";
static NSString * _Nonnull const VMMVideoCardTypeIntelGMA =   @"Intel GMA";
static NSString * _Nonnull const VMMVideoCardTypeATIAMD =     @"ATI/AMD";
static NSString * _Nonnull const VMMVideoCardTypeNVIDIA =     @"NVIDIA";

static NSString * _Nonnull const VMMVideoCardBusPCIe =        @"spdisplays_pcie_device";
static NSString * _Nonnull const VMMVideoCardBusPCI =         @"sppci_pci_device";
static NSString * _Nonnull const VMMVideoCardBusBuiltIn =     @"spdisplays_builtin";

static NSString * _Nonnull const VMMVideoCardVendorIDIntel =  @"0x8086";
static NSString * _Nonnull const VMMVideoCardVendorIDNVIDIA = @"0x10de";
static NSString * _Nonnull const VMMVideoCardVendorIDATIAMD = @"0x1002";

static NSString * _Nonnull const VMMVideoCardVendorIntel =    @"Intel";
static NSString * _Nonnull const VMMVideoCardVendorNVIDIA =   @"NVIDIA";
static NSString * _Nonnull const VMMVideoCardVendorATIAMD =   @"ATI/AMD";

static NSString * _Nonnull const VMMVideoCardNameVirtualBox =                 @"VirtualBox VM";
static NSString * _Nonnull const VMMVideoCardTypeVirtualBox =                 @"VirtualBox";
static NSString * _Nonnull const VMMVideoCardVendorVirtualBox =               @"VirtualBox";
static NSString * _Nonnull const VMMVideoCardVendorIDVirtualBox =             @"0x80ee";
static NSString * _Nonnull const VMMVideoCardDeviceIDVirtualBox =             @"0xbeef";

static NSString * _Nonnull const VMMVideoCardNameVMware =                     @"VMware VM";
static NSString * _Nonnull const VMMVideoCardTypeVMware =                     @"VMware";
static NSString * _Nonnull const VMMVideoCardVendorVMware =                   @"VMware";
static NSString * _Nonnull const VMMVideoCardVendorIDVMware =                 @"0x15ad";

static NSString * _Nonnull const VMMVideoCardNameParallelsDesktop =           @"Parallels Desktop VM";
static NSString * _Nonnull const VMMVideoCardTypeParallelsDesktop =           @"Parallels Desktop";
static NSString * _Nonnull const VMMVideoCardVendorParallelsDesktop =         @"Parallels Desktop";
static NSString * _Nonnull const VMMVideoCardVendorIDParallelsDesktop =       @"0x1ab8";

static NSString * _Nonnull const VMMVideoCardNameMicrosoftRemoteDesktop =     @"Microsoft Remote Desktop";
static NSString * _Nonnull const VMMVideoCardTypeMicrosoftRemoteDesktop =     @"Microsoft Remote Desktop";
static NSString * _Nonnull const VMMVideoCardVendorMicrosoftRemoteDesktop =   @"Microsoft Remote Desktop";
static NSString * _Nonnull const VMMVideoCardVendorIDMicrosoftRemoteDesktop = @"0xbaad";

static NSString * _Nonnull const VMMVideoCardNameQemu =                       @"QEMU Emulated Graphic Card";
static NSString * _Nonnull const VMMVideoCardTypeQemu =                       @"QEMU";
static NSString * _Nonnull const VMMVideoCardVendorQemu =                     @"QEMU";
static NSString * _Nonnull const VMMVideoCardVendorIDQemu =                   @"0x1234";
static NSString * _Nonnull const VMMVideoCardDeviceIDQemu =                   @"0x1111";

@interface VMMVideoCard : NSObject

-(instancetype _Nullable )initVideoCardWithDictionary:(NSDictionary* _Nonnull)dict;

@property (nonatomic, strong, readonly) NSDictionary* _Nonnull dictionary;

@property (nonatomic, strong, readonly) NSString* _Nullable name;
@property (nonatomic, strong, readonly) NSString* _Nullable type;
@property (nonatomic, strong, readonly) NSString* _Nullable bus;
@property (nonatomic, strong, readonly) NSString* _Nullable deviceID;
@property (nonatomic, strong, readonly) NSString* _Nullable vendorID;
@property (nonatomic, strong, readonly) NSString* _Nullable vendor;
@property (nonatomic, strong, readonly) NSNumber* _Nullable memorySizeInMegabytes;

-(NSString* _Nonnull)descriptorName;

-(BOOL)isReal;
-(BOOL)isComplete;
-(BOOL)isVirtualMachineVideoCard;

@end
