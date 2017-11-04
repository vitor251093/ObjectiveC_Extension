//
//  NSMutableString+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 04/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#ifndef NSMutableString_Extension_Class
#define NSMutableString_Extension_Class

#import <Foundation/Foundation.h>

@interface NSMutableString (VMMMutableString)

-(void)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

@end

#endif
