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
    [self needsDisplay];
}
-(void)drawRect:(NSRect)dirtyRect
{
    if (_backgroundColor)
    {
        [_backgroundColor setFill];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }
    
    [super drawRect:dirtyRect];
}

@end
