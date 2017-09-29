//
//  NSVersion.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/09/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSVersion : NSObject

+(NSComparisonResult)compareVersionString:(NSString*)PK1 withVersionString:(NSString*)PK2;

@end
