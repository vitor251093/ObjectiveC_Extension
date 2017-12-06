//
//  NSString+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSString_Extension_Class
#define NSString_Extension_Class

#import <Foundation/Foundation.h>

@interface NSString (VMMString)

-(BOOL)contains:(nonnull NSString*)string;
-(BOOL)matchesWithSearchTerms:(nonnull NSArray*)searchTerms;
-(nonnull NSArray<NSString*>*)searchTermsWithString;

-(BOOL)matchesWithRegex:(nonnull NSString*)regexString;
-(nonnull NSArray<NSString*>*)componentsMatchingWithRegex:(nonnull NSString*)regexString;

+(nonnull NSString*)humanReadableSizeForBytes:(long long int)bytes withDecimalMeasureSystem:(BOOL)measure;

-(nonnull NSString*)hexadecimalString;
+(nullable NSString*)stringWithHexadecimalUTF8String:(nonnull NSString*)string;

+(nonnull NSString*)stringByRemovingEvenCharsFromString:(nonnull NSString*)text;
-(nonnull NSString*)stringToWebStructure;

-(NSRange)rangeAfterString:(nullable NSString*)before andBeforeString:(nullable NSString*)after;
-(nullable NSString*)getFragmentAfter:(nullable NSString*)before andBefore:(nullable NSString*)after;

-(nullable NSNumber*)initialIntegerValue;

+(nullable NSString*)stringWithContentsOfFile:(nonnull NSString*)file encoding:(NSStringEncoding)enc;
+(nullable NSString*)stringWithContentsOfURL:(nonnull NSURL *)url encoding:(NSStringEncoding)enc timeoutInterval:(long long int)timeoutInterval;

-(BOOL)writeToFile:(nonnull NSString*)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc;

-(nonnull NSData*)dataWithBase64Encoding;

-(BOOL)isAValidURL;

@end

#endif
