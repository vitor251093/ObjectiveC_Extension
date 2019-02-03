//
//  VMMView.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 07/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMView.h"

@implementation VMMView

-(void)setBackgroundColor:(NSColor*)color
{
    _backgroundColor = color;
    [self setNeedsDisplay:YES];
}
-(void)setBackgroundImage:(NSImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect
{
    CGFloat borderThickness = 0;
    if (_borderColor)
    {
        borderThickness = _borderThickness.doubleValue;
        
        [_borderColor setFill];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }
    
    if (_backgroundColor)
    {
        [_backgroundColor setFill];
        
        BOOL hasLeftMargin   = (_borderSides == nil || (_borderSides.unsignedIntegerValue & VMMViewBorderSideLeft)   != 0);
        BOOL hasRightMargin  = (_borderSides == nil || (_borderSides.unsignedIntegerValue & VMMViewBorderSideRight)  != 0);
        BOOL hasTopMargin    = (_borderSides == nil || (_borderSides.unsignedIntegerValue & VMMViewBorderSideTop)    != 0);
        BOOL hasBottomMargin = (_borderSides == nil || (_borderSides.unsignedIntegerValue & VMMViewBorderSideBottom) != 0);
        
        CGFloat leftMargin   = hasLeftMargin   ? borderThickness : 0;
        CGFloat rightMargin  = hasRightMargin  ? borderThickness : 0;
        CGFloat topMargin    = hasTopMargin    ? borderThickness : 0;
        CGFloat bottomMargin = hasBottomMargin ? borderThickness : 0;
        
        NSRect bgRect = NSMakeRect(dirtyRect.origin.x + leftMargin, dirtyRect.origin.y + bottomMargin,
                                   dirtyRect.size.width - (leftMargin + rightMargin),
                                   dirtyRect.size.height - (topMargin + bottomMargin));
        NSRectFillUsingOperation(bgRect, NSCompositeSourceOver);
    }
    
    [super drawRect:dirtyRect];
    
    if (_backgroundImage)
    {
        [_backgroundImage setSize:self.frame.size];
        [_backgroundImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}

@end
