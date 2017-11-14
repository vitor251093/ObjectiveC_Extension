//
//  NSColorTests.m
//  ObjectiveC_ExtensionTests
//
//  Created by Vitor Marques de Miranda on 14/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSColor+Extension.h"

@interface NSColorTests : XCTestCase

@end

@implementation NSColorTests

-(void)testColorWithHexColorString
{
    NSColor* redColor = [NSColor colorWithHexColorString:@"FF0000"];
    
    XCTAssert(redColor.redComponent - 255 < 0.1);
    XCTAssert(redColor.greenComponent < 0.1);
    XCTAssert(redColor.blueComponent < 0.1);
}
-(void)testHexColorString
{
    NSColor* redColor = [NSColor redColor];
    NSString* redColorHex = [redColor hexColorString];
    
    XCTAssert([redColorHex isEqualToString:@"FF0000"]);
}

@end
