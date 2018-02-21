//
//  VMMComputerInformation.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//
//  System requirements references:
//  https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_7.html
//  https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_8.html
//  https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_9.html
//  https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_10.html
//  https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_11.html
//  https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/OSXv10.html
//  https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/macOS_10_13_0.html
//
//  User groups references:
//  https://apple.stackexchange.com/a/240281
//  dscl . list /Groups PrimaryGroupID | tr -s ' ' | sort -n -t ' ' -k2,2
//

#ifndef VMMComputerInformation_Class
#define VMMComputerInformation_Class

// Checks if macOS version is compatible
#define IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR   [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.7"]   // Lion
#define IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR   [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.8"]   // Mountain Lion
#define IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR   [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.9"]   // Mavericks
#define IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR  [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.10"]  // Yosemite
#define IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR  [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.11"]  // El Capitan
#define IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR  [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.12"]  // Sierra
#define IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR  [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.13"]  // High Sierra


// Checks if deprecated frameworks are still available
#define IsFrameworkMessageAvailable                     (!IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR)
#define IsFrameworkServerNotificationAvailable          (!IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR)
#define IsFrameworkAppleShareClientCoreAvailable        (!IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR)
#define IsFrameworkRubyCocoaAvailable                   (!IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR)
#define IsFrameworkSharedFileListAvailable              (!IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR)
#define IsFrameworkVideoDecodeAccelerationAvailable     (!IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR)


// Checks if deprecated classes are still available
#define IsClassNSGarbageCollectorAvailable              (!IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR)


// Checks if new frameworks are available
#define IsFrameworkAVFoundationAvailable                IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR

#define IsFrameworkAccountsAvailable                    IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsFrameworkAudioVideoBridgingAvailable          IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsFrameworkEventKitAvailable                    IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsFrameworkGameKitAvailable                     IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsFrameworkGLKitAvailable                       IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsFrameworkSceneKitAvailable                    IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsFrameworkSocialAvailable                      IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsFrameworkVideoToolboxAvailable                IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR

#define IsFrameworkAVKitAvailable                       IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsFrameworkSpriteKitAvailable                   IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsFrameworkMapKitAvailable                      IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsFrameworkGameControllerAvailable              IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsFrameworkMediaAccessibilityAvailable          IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsFrameworkMediaLibraryAvailable                IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsFrameworkiTunesLibraryAvailable               IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR

#define IsFrameworkCryptoTokenKitAvailable              IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsFrameworkFinderSyncAvailable                  IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsFrameworkHypervisorAvailable                  IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsFrameworkMultipeerConnectivityAvailable       IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsFrameworkNotificationCenterAvailable          IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR

#define IsFrameworkContactsAvailable                    IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
#define IsFrameworkGameplayKitAvailable                 IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
#define IsFrameworkMetalAvailable                       IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
#define IsFrameworkMetalKitAvailable                    IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
#define IsFrameworkModelIOAvailable                     IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
#define IsFrameworkNetworkExtensionAvailable            IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR

#define IsFrameworkIntentsAvailable                     IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsFrameworkSafariServicesAvailable              IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR

#define IsFrameworkCoreMLAvailable                      IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsFrameworkVisionAvailable                      IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR


// Checks if new classes are available
#define IsClassNSDraggingImageComponentAvailable        IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
#define IsClassNSDraggingItemAvailable                  IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
#define IsClassNSDraggingSessionAvailable               IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
#define IsClassNSFontCollectionAvailable                IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
#define IsClassNSJSONSerializationAvailable             IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
#define IsClassNSLinguisticTaggerAvailable              IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
#define IsClassNSOrderedSetAvailable                    IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
#define IsClassNSRegularExpressionAvailable             IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR

#define IsClassAVPlayerItemOutputAvailable              IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassAVSampleBufferDisplayLayerAvailable      IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassCLGeocoderAvailable                      IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassCLPlacemarkAvailable                     IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassCMClockAvailable                         IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassCMTimebaseAvailable                      IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassNSPageControllerAvailable                IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassNSTextAlternativesAvailable              IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassNSUserNotificationCenterAvailable        IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassNSUUIDAvailable                          IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassNSXPCConnectionAvailable                 IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassSKDownloadAvailable                      IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
#define IsClassSKPaymentQueueAvailable                  IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR

#define IsClassNSMediaLibraryBrowserControllerAvailable IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsClassNSStackViewAvailable                     IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsClassNSProgressAvailable                      IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
#define IsClassNSURLSessionAvailable                    IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR

#define IsClassGKSavedGameAvailable                     IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSDateComponentsFormatterAvailable       IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSDateIntervalFormatterAvailable         IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSEnergyFormatterAvailable               IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSGestureRecognizerAvailable             IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSLengthFormatterAvailable               IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSMassFormatterAvailable                 IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSSplitViewItemAvailable                 IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassNSVisualEffectViewAvailable              IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassSCNActionAvailable                       IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassSCNParticleSystemAvailable               IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassSCNPhysicsBehaviorAvailable              IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassSCNPhysicsFieldAvailable                 IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassSCNPhysicsVehicleAvailable               IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassSCNPhysicsWorldAvailable                 IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassSCNTechniqueAvailable                    IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
#define IsClassWKWebViewAvailable                       IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR

#define IsClassNSLayoutGuideAvailable                   IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
#define IsClassNSPersonNameComponentsFormatterAvailable IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
#define IsClassSCNAudioPlayerAvailable                  IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR

#define IsClassAVAssetCacheAvailable                    IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassAVPlayerLooperAvailable                  IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKCloudPlayerAvailable                   IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKDecisionNodeAvailable                  IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKDecisionTreeAvailable                  IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKGameSessionAvailable                   IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKGraphNode3DAvailable                   IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKMeshGraphAvailable                     IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKMonteCarloStrategistAvailable          IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKSceneAvailable                         IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassGKSKNodeComponentAvailable               IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassMDLMaterialPropertyGraphAvailable        IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassNSDateIntervalAvailable                  IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassNSDimensionAvailable                     IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassNSISO8601DateFormatterAvailable          IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassNSPersistentContainerAvailable           IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassNSURLSessionTaskMetricsAvailable         IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassPHLivePhotoAvailable                     IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassPHLivePhotoEditingContextAvailable       IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassPHLivePhotoViewAvailable                 IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassSKTileGroupAvailable                     IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassSKTileGroupRuleAvailable                 IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassSKTileMapNodeAvailable                   IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassSKTileSetAvailable                       IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
#define IsClassSKWarpGeometryAvailable                  IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR

#define IsClassCIBarcodeDescriptorAvailable             IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassAVSampleBufferAudioRendererAvailable     IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCIBicubicScaleTransformAvailable         IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCIBlendKernelAvailable                   IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCIBokehBlurAvailable                     IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCIColorCurvesAvailable                   IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCILabDeltaEAvailable                     IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCIMinMaxRedAvailable                     IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCITextImageGeneratorAvailable            IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassCIRenderDestinationAvailable             IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassNSFontAssetRequestAvailable              IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassPHAssetAvailable                         IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassPHFetchRequestAvailable                  IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassPHPhotoLibraryAvailable                  IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassPHProjectAvailable                       IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassPHProjectChangeRequestAvailable          IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
#define IsClassPHProjectInfoAvailable                   IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR

#define IsClassAVRouteDetectorAvailable                 [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.13.2"]


#import <Foundation/Foundation.h>

static NSString * _Nonnull const VMMVideoCardNameKey =                @"Video card name";
static NSString * _Nonnull const VMMVideoCardChipsetModelKey =        @"Chipset Model";
static NSString * _Nonnull const VMMVideoCardTypeKey =                @"Type";
static NSString * _Nonnull const VMMVideoCardBusKey =                 @"Bus";
static NSString * _Nonnull const VMMVideoCardMemorySizeBuiltInKey =   @"VRAM (Dynamic, Max)";
static NSString * _Nonnull const VMMVideoCardMemorySizePciOrPcieKey = @"VRAM (Total)";
static NSString * _Nonnull const VMMVideoCardVendorKey =              @"Vendor";
static NSString * _Nonnull const VMMVideoCardVendorIDKey =            @"Vendor ID";
static NSString * _Nonnull const VMMVideoCardDeviceIDKey =            @"Device ID";

static NSString * _Nonnull const VMMVideoCardTypeIntelHD =    @"Intel HD";
static NSString * _Nonnull const VMMVideoCardTypeIntelUHD =   @"Intel UHD";
static NSString * _Nonnull const VMMVideoCardTypeIntelIris =  @"Intel Iris";
static NSString * _Nonnull const VMMVideoCardTypeIntelGMA =   @"Intel GMA";
static NSString * _Nonnull const VMMVideoCardTypeATIAMD =     @"ATI/AMD";
static NSString * _Nonnull const VMMVideoCardTypeNVIDIA =     @"NVIDIA";

static NSString * _Nonnull const VMMVideoCardBusPCIe =        @"PCIe";
static NSString * _Nonnull const VMMVideoCardBusPCI =         @"PCI";
static NSString * _Nonnull const VMMVideoCardBusBuiltIn =     @"Built-In";

static NSString * _Nonnull const VMMVideoCardVendorIDIntel =  @"0x8086";
static NSString * _Nonnull const VMMVideoCardVendorIDNVIDIA = @"0x10de";
static NSString * _Nonnull const VMMVideoCardVendorIDATIAMD = @"0x1002";

static NSString * _Nonnull const VMMVideoCardNameVirtualBox =     @"VirtualBox";
static NSString * _Nonnull const VMMVideoCardTypeVirtualBox =     @"VirtualBox";
static NSString * _Nonnull const VMMVideoCardVendorIDVirtualBox = @"0x80ee";
static NSString * _Nonnull const VMMVideoCardDeviceIDVirtualBox = @"0xbeef";

static NSString * _Nonnull const VMMVideoCardNameVMware =         @"VMware";
static NSString * _Nonnull const VMMVideoCardTypeVMware =         @"VMware";
static NSString * _Nonnull const VMMVideoCardVendorIDVMware =     @"0x15ad";


typedef enum VMMUserGroup
{
    VMMUserGroupEveryone      = 12,
    VMMUserGroupStaff         = 20, // root
    VMMUserGroupInteractUsers = 51,
    VMMUserGroupNetUsers      = 52,
    VMMUserGroupConsoleUsers  = 53,
    VMMUserGroupLocalAccounts = 61,
    VMMUserGroupNetAccounts   = 62,
    VMMUserGroupAdmin         = 80, // Admin rights
    VMMUserGroupAccessibility = 90,
} VMMUserGroup;

@interface VMMComputerInformation : NSObject

/*!
 * @discussion  Returns a dictionary with information related with the main video card.
 * @return      A Dictionary with the system_profiler information related with the main video card.
 */
+(nullable NSDictionary*)videoCardDictionary;


/*!
 * @discussion  Returns the Device ID (eg. 0x1234) of the main video card.
 * @return      The Device ID (eg. 0x1234) of the main video card.
 */
+(nullable NSString*)videoCardDeviceID;

/*!
 * @discussion  Returns the name of the main video card.
 * @return      The name of the main video card.
 */
+(nullable NSString*)videoCardName;

/*!
 * @discussion  Returns the type (eg. Intel Iris) of the main video card.
 * @return      The type (eg. Intel Iris) of the main video card.
 */
+(nullable NSString*)videoCardType;

/*!
 * @discussion  Returns the Vendor ID (eg. 0x8086) of the main video card.
 * @return      The Vendor ID (eg. 0x8086) of the main video card.
 */
+(nullable NSString*)videoCardVendorID;

/*!
 * @discussion  Returns the VRAM size of the main video card in Megabytes.
 * @return      The VRAM size of the main video card in Megabytes.
 */
+(NSUInteger)videoCardMemorySizeInMegabytes;

+(nullable NSString*)macOsVersion;
+(nullable NSString*)completeMacOsVersion;
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(nonnull NSString*)version;

+(nullable NSString*)macOsBuildVersion;

+(BOOL)isUserMemberOfUserGroup:(VMMUserGroup)userGroup;

@end

#endif
