//
//  NSView+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 04/09/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSView+Extension.h"

@implementation NSView (VMMView_Extensions)

-(void)removeAllSubviews
{
    NSArray* subviewsArray = [self subviews];
    for (int i = (int)subviewsArray.count - 1; i >= 0 ; i--)
    {
        [subviewsArray[i] removeFromSuperview];
    }
}

@end
