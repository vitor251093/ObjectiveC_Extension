//
//  VMMPropertyList.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 08/03/2018.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMMPropertyList : NSObject

+(nullable id)propertyListWithUnarchivedString:(NSString*)string;

+(nullable id)propertyListWithArchivedString:(NSString *)string;

@end
