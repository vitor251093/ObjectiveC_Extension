//
//  NSUtilitiesTests.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 05/07/16.
//  Copyright © 2016 Vitor Marques de Miranda. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSWebUtilities.h"

@interface NSUtilitiesTests : XCTestCase

@end

@implementation NSUtilitiesTests

- (void)testTimeNeededToDownloadWithSpeed
{
    NSString* expectedString;
    
    expectedString = [NSString stringWithFormat:NSLocalizedString(@"Time left:%@",nil),@" 1s"];
    XCTAssert([[NSWebUtilities timeNeededToDownload:1 withSpeed:1] isEqualToString:expectedString]);
    
    expectedString = [NSString stringWithFormat:NSLocalizedString(@"Time left:%@",nil),@" 1m"];
    XCTAssert([[NSWebUtilities timeNeededToDownload:60 withSpeed:1] isEqualToString:expectedString]);
    
    expectedString = [NSString stringWithFormat:NSLocalizedString(@"Time left:%@",nil),@" 1h"];
    XCTAssert([[NSWebUtilities timeNeededToDownload:3600 withSpeed:1] isEqualToString:expectedString]);
    
    expectedString = [NSString stringWithFormat:NSLocalizedString(@"Time left:%@",nil),@" 1d"];
    XCTAssert([[NSWebUtilities timeNeededToDownload:24*3600 withSpeed:1] isEqualToString:expectedString]);
    
    expectedString = [NSString stringWithFormat:NSLocalizedString(@"Time left:%@",nil),@" ∞"];
    XCTAssert([[NSWebUtilities timeNeededToDownload:10 withSpeed:0] isEqualToString:expectedString]);
}

@end
