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

#import "NSComputerInformation.h"
#import "NSLogUtility.h"

#define INNER_GOG_ICON_SIDE     440
#define INNER_GOG_ICON_X_MARGIN 36
#define INNER_GOG_ICON_Y_MARGIN 35

#define FULL_ICON_SIZE          512


#define SMALLER_ICONSET_NEEDED_SIZE 16
#define BIGGEST_ICONSET_NEEDED_SIZE 1024

#define TIFF2ICNS_ICON_SIZE 512
#define QLMANAGE_ICON_SIZE 512


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

+(CGFloat)retinaScale
{
    return IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR ? [NSScreen mainScreen].backingScaleFactor :
                                               [NSScreen mainScreen].userSpaceScaleFactor;
}

+(NSImage*)quickLookImageFromFileAtPath:(NSString*)arquivo
{
    NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile:arquivo];
    
    [NSTask runProgram:@"qlmanage" atRunPath:[arquivo stringByDeletingLastPathComponent]
             withFlags:@[@"-t", @"-s",[NSString stringWithFormat:@"%d",QLMANAGE_ICON_SIZE], @"-o.", arquivo] wait:YES];
    
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

-(NSImage*)imageByFramingImageResizing:(BOOL)willResize
{
    int MAX_ICON_SIZE = FULL_ICON_SIZE/[NSImage retinaScale];
    
    CGFloat width  = self.size.width;
    if (width < 1) width = 1;
    
    CGFloat height = self.size.height;
    if (height < 1) height = 1;
    
    if (width > height)
    {
        CGFloat newHeight = (MAX_ICON_SIZE / width) * height;
        [self setSize:NSMakeSize(MAX_ICON_SIZE,newHeight)];
        
        NSRect dim = [self alignmentRect];
        dim.size.height = MAX_ICON_SIZE;
        dim.origin.y = height/2 - MAX_ICON_SIZE/2;
        [self setAlignmentRect:dim];
    }
    
    else if (width < height)
    {
        CGFloat newWidth = (MAX_ICON_SIZE / height) * width;
        [self setSize: NSMakeSize(newWidth,MAX_ICON_SIZE)];
        
        NSRect dim = [self alignmentRect];
        dim.size.width = MAX_ICON_SIZE;
        dim.origin.x = width/2 - MAX_ICON_SIZE/2;
        [self setAlignmentRect:dim];
    }
    
    else [self setSize:NSMakeSize(MAX_ICON_SIZE,MAX_ICON_SIZE)];
    
    if (willResize)
    {
        NSImage *resizedImage = [[NSImage alloc] initWithSize:NSMakeSize(MAX_ICON_SIZE,MAX_ICON_SIZE)];
        [resizedImage lockFocus];
        
        [self drawInRect:NSMakeRect(0,0,MAX_ICON_SIZE,MAX_ICON_SIZE) fromRect:self.alignmentRect
               operation:NSCompositeSourceOver fraction:1.0];
        
        [resizedImage unlockFocus];
        
        return resizedImage;
    }
    
    return self;
}
-(NSImage*)circularImageWithSize:(CGSize)size andBackgroundColor:(NSColor*)bgColor cuttingImage:(BOOL)cutting
{
    NSImage *resizedImage;
    
    @autoreleasepool
    {
        NSRect imageFrame = NSMakeRect(INNER_GOG_ICON_X_MARGIN, INNER_GOG_ICON_Y_MARGIN, INNER_GOG_ICON_SIDE, INNER_GOG_ICON_SIDE);
        resizedImage = [[NSImage alloc] initWithSize:size];
        
        [resizedImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:imageFrame];
        [path setWindingRule:NSEvenOddWindingRule];
        [path addClip];
        
        [bgColor set];
        [path fill];
        
        if (!cutting) [self setSize:NSMakeSize(FULL_ICON_SIZE, FULL_ICON_SIZE)];
        [self drawInRect:imageFrame fromRect:cutting ? NSZeroRect : imageFrame operation:NSCompositeSourceOver fraction:1.0];
        
        [resizedImage unlockFocus];
    }
    
    return resizedImage;
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
            [NSTask runProgram:@"iconutil" atRunPath:nil withFlags:@[@"-c", @"icns", iconsetPath] wait:YES];
            [[NSFileManager defaultManager] removeItemAtPath:iconsetPath];
            
            result = ([[NSFileManager defaultManager] sizeOfRegularFileAtPath:icnsPath] > 10);
        }
        
        if (result) return true;
    }
    
    @autoreleasepool
    {
        NSString *tiffPath = [NSString stringWithFormat:@"%@.tiff",icnsPath];
        
        CGFloat correctIconSize = TIFF2ICNS_ICON_SIZE/[NSImage retinaScale];
        NSImage *resizedImage = [[NSImage alloc] initWithSize:NSMakeSize(correctIconSize,correctIconSize)];
        [resizedImage lockFocus];
        [self drawInRect:NSMakeRect(0,0,correctIconSize, correctIconSize) fromRect:self.alignmentRect
               operation:NSCompositeSourceOver fraction:1.0];
        [resizedImage unlockFocus];
        
        [[resizedImage TIFFRepresentation] writeToFile:tiffPath atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:icnsPath];
        [NSTask runProgram:@"tiff2icns" atRunPath:nil withFlags:@[@"-noLarge", tiffPath, icnsPath] wait:YES];
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
    if (!data) return FALSE;
    
    return [data writeToFile:file atomically:useAuxiliaryFile];
}

@end
