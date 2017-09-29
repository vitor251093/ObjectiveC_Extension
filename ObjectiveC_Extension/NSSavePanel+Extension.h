//
//  NSSavePanel+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSSavePanel_Extension_Class
#define NSSavePanel_Extension_Class

#import <Cocoa/Cocoa.h>

@interface NSOpenPanel (VMMOpenPanel)

+(NSArray<NSURL*>*)runThreadSafeModalWithOpenPanel:(void (^)(NSOpenPanel* openPanel))optionsForPanel;

@end

@interface NSSavePanel (VMMSavePanel)

+(NSURL*)runThreadSafeModalWithSavePanel:(void (^)(NSSavePanel* savePanel))optionsForPanel;

-(void)setInitialDirectory:(NSString*)path;

-(void)setWindowTitle:(NSString*)string;

@end

#endif
