//
//  NSText+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSText_Extension_Class
#define NSText_Extension_Class

#import <Cocoa/Cocoa.h>

@interface NSText (VMMText)
-(void)setSelectedRangeHasTheEndOfTheField;
@end

@interface NSTextView (VMMTextView)
-(void)setAttributedString:(NSAttributedString*)string withColor:(NSColor*)color;
@end

@interface NSTextField (VMMTextField)
-(void)setSelectedRangeHasTheEndOfTheField;
-(void)setAnyStringValue:(NSString*)stringValue;
@end

#endif
