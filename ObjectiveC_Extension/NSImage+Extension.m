//
//  NSImage+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 12/03/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <CoreImage/CoreImage.h>

#import "NSException+Extension.h"
#import "NSFileManager+Extension.h"
#import "NSImage+Extension.h"
#import "NSString+Extension.h"
#import "NSTask+Extension.h"
#import "NSScreen+Extension.h"

#import "VMMComputerInformation.h"
#import "VMMLogUtility.h"

#define SMALLER_ICONSET_NEEDED_SIZE 16
#define BIGGEST_ICONSET_NEEDED_SIZE 1024

#define TIFF2ICNS_ICON_SIZE 512

@implementation NSBitmapImageRep (VMMBitmapImageRep)
-(BOOL)isTransparentAtX:(int)x andY:(int)y
{
    CGFloat alpha = [[self colorAtX:x y:y] alphaComponent];
    return (alpha < 1.0/255);
}
@end

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
        return nil;
    }
    
    return image;
}

+(NSImage*)quickLookImageWithMaximumSize:(int)size forFileAtPath:(NSString*)arquivo
{
    NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile:arquivo];
    
    [NSTask runCommand:@[@"qlmanage", @"-t", @"-s",[NSString stringWithFormat:@"%d",size], @"-o.", arquivo]
             atRunPath:[arquivo stringByDeletingLastPathComponent]];
    
    NSString* newFile = [NSString stringWithFormat:@"%@.png",arquivo];
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
    
    if (img == nil)
    {
        // 100000 is an arbitrary number, choosen for been a size bigger enought to
        // take the maximum quality of every possible image or icon.
        img = [self quickLookImageWithMaximumSize:100000 forFileAtPath:arquivo];
    }
    
    if (img == nil)
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

-(BOOL)isTransparent
{
    NSData *tempData = [[NSData alloc] initWithData:[self TIFFRepresentation]];
    NSBitmapImageRep *repIcon = [[NSBitmapImageRep alloc] initWithData:tempData];
    int x, y;
    
    for (y=0; y<self.size.height; y++)
    {
        for (x=0; x<self.size.width; x++)
        {
            if ([repIcon isTransparentAtX:x andY:y] == false)
            {
                return false;
            }
        }
    }
    
    return true;
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
        if (ciimage == nil) return false;
        
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
    if (icnsPath == nil) return false;
    
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
    NSString* extension = file.pathExtension.lowercaseString;
    NSDictionary* typeForExtension = @{@"bmp" : @(IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR ? NSBitmapImageFileTypeBMP      : NSBMPFileType     ),
                                       @"gif" : @(IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR ? NSBitmapImageFileTypeGIF      : NSGIFFileType     ),
                                       @"jpg" : @(IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR ? NSBitmapImageFileTypeJPEG     : NSJPEGFileType    ),
                                       @"jp2" : @(IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR ? NSBitmapImageFileTypeJPEG2000 : NSJPEG2000FileType),
                                       @"png" : @(IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR ? NSBitmapImageFileTypePNG      : NSPNGFileType     ),
                                       @"tiff": @(IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR ? NSBitmapImageFileTypeTIFF     : NSTIFFFileType    )};
    
    if ([typeForExtension.allKeys containsObject:extension] == false)
    {
        @throw exception(NSInvalidArgumentException,
                         [NSString stringWithFormat:@"Invalid extension for saving image file: %@",extension]);
        return false;
    }
    
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
    NSData* data = [imageRep representationUsingType:(NSBitmapImageFileType)[typeForExtension[extension] unsignedLongValue] properties:@{}];
    if (data == nil) return false;
    
    return [data writeToFile:file atomically:useAuxiliaryFile];
}

@end
