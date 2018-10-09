//
//  VMMVideoCardManager.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 04/10/18.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#import "VMMVideoCardManager.h"

#import "NSMutableArray+Extension.h"
#import "NSString+Extension.h"

@implementation VMMVideoCardManager

+(NSArray<VMMVideoCard*>* _Nullable)systemProfilerVideoCards
{
    NSArray* displayOutput = [VMMComputerInformation systemProfilerItemsForDataType:SPDisplaysDataType];
    
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
                        NSString* key = [NSString stringWithCFType:cf_type];
                        if (key == nil) key = [NSString stringWithCFTypeIDDescription:cf_type];
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



+(BOOL)anyVideoCardDictionaryIsCompleteInArray:(NSArray<VMMVideoCard*>* _Nonnull)videoCards
{
    for (VMMVideoCard* vc in videoCards)
    {
        if (vc.isComplete) return true;
    }
    
    return false;
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
            
            [videoCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"kextLoaded" ascending:NO]]];
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

@end
