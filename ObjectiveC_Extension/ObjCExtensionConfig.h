//
//  ObjCExtensionConfig.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/08/18.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#ifndef ObjCExtensionConfig_h
#define ObjCExtensionConfig_h


#define I_WANT_TO_BE_RELEASED_IN_APPLE_STORE false
//
// Pretty straightforward. If you set this to FALSE, some classes will take use of
// features that aren't allowed in the Apple Store. They are:
// - VMMVideoCard will use the Metal framework to check the devices only if the framework is available
// - VMMUserNotificationCenter will allow the use of custom icons in macOS notifications
//
// If you don't care about those two, just set this to TRUE. Those features will be removed
// in compiling time, so they won't be in your final product in any way.
//


#define IM_IMPORTING_THE_METAL_FRAMEWORK     false
//
// If you import the Metal Framework, your app will be macOS 10.11+ compatible only.
// https://developer.apple.com/documentation/metal
//
// - If you won't use VMMVideoCard in your project, just ignore this condition. If you want
// to be released in the Apple Store or not, that will only depend of the other #define above.
//
// - If you want to use the VMMVideoCard's class with full potential, and still be released
// in the Apple Store, set this to TRUE and add the Metal Framework to this project.
//
// - If you want to use the VMMVideoCard's class with full potential, but you don't care
// about being released in the Apple Store, I recommend setting this to FALSE so VMMVideoCard
// can load it only when it exists, and this project will still be 10.6+ compatible.
//


#endif /* ObjCExtensionConfig_h */
