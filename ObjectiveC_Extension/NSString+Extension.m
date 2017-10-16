//
//  NSString+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSString+Extension.h"

#import "NSData+Extension.h"
#import "NSTask+Extension.h"
#import "NSAlert+Extension.h"
#import "NSFileManager+Extension.h"

#import "NSComputerInformation.h"

@implementation NSString (VMMString)

-(BOOL)contains:(NSString*)string
{
    return [self rangeOfString:string].location != NSNotFound;
}
-(BOOL)containsWord:(NSString*)word
{
    BOOL result;
    
    @autoreleasepool
    {
        NSArray* words = [self.lowercaseString componentsSeparatedByString:@" "];
        result = [words containsObject:word];
    }
    
    return result;
}
-(BOOL)containsOneOfSynonyms:(NSArray*)words
{
    for (NSString* word in words)
    {
        if ([self containsWord:word])
        {
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)containsAbbreviation:(NSString*)string
{
    if (string.length == 1)
    {
        // It will just a waste of time. Considering that 'contains' return true, that will be irrelevant;
        // If it returns false, then that function will return false as well
        return NO;
    }
    
    @autoreleasepool
    {
        NSString* abbreviation = string.lowercaseString;
        
        NSMutableArray* words = [[self.lowercaseString componentsSeparatedByString:@" "] mutableCopy];
        [words removeObject:@""];
        
        if (words.count < abbreviation.length)
        {
            return false;
        }
        
        int lettersSkipped;
        BOOL patternMatches = NO;
        BOOL letterMatches = NO;
        char letter;
        
        for (int wordIndex = 0; wordIndex <= words.count - abbreviation.length; wordIndex++)
        {
            letter = [abbreviation characterAtIndex:0];
            letterMatches = [words[wordIndex] characterAtIndex:0] == letter;
            
            if (letterMatches)
            {
                patternMatches = NO;
                lettersSkipped = 0;
                
                for (int letterIndex = 1; letterIndex < abbreviation.length; letterIndex++)
                {
                    letter = [abbreviation characterAtIndex:letterIndex];
                    letterMatches = [words[wordIndex+letterIndex+lettersSkipped] characterAtIndex:0] == letter;
                    
                    if (letterMatches && letterIndex == abbreviation.length - 1) patternMatches = YES;
                    
                    if (words.count == wordIndex + letterIndex + lettersSkipped + 1)
                    {
                        break;
                    }
                    
                    if (!letterMatches)
                    {
                        lettersSkipped++;
                        letterIndex--;
                    }
                }
                
                if (patternMatches) break;
            }
            
            if (patternMatches) break;
        }
        
        return patternMatches;
    }
}
-(BOOL)matchesWithSearchTerms:(NSArray*)searchTerms
{
    NSCharacterSet* unitingSetItem    = [NSCharacterSet characterSetWithCharactersInString:@"'."];
    NSCharacterSet* separatingSetItem = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    
    NSString* string = [self.lowercaseString stringByTrimmingCharactersInSet:unitingSetItem];
    string = [[string componentsSeparatedByCharactersInSet:separatingSetItem] componentsJoinedByString:@" "];
    
    for (NSString* term in searchTerms)
    {
        if (![string contains:term] && ![string containsAbbreviation:term])
        {
            NSArray* synonymsPairs = @[@[@"&",@"and"],@[@"vs",@"versus"],
                                       @[@"i",    @"1"],@[@"ii",   @"2"],@[@"iii", @"3"],@[@"iv",  @"4"],@[@"v",    @"5"],@[@"vi",    @"6"],
                                       @[@"vii",  @"7"],@[@"viii", @"8"],@[@"ix",  @"9"],@[@"x",  @"10"],@[@"xi",  @"11"],@[@"xii",  @"12"],
                                       @[@"xiii",@"13"],@[@"xiv", @"14"],@[@"xv", @"15"],@[@"xvi",@"16"],@[@"xvii",@"17"],@[@"xviii",@"18"],
                                       @[@"xix", @"19"]];
            
            BOOL hadASynonym = NO;
            
            for (NSArray* pair in synonymsPairs)
            {
                if ([pair containsObject:term])
                {
                    hadASynonym = YES;
                    if (![string containsOneOfSynonyms:pair]) return NO;
                }
            }
            
            if (!hadASynonym) return NO;
        }
    }
    
    return YES;
}
-(NSArray*)searchTermsWithString
{
    NSArray* searchTerms;
    
    @autoreleasepool
    {
        NSCharacterSet* separatingSetSearch = [NSCharacterSet characterSetWithCharactersInString:@" :-*?!.,'+&()[]{}"];
        NSArray* mustIgnoreWords = @[@""];
        NSArray* mayIgnoreWords = @[@"a",@"of",@"the",@"in",@"to"];
        
        searchTerms = [self.lowercaseString componentsSeparatedByCharactersInSet:separatingSetSearch];
        
        NSMutableArray* clearSearchTerms = [searchTerms mutableCopy];
        [clearSearchTerms removeObjectsInArray:mustIgnoreWords];
        
        NSMutableArray* filteredSearchTerms = [clearSearchTerms mutableCopy];
        [filteredSearchTerms removeObjectsInArray:mayIgnoreWords];
        
        if (filteredSearchTerms.count == 0)
        {
            searchTerms = clearSearchTerms;
        }
        else
        {
            searchTerms = filteredSearchTerms;
        }
    }
    
    return searchTerms;
}

-(BOOL)matchesWithRegex:(NSString*)regexString
{
    BOOL result;
    
    @autoreleasepool
    {
        NSPredicate* regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
        result = [regex evaluateWithObject:self];
    }
    
    return result;
}
-(NSArray*)componentsMatchingWithRegex:(NSString*)regexString
{
    if (IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR)
    {
        NSMutableArray* matches;
        
        @autoreleasepool
        {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:NULL];
            NSArray* rangeArray = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
            
            matches = [[NSMutableArray alloc] init];
            for (NSTextCheckingResult *match in rangeArray)
            {
                [matches addObject:[self substringWithRange:match.range]];
            }
        }
        
        return matches;
    }
    
    NSString* pythonScriptPath = [NSString stringWithFormat:@"%@pythonRegex.py",NSTemporaryDirectory()];
    NSString* stringFilePath   = [NSString stringWithFormat:@"%@pythonFile.dat",NSTemporaryDirectory()];
    
    NSArray* pythonScriptContentsArray = @[@"import re",
                                           @"import os",
                                           @"dir_path = os.path.dirname(os.path.abspath(__file__))",
                                           @"text_file = open(dir_path + \"/pythonFile.dat\", \"r\")",
                                           @"text = text_file.read()",
                                           [NSString stringWithFormat:@"regex = re.compile(r\"(%@)\")",regexString],
                                           @"matches = regex.finditer(text)",
                                           @"for match in matches:",
                                           @"    print match.group()"];
    NSString* pythonScriptContents = [pythonScriptContentsArray componentsJoinedByString:@"\n"];
    
    [self                 writeToFile:stringFilePath   atomically:YES encoding:NSASCIIStringEncoding];
    [pythonScriptContents writeToFile:pythonScriptPath atomically:YES encoding:NSASCIIStringEncoding];
    
    NSString* output = [NSTask runCommand:@[@"python", pythonScriptPath]];
    NSMutableArray* outputList = [[output componentsSeparatedByString:@"\n"] mutableCopy];
    [outputList removeObject:@""];
    
    return outputList;
}

+(NSString*)humanReadableSizeForBytes:(long long int)bytes withDecimalMeasureSystem:(BOOL)measure
{
    NSString* result;
    
    @autoreleasepool
    {
        int degree = 0;
        int minorBytes = 0;
        int divisor = measure ? 1000 : 1024;
        
        while (bytes/divisor && degree < 8)
        {
            minorBytes=bytes%divisor;
            bytes/=divisor;
            degree++;
        }
        
        switch (degree)
        {
            case 0:  result = @"b";  break;
            case 1:  result = @"Kb"; break;
            case 2:  result = @"Mb"; break;
            case 3:  result = @"Gb"; break;
            case 4:  result = @"Tb"; break;
            case 5:  result = @"Pb"; break;
            case 6:  result = @"Eb"; break;
            case 7:  result = @"Zb"; break;
            default: result = @"Yb"; break;
        }
        
        minorBytes = ((minorBytes*1000)/divisor)/100;
        if (minorBytes) result = [NSString stringWithFormat:@".%d%@",minorBytes,result];
        
        result = [NSString stringWithFormat:@"%lld%@",bytes,result];
    }
    
    return result;
}
+(NSString*)stringWithHexString:(NSString*)string
{
    NSMutableString* newString;
    
    @autoreleasepool
    {
        newString = [[NSMutableString alloc] init];
        NSScanner* scanner = [[NSScanner alloc] initWithString:string];
        unsigned value;
        while ([scanner scanHexInt:&value])
        {
            if (value==0) [newString appendString:@"\0"];
            else [newString appendFormat:@"%c",(char)(value & 0xFF)];
        }
    }
    
    return newString;
}
+(NSString*)stringByRemovingEvenCharsFromString:(NSString*)text
{
    NSMutableString* text2;
    
    @autoreleasepool
    {
        text2 = [NSMutableString stringWithString:@""];
        
        for (int x = 0; x < text.length; x = x+2)
        {
            [text2 appendString:[text substringWithRange:NSMakeRange(x,1)]];
        }
    }
    
    return text2;
}
-(NSString*)stringToWebStructure
{
    NSString* webString;
    
    @autoreleasepool
    {
        webString = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        webString = [webString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        webString = [webString stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
        webString = [webString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        webString = [webString stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    }
    
    return webString;
}

-(NSRange)rangeAfterString:(NSString*)before andBeforeString:(NSString*)after
{
    NSRange beforeRange = before ? [self rangeOfString:before] : NSMakeRange(0, 0);
    
    if (beforeRange.location == NSNotFound)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    
    CGFloat afterBeforeRangeStart = beforeRange.location + beforeRange.length;
    NSRange afterBeforeRange = NSMakeRange(afterBeforeRangeStart, self.length - afterBeforeRangeStart);
    NSRange afterRange = after ? [self rangeOfString:after options:0 range:afterBeforeRange] : NSMakeRange(NSNotFound, 0);
    
    if (afterRange.location == NSNotFound)
    {
        return afterBeforeRange;
    }
    
    return NSMakeRange(afterBeforeRangeStart, afterRange.location - afterBeforeRangeStart);
}
-(NSString*)getFragmentAfter:(NSString*)before andBefore:(NSString*)after
{
    NSRange range = [self rangeAfterString:before andBeforeString:after];
    if (range.location != NSNotFound) return [self substringWithRange:range];
    return nil;
}

-(NSNumber*)initialIntegerValue
{
    NSNumber* numberValue;
    
    @autoreleasepool
    {
        NSMutableString* originalString = [self mutableCopy];
        NSMutableString* newString = [NSMutableString stringWithString:@""];
        NSRange firstCharRange = NSMakeRange(0, 1);
        
        while (originalString.length > 0 && [originalString characterAtIndex:0] >= '0' && [originalString characterAtIndex:0] <= '9')
        {
            [newString appendString:[originalString substringWithRange:firstCharRange]];
            [originalString deleteCharactersInRange:firstCharRange];
        }
        
        if (newString.length > 0) numberValue = [[NSNumber alloc] initWithInt:newString.intValue];
    }
    
    return numberValue;
}

+(NSString*)stringWithContentsOfFile:(NSString*)file encoding:(NSStringEncoding)enc
{
    if (![[NSFileManager defaultManager] regularFileExistsAtPath:file]) return nil;
    
    NSError* error;
    NSString* string = [self stringWithContentsOfFile:file encoding:enc error:&error];
    
    if (error)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while reading file: %@",nil), error.localizedDescription]];
    }
    
    return string;
}
+(NSString*)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc timeoutInterval:(long long int)timeoutInterval
{
    NSString* stringValue;
    
    @autoreleasepool
    {
        NSData* stringData = [NSData dataWithContentsOfURL:url timeoutInterval:timeoutInterval];
        
        stringValue = stringData ? [[NSString alloc] initWithData:stringData encoding:enc] : nil;
    }
    
    return stringValue;
}

-(BOOL)writeToFile:(NSString*)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc
{
    if (![[NSFileManager defaultManager] regularFileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createEmptyFileAtPath:path];
    }
    
    NSError* error;
    BOOL created = [self writeToFile:path atomically:useAuxiliaryFile encoding:enc error:&error];
    
    if (error)
    {
        [NSAlert showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:NSLocalizedString(@"Error while writting file: %@",nil), error.localizedDescription]];
    }
    
    return created;
}

-(NSData*)dataWithBase64Encoding
{
    if (IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR)
    {
        return [[NSData alloc] initWithBase64EncodedString:self options:0];
    }
    else
    {
        return [[NSData alloc] initWithBase64Encoding:self];
    }
}

-(BOOL)isAValidURL
{
    BOOL isValid = true;
    
    @autoreleasepool
    {
        if (![self hasPrefix:@"http://"] && ![self hasPrefix:@"https://"] && ![self hasPrefix:@"ftp://"])
        {
            isValid = false;
        }
        
        if (isValid)
        {
            NSURL *candidateURL = [NSURL URLWithString:self];
            isValid = candidateURL && candidateURL.scheme && candidateURL.host;
        }
    }
    
    return isValid;
}

@end
