//
//  NSImage+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 12/03/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <CoreImage/CoreImage.h>

#import "NSFileManager+Extension.h"
#import "NSImage+Extension.h"
#import "NSString+Extension.h"
#import "NSTask+Extension.h"
#import "NSScreen+Extension.h"

#import "NSComputerInformation.h"
#import "NSLogUtility.h"

#define SMALLER_ICONSET_NEEDED_SIZE 16
#define BIGGEST_ICONSET_NEEDED_SIZE 1024

#define TIFF2ICNS_ICON_SIZE 512
#define QLMANAGE_ICON_SIZE  512

@implementation NSImage (VMMImage)

+(NSImage*)imageWithData:(NSData*)data
{
    NSImage* image;
    
    @try
    {
        image = [[NSImage alloc] initWithData:data];
    }
    @catch (NSException* exception)
    {
        NSDebugLog(@"Failed to init image with data");
        return nil;
    }
    
    return image;
}

+(NSImage*)quickLookImageFromFileAtPath:(NSString*)arquivo
{
    NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile:arquivo];
    
    [NSTask runCommand:@[@"qlmanage", @"-t", @"-s",[NSString stringWithFormat:@"%d",QLMANAGE_ICON_SIZE], @"-o.", arquivo]
             atRunPath:[arquivo stringByDeletingLastPathComponent]];
    
    NSString* newFile = [NSString stringWithFormat:@"%@.png",arquivo, nil];
    if ([[NSFileManager defaultManager] regularFileExistsAtPath:newFile])
    {
        img = [[NSImage alloc] initWithContentsOfFile:newFile];
        [[NSFileManager defaultManager] removeItemAtPath:newFile];
    }
    
    return img;
}
+(NSImage*)imageFromFileAtPath:(NSString*)arquivo
{
    NSImage *img;
    
    if ([[NSImage imageFileTypes] containsObject:arquivo.pathExtension.lowercaseString])
    {
        img = [[NSImage alloc] initWithContentsOfFile:arquivo];
    }
    
    if (!img)
    {
        img = [self quickLookImageFromFileAtPath:arquivo];
    }
    
    if (!img)
    {
        img = [[NSWorkspace sharedWorkspace] iconForFile:arquivo];
    }
    
    return img;
}

+(NSImage*)transparentImageWithSize:(NSSize)size
{
    NSImage* clearImage = [[NSImage alloc] initWithSize:size];
    [clearImage lockFocus];
    [[NSColor clearColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(0, 0, size.height, size.width)];
    [clearImage unlockFocus];
    
    return clearImage;
}

-(BOOL)saveAsPngImageWithSize:(int)size atPath:(NSString*)pngPath
{
    @autoreleasepool
    {
        CIImage *ciimage = [CIImage imageWithData:[self TIFFRepresentation]];
        CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        
        int originalWidth  = [ciimage extent].size.width;
        float scale = (float)size / (float)originalWidth;
        
        [scaleFilter setValue:@(scale) forKey:@"inputScale"];
        [scaleFilter setValue:@(1.0)   forKey:@"inputAspectRatio"];
        [scaleFilter setValue:ciimage  forKey:@"inputImage"];
        
        ciimage = [scaleFilter valueForKey:@"outputImage"];
        if (!ciimage) return false;
        
        NSBitmapImageRep* rep;
        
        @try
        {
            rep = [[NSBitmapImageRep alloc] initWithCIImage:ciimage];
        }
        @catch (NSException* exception)
        {
            return false;
        }
        
        NSData *data = [rep representationUsingType:NSPNGFileType properties:@{}];
        [data writeToFile:pngPath atomically:YES];
    }
        
    return true;
}
-(BOOL)saveIconsetWithSize:(int)size atFolder:(NSString*)folder
{
    BOOL result = [self saveAsPngImageWithSize:size atPath:[NSString stringWithFormat:@"%@/icon_%dx%d.png",folder,size,size]];
    if (result == false) return false;
    
    result = [self saveAsPngImageWithSize:size*2 atPath:[NSString stringWithFormat:@"%@/icon_%dx%d@2x.png",folder,size,size]];
    return result;
}
-(BOOL)saveAsIcnsAtPath:(NSString*)icnsPath
{
    if (!icnsPath) return false;
    
    BOOL result;

    if (IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR)
    {
        @autoreleasepool
        {
            if (![icnsPath hasSuffix:@".icns"]) icnsPath = [icnsPath stringByAppendingString:@".icns"];
            NSString* iconsetPath = [[icnsPath substringToIndex:icnsPath.length - 5] stringByAppendingString:@".iconset"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:iconsetPath withIntermediateDirectories:NO];
            for (int validSize = SMALLER_ICONSET_NEEDED_SIZE; validSize <= BIGGEST_ICONSET_NEEDED_SIZE; validSize=validSize*2)
                [self saveIconsetWithSize:validSize atFolder:iconsetPath];
            
            [[NSFileManager defaultManager] removeItemAtPath:icnsPath];
            [NSTask runCommand:@[@"iconutil", @"-c", @"icns", iconsetPath]];
            [[NSFileManager defaultManager] removeItemAtPath:iconsetPath];
            
            result = ([[NSFileManager defaultManager] sizeOfRegularFileAtPath:icnsPath] > 10);
        }
        
        if (result) return true;
    }
    
    @autoreleasepool
    {
        NSString *tiffPath = [NSString stringWithFormat:@"%@.tiff",icnsPath];
        
        CGFloat correctIconSize = TIFF2ICNS_ICON_SIZE/[[NSScreen mainScreen] retinaScale];
        NSImage *resizedImage = [[NSImage alloc] initWithSize:NSMakeSize(correctIconSize,correctIconSize)];
        [resizedImage lockFocus];
        [self drawInRect:NSMakeRect(0,0,correctIconSize, correctIconSize) fromRect:self.alignmentRect
               operation:NSCompositeSourceOver fraction:1.0];
        [resizedImage unlockFocus];
        
        [[resizedImage TIFFRepresentation] writeToFile:tiffPath atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:icnsPath];
        [NSTask runCommand:@[@"tiff2icns", @"-noLarge", tiffPath, icnsPath]];
        [[NSFileManager defaultManager] removeItemAtPath:tiffPath];
        
        result = [[NSFileManager defaultManager] regularFileExistsAtPath:icnsPath];
    }
    
    return result;
}

-(BOOL)writeToFile:(NSString*)file atomically:(BOOL)useAuxiliaryFile
{
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
    NSString* extension = file.pathExtension.lowercaseString;
    
    NSData* data;
    if ([extension isEqualToString:@"bmp"])  data = [imageRep representationUsingType:NSBMPFileType      properties:@{}];
    if ([extension isEqualToString:@"gif"])  data = [imageRep representationUsingType:NSGIFFileType      properties:@{}];
    if ([extension isEqualToString:@"jpg"])  data = [imageRep representationUsingType:NSJPEGFileType     properties:@{}];
    if ([extension isEqualToString:@"jp2"])  data = [imageRep representationUsingType:NSJPEG2000FileType properties:@{}];
    if ([extension isEqualToString:@"png"])  data = [imageRep representationUsingType:NSPNGFileType      properties:@{}];
    if ([extension isEqualToString:@"tiff"]) data = [imageRep representationUsingType:NSTIFFFileType     properties:@{}];
    if (!data)
    {
        if ([@[@"bmp",@"gif",@"jpg",@"jp2",@"png",@"tiff"] containsObject:extension])
        {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:[NSString stringWithFormat:@"%@ file is corrupted or with the wrong extension.",extension]
                                   userInfo:nil] raise];
        }
        else
        {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:[NSString stringWithFormat:@"Invalid extension for saving image file: %@",extension]
                                   userInfo:nil] raise];
        }
        return false;
    }
    
    return [data writeToFile:file atomically:useAuxiliaryFile];
}

@end
