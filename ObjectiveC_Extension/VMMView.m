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
    if (_backgroundColor)
    {
        [_backgroundColor setFill];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }
    
    [super drawRect:dirtyRect];
    
    if (_backgroundImage)
    {
        [_backgroundImage setSize:self.frame.size];
        [_backgroundImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}

@end
