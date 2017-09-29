//
//  NSMenuItem+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 30/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMenuItem (VMMMenuItem)

+(NSMenuItem*)menuItemWithTitle:(NSString*)title andAction:(SEL)action forTarget:(id)target;

@end
