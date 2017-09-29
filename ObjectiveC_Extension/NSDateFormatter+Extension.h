//
//  NSDateFormatter+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 21/07/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (VMMDateFormatter)

+(NSDate*)dateFromString:(NSString *)string withFormat:(NSString*)format;

@end
