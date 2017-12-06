//
//  NSBundle+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 25/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (VMMBundle)

-(nonnull NSString*)bundleName;

-(BOOL)isAppTranslocationActive;

+(nullable NSBundle*)originalMainBundle;

@end
