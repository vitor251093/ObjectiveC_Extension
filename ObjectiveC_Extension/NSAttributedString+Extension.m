//
//  NSAttributedString+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 12/03/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSAttributedString+Extension.h"

@implementation NSAttributedString (VMMAttributedString)

-(instancetype)initWithHTMLData:(NSData*)data
{
    self = [self initWithData:data options:@{NSDocumentTypeDocumentAttribute:     NSHTMLTextDocumentType,
                                             NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
           documentAttributes:nil error:nil];
    return self;
}
-(instancetype)initWithHTMLString:(NSString*)string
{
    self = [self initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    return self;
}

-(NSString*)htmlString
{
    NSString* htmlString;
    
    @autoreleasepool
    {
        NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
        NSData *htmlData = [self dataFromRange:NSMakeRange(0, self.length) documentAttributes:documentAttributes error:NULL];
        htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
        
        // That solves the double-line bug
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    }
    
    return htmlString;
}

@end
