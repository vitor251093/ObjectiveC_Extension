//
//  NSMenu+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 16/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//
//  Reference NSMenu+Dark:
//  https://github.com/swillits/NSMenu-Dark
//

#import "NSMenu+Extension.h"

#import <Carbon/Carbon.h>
#import <objc/runtime.h>

#if __LP64__
extern void SetMenuItemProperty(MenuRef         menu,
                                MenuItemIndex   item,
                                OSType          propertyCreator,
                                OSType          propertyTag,
                                ByteCount       propertySize,
                                const void *    propertyData);
#endif


@interface NSMenu (Private)
- (id)_menuImpl;
@end


@protocol NSCarbonMenuImplProtocol <NSObject>
- (MenuRef)_principalMenuRef;
@end


@interface NSMenu (DarkPrivate)
- (void)makeDark;
@end


@interface NSMenuDarkMaker : NSObject
{
    NSMenu * mMenu;
}
- (id)initWithMenu:(NSMenu *)menu;
@end


@implementation NSMenu (VMMMenu)
static int MAKE_DARK_KEY;

- (instancetype)initDarkMenu
{
    self = [self init];
    if (self)
    {
        [self setDark];
    }
    return self;
}

- (void)setDark;
{
    NSMenuDarkMaker * maker = [[NSMenuDarkMaker alloc] initWithMenu:self];
    objc_setAssociatedObject(self, &MAKE_DARK_KEY, maker, OBJC_ASSOCIATION_RETAIN);
}

- (void)makeDark;
{
    id impl = [self _menuImpl];
    if ([impl respondsToSelector:@selector(_principalMenuRef)]) {
        MenuRef m = [impl _principalMenuRef];
        if (m) {
            char on = 1;
            SetMenuItemProperty(m, 0, 'dock', 'dark', 1, &on);
        }
    }
    
    for (NSMenuItem * item in self.itemArray)
    {
        [item.submenu makeDark];
    }
}

@end


@implementation NSMenuDarkMaker

- (id)initWithMenu:(NSMenu *)menu;
{
    self = [super init];
    if (self)
    {
        mMenu = menu;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginTracking:)
                                                     name:NSMenuDidBeginTrackingNotification object:mMenu];
    }
    return self;
}

- (void)dealloc;
{
    mMenu = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)beginTracking:(NSNotification *)note;
{
    [mMenu makeDark];
}

@end
