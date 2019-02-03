//
//  VMMMenu.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 03/02/19.
//  Copyright © 2019 VitorMM. All rights reserved.
//

#import "VMMMenu.h"

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

@implementation VMMMenu

static int MAKE_DARK_KEY;

static BOOL FORCE_LIGHT;
static BOOL FORCE_DARK;

+ (void)forceLightMenu {
    FORCE_LIGHT = true;
    FORCE_DARK = false;
}
+ (void)forceDarkMenu {
    FORCE_LIGHT = false;
    FORCE_DARK = true;
}
+ (void)forceSystemMenu {
    FORCE_LIGHT = false;
    FORCE_DARK = false;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        NSMenuDarkMaker * maker = [[NSMenuDarkMaker alloc] initWithMenu:self];
        objc_setAssociatedObject(self, &MAKE_DARK_KEY, maker, OBJC_ASSOCIATION_RETAIN);
    }
    return self;
}

- (void)makeDark
{
    if (FORCE_LIGHT || FORCE_DARK)
    {
        id impl = [self _menuImpl];
        if ([impl respondsToSelector:@selector(_principalMenuRef)]) {
            MenuRef m = [impl _principalMenuRef];
            if (m) {
                char on = FORCE_DARK ? 1 : 0;
                SetMenuItemProperty(m, 0, 'dock', 'dark', 1, &on);
            }
        }
        
        for (NSMenuItem * item in self.itemArray)
        {
            [item.submenu makeDark];
        }
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
