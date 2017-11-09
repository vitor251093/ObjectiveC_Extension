//
//  NSMutableAttributedString+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSMutableAttributedString+Extension.h"

#import "VMMComputerInformation.h"

@implementation NSMutableAttributedString (VMMMutableAttributedString)

-(instancetype)initWithString:(NSString*)str fontNamed:(NSString*)fontName size:(CGFloat)size
{
    self = [self initWithString:str];
    
    if (self)
    {
        NSFont* font = [NSFont fontWithName:fontName size:size];
        [self addAttribute:NSFontAttributeName value:font];
    }
    
    return self;
}

-(void)replaceOccurrencesOfString:(NSString*)oldString withString:(NSString*)newString
{
    NSRange downloadRange = [self.string rangeOfString:oldString];
    while (downloadRange.location != NSNotFound && downloadRange.length != 0)
    {
        [self replaceCharactersInRange:downloadRange withString:newString];
        downloadRange = [self.string rangeOfString:oldString];
    }
}

-(void)addAttribute:(NSString *)name value:(id)value
{
    [self addAttribute:name value:value range:NSMakeRange(0, self.length)];
}
-(void)setRegularFont:(NSString*)regFont boldFont:(NSString*)boldFont italicFont:(NSString*)italicFont boldAndItalicFont:(NSString*)biFont size:(CGFloat)fontSize
{
    @autoreleasepool
    {
        NSMutableDictionary* fontBoldDictionary = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* fontItalicDictionary = [[NSMutableDictionary alloc] init];
        
        for (int i=0; i< self.length; i++)
        {
            NSString *fontName = [[self attribute:NSFontAttributeName atIndex:i effectiveRange:nil] fontName];
            
            NSNumber* hasItalic = fontItalicDictionary[fontName];
            if (hasItalic == nil)
            {
                fontItalicDictionary[fontName] = @([[[NSFontManager alloc] init] fontNamed:fontName hasTraits:NSItalicFontMask]);
                hasItalic = fontItalicDictionary[fontName];
            }
            
            NSNumber* hasBold = fontBoldDictionary[fontName];
            if (hasBold == nil)
            {
                fontBoldDictionary[fontName] = @([[[NSFontManager alloc] init] fontNamed:fontName hasTraits:NSBoldFontMask]);
                hasBold = fontBoldDictionary[fontName];
            }
            
            fontName = regFont;
            if (boldFont   && hasBold.boolValue)                        fontName = boldFont;
            if (italicFont && hasItalic.boolValue)                      fontName = italicFont;
            if (biFont     && hasBold.boolValue && hasItalic.boolValue) fontName = biFont;
            
            [self setFont:[NSFont fontWithName:fontName size:fontSize] range:NSMakeRange(i,1)];
        }
    }
}

-(void)setTextJustified
{
    [self setTextAlignment:IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR ? NSTextAlignmentJustified : NSJustifiedTextAlignment];
}
-(void)setTextAlignment:(NSTextAlignment)textAlignment
{
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = textAlignment;
    [self addAttribute:NSParagraphStyleAttributeName value:paragrapStyle];
}

-(void)setFontColor:(NSColor*)color range:(NSRange)range
{
    [self addAttribute:NSForegroundColorAttributeName value:color range:range];
}
-(void)setFontColor:(NSColor*)color
{
    [self addAttribute:NSForegroundColorAttributeName value:color];
}
-(void)setFont:(NSFont*)font range:(NSRange)range
{
    [self addAttribute:NSFontAttributeName value:font range:range];
}
-(void)setFont:(NSFont*)font
{
    [self addAttribute:NSFontAttributeName value:font];
}

-(void)appendString:(NSString*)aString
{
    [self appendAttributedString:[[NSAttributedString alloc] initWithString:aString]];
}

-(BOOL)adjustExpansionToFitWidth:(CGFloat)width
{
    CGFloat originalWidth = self.size.width;
    
    BOOL sizeChanged = false;
    CGFloat resizeRate = 0.0;
    
    if (originalWidth > width)
    {
        sizeChanged = true;
        resizeRate = 1 - originalWidth/width;
    }
    
    [self addAttribute:NSExpansionAttributeName value:@(resizeRate)];
    return sizeChanged;
}

@end

