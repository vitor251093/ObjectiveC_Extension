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
#define IS_SYSTEM_MAC_OS_10_14_OR_SUPERIOR  [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.14"]  // Mojave


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

#define IsClassNSTouchBarAvailable                      [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.12.2"]
#define IsClassAVRouteDetectorAvailable                 [VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.13.2"]


#import <Foundation/Foundation.h>
#import "VMMVideoCard.h"
#import "ObjCExtensionConfig.h"

static NSString* _Nonnull const SPAirPortDataType              = @"SPAirPortDataType";
static NSString* _Nonnull const SPApplicationsDataType         = @"SPApplicationsDataType";
static NSString* _Nonnull const SPAudioDataType                = @"SPAudioDataType";
static NSString* _Nonnull const SPBluetoothDataType            = @"SPBluetoothDataType";
static NSString* _Nonnull const SPCameraDataType               = @"SPCameraDataType";
static NSString* _Nonnull const SPCardReaderDataType           = @"SPCardReaderDataType";
static NSString* _Nonnull const SPComponentDataType            = @"SPComponentDataType";
static NSString* _Nonnull const SPConfigurationProfileDataType = @"SPConfigurationProfileDataType";
static NSString* _Nonnull const SPDeveloperToolsDataType       = @"SPDeveloperToolsDataType";
static NSString* _Nonnull const SPDiagnosticsDataType          = @"SPDiagnosticsDataType";
static NSString* _Nonnull const SPDisabledSoftwareDataType     = @"SPDisabledSoftwareDataType";
static NSString* _Nonnull const SPDiscBurningDataType          = @"SPDiscBurningDataType";
static NSString* _Nonnull const SPDisplaysDataType             = @"SPDisplaysDataType";
static NSString* _Nonnull const SPEthernetDataType             = @"SPEthernetDataType";
static NSString* _Nonnull const SPExtensionsDataType           = @"SPExtensionsDataType";
static NSString* _Nonnull const SPFibreChannelDataType         = @"SPFibreChannelDataType";
static NSString* _Nonnull const SPFirewallDataType             = @"SPFirewallDataType";
static NSString* _Nonnull const SPFireWireDataType             = @"SPFireWireDataType";
static NSString* _Nonnull const SPFontsDataType                = @"SPFontsDataType";
static NSString* _Nonnull const SPFrameworksDataType           = @"SPFrameworksDataType";
static NSString* _Nonnull const SPHardwareDataType             = @"SPHardwareDataType";
static NSString* _Nonnull const SPHardwareRAIDDataType         = @"SPHardwareRAIDDataType";
static NSString* _Nonnull const SPiBridgeDataType              = @"SPiBridgeDataType";
static NSString* _Nonnull const SPInstallHistoryDataType       = @"SPInstallHistoryDataType";
static NSString* _Nonnull const SPLogsDataType                 = @"SPLogsDataType";
static NSString* _Nonnull const SPManagedClientDataType        = @"SPManagedClientDataType";
static NSString* _Nonnull const SPMemoryDataType               = @"SPMemoryDataType";
static NSString* _Nonnull const SPModemDataType                = @"SPModemDataType";
static NSString* _Nonnull const SPNetworkDataType              = @"SPNetworkDataType";
static NSString* _Nonnull const SPNetworkLocationDataType      = @"SPNetworkLocationDataType";
static NSString* _Nonnull const SPNetworkVolumeDataType        = @"SPNetworkVolumeDataType";
static NSString* _Nonnull const SPNVMeDataType                 = @"SPNVMeDataType";
static NSString* _Nonnull const SPParallelATADataType          = @"SPParallelATADataType";
static NSString* _Nonnull const SPParallelSCSIDataType         = @"SPParallelSCSIDataType";
static NSString* _Nonnull const SPPCCardDataType               = @"SPPCCardDataType";
static NSString* _Nonnull const SPPCIDataType                  = @"SPPCIDataType";
static NSString* _Nonnull const SPPowerDataType                = @"SPPowerDataType";
static NSString* _Nonnull const SPPrefPaneDataType             = @"SPPrefPaneDataType";
static NSString* _Nonnull const SPPrintersDataType             = @"SPPrintersDataType";
static NSString* _Nonnull const SPPrintersSoftwareDataType     = @"SPPrintersSoftwareDataType";
static NSString* _Nonnull const SPRawCameraDataType            = @"SPRawCameraDataType";
static NSString* _Nonnull const SPSASDataType                  = @"SPSASDataType";
static NSString* _Nonnull const SPSerialATADataType            = @"SPSerialATADataType";
static NSString* _Nonnull const SPSmartCardsDataType           = @"SPSmartCardsDataType";
static NSString* _Nonnull const SPSoftwareDataType             = @"SPSoftwareDataType";
static NSString* _Nonnull const SPSPIDataType                  = @"SPSPIDataType";
static NSString* _Nonnull const SPStartupItemDataType          = @"SPStartupItemDataType";
static NSString* _Nonnull const SPStorageDataType              = @"SPStorageDataType";
static NSString* _Nonnull const SPSyncServicesDataType         = @"SPSyncServicesDataType";
static NSString* _Nonnull const SPThunderboltDataType          = @"SPThunderboltDataType";
static NSString* _Nonnull const SPUniversalAccessDataType      = @"SPUniversalAccessDataType";
static NSString* _Nonnull const SPUSBDataType                  = @"SPUSBDataType";
static NSString* _Nonnull const SPWWANDataType                 = @"SPWWANDataType";


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


#if USE_THE_METAL_FRAMEWORK_WHEN_AVAILABLE == true
@protocol VMMVideoCardMetalDevice

// Equivalent to MTLDevice created to support it in macOS 10.6+
// https://developer.apple.com/documentation/metal/mtldevice?language=objc

@property (nonnull, readonly) NSString *name;
@property (readonly) uint64_t registryID API_AVAILABLE(macos(10.13)) ;
//@property (readonly) MTLSize maxThreadsPerThreadgroup API_AVAILABLE(macos(10.11), ios(9.0));
@property (readonly, getter=isLowPower) BOOL lowPower;
@property (readonly, getter=isHeadless) BOOL headless;
@property (readonly, getter=isRemovable) BOOL removable API_AVAILABLE(macos(10.13));
@property (readonly) uint64_t recommendedMaxWorkingSetSize API_AVAILABLE(macos(10.12));
@property (readonly, getter=isDepth24Stencil8PixelFormatSupported) BOOL depth24Stencil8PixelFormatSupported;
//@property (readonly) MTLReadWriteTextureTier readWriteTextureSupport API_AVAILABLE(macos(10.13));
//@property (readonly) MTLArgumentBuffersTier argumentBuffersSupport API_AVAILABLE(macos(10.13));
@property (readonly, getter=areRasterOrderGroupsSupported) BOOL rasterOrderGroupsSupported API_AVAILABLE(macos(10.13));
@property (readonly) NSUInteger currentAllocatedSize API_AVAILABLE(macos(10.13), ios(11.0));

///// MTLCommandQueue related
//- (nullable id <MTLCommandQueue>)newCommandQueue;
//- (nullable id <MTLCommandQueue>)newCommandQueueWithMaxCommandBufferCount:(NSUInteger)maxCommandBufferCount;

///// MTLSizeAndAlign related
//- (MTLSizeAndAlign)heapTextureSizeAndAlignWithDescriptor:(MTLTextureDescriptor *)desc API_AVAILABLE(macos(10.13), ios(10.0));
//- (MTLSizeAndAlign)heapBufferSizeAndAlignWithLength:(NSUInteger)length options:(MTLResourceOptions)options API_AVAILABLE(macos(10.13), ios(10.0));

///// MTLHeap related
//- (nullable id <MTLHeap>)newHeapWithDescriptor:(MTLHeapDescriptor *)descriptor API_AVAILABLE(macos(10.13), ios(10.0));

///// MTLBuffer related
//- (nullable id <MTLBuffer>)newBufferWithLength:(NSUInteger)length options:(MTLResourceOptions)options;
//- (nullable id <MTLBuffer>)newBufferWithBytes:(const void *)pointer length:(NSUInteger)length options:(MTLResourceOptions)options;
//- (nullable id <MTLBuffer>)newBufferWithBytesNoCopy:(void *)pointer length:(NSUInteger)length options:(MTLResourceOptions)options deallocator:(void (^ __nullable)(void *pointer, NSUInteger length))deallocator;

///// MTLDepthStencilState related
//- (nullable id <MTLDepthStencilState>)newDepthStencilStateWithDescriptor:(MTLDepthStencilDescriptor *)descriptor;

///// MTLTexture related
//- (nullable id <MTLTexture>)newTextureWithDescriptor:(MTLTextureDescriptor *)descriptor;
//- (nullable id <MTLTexture>)newTextureWithDescriptor:(MTLTextureDescriptor *)descriptor iosurface:(IOSurfaceRef)iosurface plane:(NSUInteger)plane API_AVAILABLE(macos(10.11), ios(11.0));
//- (nullable id <MTLTexture>)newSharedTextureWithDescriptor:(MTLTextureDescriptor *)descriptor API_AVAILABLE(macos(10.14)) API_UNAVAILABLE(ios);
//- (nullable id <MTLTexture>)newSharedTextureWithHandle:(MTLSharedTextureHandle *)sharedHandle API_AVAILABLE(macos(10.14)) API_UNAVAILABLE(ios);

///// MTLSamplerState related
//- (nullable id <MTLSamplerState>)newSamplerStateWithDescriptor:(MTLSamplerDescriptor *)descriptor;

///// MTLLibrary related
//- (nullable id <MTLLibrary>)newDefaultLibrary;
//- (nullable id <MTLLibrary>)newDefaultLibraryWithBundle:(NSBundle *)bundle error:(__autoreleasing NSError **)error API_AVAILABLE(macos(10.12), ios(10.0));
//- (nullable id <MTLLibrary>)newLibraryWithFile:(NSString *)filepath error:(__autoreleasing NSError **)error;
//- (nullable id <MTLLibrary>)newLibraryWithURL:(NSURL *)url error:(__autoreleasing NSError **)error API_AVAILABLE(macos(10.13), ios(11.0));
//- (nullable id <MTLLibrary>)newLibraryWithData:(dispatch_data_t)data error:(__autoreleasing NSError **)error;
//- (nullable id <MTLLibrary>)newLibraryWithSource:(NSString *)source options:(nullable MTLCompileOptions *)options error:(__autoreleasing NSError **)error;
//- (void)newLibraryWithSource:(NSString *)source options:(nullable MTLCompileOptions *)options completionHandler:(MTLNewLibraryCompletionHandler)completionHandler;

///// MTLRenderPipelineState related
//- (nullable id <MTLRenderPipelineState>)newRenderPipelineStateWithDescriptor:(MTLRenderPipelineDescriptor *)descriptor error:(__autoreleasing NSError **)error;
//- (nullable id <MTLRenderPipelineState>)newRenderPipelineStateWithDescriptor:(MTLRenderPipelineDescriptor *)descriptor options:(MTLPipelineOption)options reflection:(MTLAutoreleasedRenderPipelineReflection * __nullable)reflection error:(__autoreleasing NSError **)error;
//- (void)newRenderPipelineStateWithDescriptor:(MTLRenderPipelineDescriptor *)descriptor completionHandler:(MTLNewRenderPipelineStateCompletionHandler)completionHandler;
//- (void)newRenderPipelineStateWithDescriptor:(MTLRenderPipelineDescriptor *)descriptor options:(MTLPipelineOption)options completionHandler:(MTLNewRenderPipelineStateWithReflectionCompletionHandler)completionHandler;

///// MTLComputePipelineState related
//- (nullable id <MTLComputePipelineState>)newComputePipelineStateWithFunction:(id <MTLFunction>)computeFunction error:(__autoreleasing NSError **)error;
//- (nullable id <MTLComputePipelineState>)newComputePipelineStateWithFunction:(id <MTLFunction>)computeFunction options:(MTLPipelineOption)options reflection:(MTLAutoreleasedComputePipelineReflection * __nullable)reflection error:(__autoreleasing NSError **)error;
//- (void)newComputePipelineStateWithFunction:(id <MTLFunction>)computeFunction completionHandler:(MTLNewComputePipelineStateCompletionHandler)completionHandler;
//- (void)newComputePipelineStateWithFunction:(id <MTLFunction>)computeFunction options:(MTLPipelineOption)options completionHandler:(MTLNewComputePipelineStateWithReflectionCompletionHandler)completionHandler;
//- (nullable id <MTLComputePipelineState>)newComputePipelineStateWithDescriptor:(MTLComputePipelineDescriptor *)descriptor options:(MTLPipelineOption)options reflection:(MTLAutoreleasedComputePipelineReflection * __nullable)reflection error:(__autoreleasing NSError **)error API_AVAILABLE(macos(10.11), ios(9.0));
//- (void)newComputePipelineStateWithDescriptor:(MTLComputePipelineDescriptor *)descriptor options:(MTLPipelineOption)options completionHandler:(MTLNewComputePipelineStateWithReflectionCompletionHandler)completionHandler API_AVAILABLE(macos(10.11), ios(9.0));

///// MTLFence related
//- (nullable id <MTLFence>)newFence API_AVAILABLE(macos(10.13), ios(10.0));

- (BOOL)supportsFeatureSet:(VMMVideoCardMetalFeatureSet)featureSet;
- (BOOL)supportsTextureSampleCount:(NSUInteger)sampleCount;

///// MTLPixelFormat related
//- (NSUInteger)minimumLinearTextureAlignmentForPixelFormat:(MTLPixelFormat)format API_AVAILABLE(macos(10.13), ios(11.0));
//- (NSUInteger)minimumTextureBufferAlignmentForPixelFormat:(MTLPixelFormat)format API_AVAILABLE(macos(10.14), ios(12.0));

@property (readonly) NSUInteger maxThreadgroupMemoryLength API_AVAILABLE(macos(10.13));
@property (readonly) NSUInteger maxArgumentBufferSamplerCount API_AVAILABLE(macos(10.14));
@property (readonly, getter=areProgrammableSamplePositionsSupported) BOOL programmableSamplePositionsSupported API_AVAILABLE(macos(10.13));

///// MTLSamplePosition related
//- (void)getDefaultSamplePositions:(MTLSamplePosition *)positions count:(NSUInteger)count API_AVAILABLE(macos(10.13), ios(11.0));

///// MTLArgumentEncoder related
//- (nullable id <MTLArgumentEncoder>)newArgumentEncoderWithArguments:(NSArray <MTLArgumentDescriptor *> *)arguments API_AVAILABLE(macos(10.13), ios(11.0));

///// MTLIndirectCommandBuffer related
//- (nullable id <MTLIndirectCommandBuffer>)newIndirectCommandBufferWithDescriptor:(MTLIndirectCommandBufferDescriptor*)descriptor maxCommandCount:(NSUInteger)maxCount options:(MTLResourceOptions)options API_AVAILABLE(macos(10.14), ios(12.0));

///// MTLEvent related
//- (nullable id <MTLEvent>)newEvent API_AVAILABLE(macos(10.14), ios(12.0));

///// MTLSharedEvent related
//- (nullable id <MTLSharedEvent>)newSharedEvent API_AVAILABLE(macos(10.14), ios(12.0));
//- (nullable id <MTLSharedEvent>)newSharedEventWithHandle:(MTLSharedEventHandle *)sharedEventHandle API_AVAILABLE(macos(10.14), ios(12.0));

@property (readonly) NSUInteger maxBufferLength;

@end
#endif


@interface VMMComputerInformation : NSObject

+(nullable NSArray<NSDictionary*>*)systemProfilerItemsForDataType:(nonnull NSString*)dataType;
    
+(long long int)hardDiskSize;
+(long long int)hardDiskFreeSize;
+(long long int)hardDiskUsedSize;
+(long long int)ramMemorySize;
+(long long int)ramMemoryFreeSize;
+(long long int)ramMemoryUsedSize;
+(nullable NSString*)processorNameAndSpeed;
+(double)processorUsage;
+(nullable NSString*)macModel;

+(nullable NSString*)macOsVersion;
+(nullable NSString*)completeMacOsVersion;
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(nonnull NSString*)version;
+(nullable NSString*)macOsBuildVersion;

+(BOOL)isUserMemberOfUserGroup:(VMMUserGroup)userGroup;


#if IM_IMPORTING_THE_METAL_FRAMEWORK == true
+(NSArray<id<MTLDevice>>*)metalDevices;
#else
#if USE_THE_METAL_FRAMEWORK_WHEN_AVAILABLE == true
+(NSArray<id<VMMVideoCardMetalDevice>>*)metalDevices;
#endif
#endif

/*!
 * @discussion  Returns every available information about every available video card.
 * @return      A VMMVideoCard array with the system_profiler information related with every available video card.
 */
+(NSArray<VMMVideoCard*>* _Nonnull)videoCards;

/*!
 * @discussion  Returns every available information about the main video card.
 * @return      A VMMVideoCard with the system_profiler information related with the main video card.
 */
+(VMMVideoCard* _Nullable)mainVideoCard;

@end

#endif
