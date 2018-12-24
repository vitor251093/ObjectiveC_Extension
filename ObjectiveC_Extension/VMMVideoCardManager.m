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

+(NSMutableArray<VMMVideoCard*>* _Nonnull)systemProfilerVideoCards
{
    NSArray* displayOutput = [VMMComputerInformation systemProfilerItemsForDataType:SPDisplaysDataType];
    
    if (displayOutput == nil)
    {
        return [[NSMutableArray alloc] init];
    }
    
    NSMutableArray* cards = [displayOutput mutableCopy];
    
    [cards replaceObjectsWithVariation:^id _Nullable(NSDictionary*  _Nonnull object, NSUInteger index)
    {
        return [[VMMVideoCard alloc] initVideoCardWithDictionary:object];
    }];
    
    [cards removeObject:[NSNull null]];
    
    return cards;
}

+(id)getValuesFromRegistryEntryObject:(id)keyData
{
    if (keyData == nil) {
        return nil;
    }

    if ([keyData isKindOfClass:[NSData class]])
    {
        NSString* keyDataString;
        NSString* keyDataAsciiString = [[NSString alloc] initWithData:keyData encoding:NSASCIIStringEncoding];
        if (!keyDataAsciiString)
        {
            keyDataString = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSString* keyDataUtf8String = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
            if (keyDataUtf8String != nil && [keyDataUtf8String length] < [keyDataAsciiString length]) {
                keyDataString = keyDataUtf8String;
            }
            else {
                keyDataString = keyDataAsciiString;
            }
        }
        
        return @[keyDataString,keyData];
    }
    
    if ([keyData isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        for (NSString* key in ((NSDictionary*)keyData).allKeys)
        {
            NSObject* newVal = [self getValuesFromRegistryEntryObject:[((NSDictionary*)keyData) objectForKey:key]];
            if (newVal != nil) dict[key] = newVal;
        }
        return dict;
    }
    
    if ([keyData isKindOfClass:[NSArray class]])
    {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for (NSString* val in ((NSArray*)keyData))
        {
            NSObject* newVal = [self getValuesFromRegistryEntryObject:val];
            if (newVal != nil) [array addObject:newVal];
        }
        return array;
    }
    
    return keyData;
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
                
                if (vramSize != NULL)
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
                    
                    CFRelease(vramSize);
                }
                
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
                    
                    id keyVal = service[key];
                    keyVal = [self getValuesFromRegistryEntryObject:keyVal];
                    graphicCardDict[[@"IOPCIDevice_" stringByAppendingString:key]] = keyVal;
                }
                free(keys);
                
                graphicCardDict[VMMVideoCardTemporaryKeyRegKeys] = [regEntryKeys componentsJoinedByString:@", "];
                
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



+(NSArray<VMMVideoCard*>* _Nonnull)videoCards
{
    static NSMutableArray<VMMVideoCard*>* videoCards = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        @autoreleasepool
        {
            videoCards = [self systemProfilerVideoCards];
            NSMutableArray<VMMVideoCard*>* extraVideoCards = [[NSMutableArray alloc] init];
            
            NSArray<VMMVideoCard*>* ioVideoCards = [self videoCardsFromIOServiceMatch];
            for (VMMVideoCard* iovc in ioVideoCards) {
                BOOL found = false;
                for (VMMVideoCard* spvc in videoCards) {
                    if ([spvc isSameVideoCard:iovc]) {
                        found = true;
                        [spvc mergeWithIOPCIVideoCard:iovc];
                    }
                }
                if (!found) [extraVideoCards addObject:iovc];
            }
            [videoCards addObjectsFromArray:extraVideoCards];
            
            [videoCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"memorySizeInMegabytes" ascending:NO]]];
            
            [videoCards sortBySelector:@selector(vendorID)
                               inOrder:@[VMMVideoCardVendorIDATIAMD, VMMVideoCardVendorIDNVIDIA, VMMVideoCardVendorIDIntel]];
            [videoCards sortBySelector:@selector(bus)
                               inOrder:@[VMMVideoCardBusPCIe, VMMVideoCardBusPCI, VMMVideoCardBusBuiltIn]];
            
            [videoCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"isComplete"    ascending:NO]]];
            [videoCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"isExternalGpu" ascending:NO]]];
        }
    });
    
    return videoCards;
}
+(NSArray<VMMVideoCard*>* _Nonnull)videoCardsWithKext
{
    NSMutableArray* videoCards = [[self videoCards] mutableCopy];
    [videoCards replaceObjectsWithVariation:^id _Nullable(VMMVideoCard * _Nonnull object, NSUInteger index) {
        return object.kextLoaded ? object : nil;
    }];
    [videoCards removeObject:[NSNull null]];
    return videoCards;
}


+(VMMVideoCard* _Nullable)bestVideoCard
{
    NSMutableArray* videoCards = [[self videoCardsWithKext] mutableCopy];
    if (videoCards == nil || videoCards.count == 0)
    {
        videoCards = [[self videoCards] mutableCopy];
        if (videoCards == nil || videoCards.count == 0) return nil;
    }
    
    [videoCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"isComplete" ascending:NO]]];
    return videoCards.firstObject;
}
+(VMMVideoCard* _Nullable)bestInternalVideoCard
{
    NSMutableArray* videoCards = [[self videoCardsWithKext] mutableCopy];
    if (videoCards == nil || videoCards.count == 0)
    {
        videoCards = [[self videoCards] mutableCopy];
        if (videoCards == nil || videoCards.count == 0) return nil;
    }
    
    [videoCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"isComplete" ascending:NO]]];
    [videoCards replaceObjectsWithVariation:^id _Nullable(VMMVideoCard * _Nonnull object, NSUInteger index) {
        return (!object.isExternalGpu) ? object : nil;
    }];
    [videoCards removeObject:[NSNull null]];
    if (videoCards.count == 0) return nil;
    
    return videoCards.firstObject;
}
+(VMMVideoCard* _Nullable)bestExternalVideoCard
{
    NSMutableArray* videoCards = [[self videoCardsWithKext] mutableCopy];
    if (videoCards == nil || videoCards.count == 0) return nil;
    
    [videoCards replaceObjectsWithVariation:^id _Nullable(VMMVideoCard * _Nonnull object, NSUInteger index) {
        return (object.isComplete && object.isExternalGpu) ? object : nil;
    }];
    [videoCards removeObject:[NSNull null]];
    if (videoCards.count == 0) return nil;
    
    return videoCards.firstObject;
}

@end
