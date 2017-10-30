//
//  VMMWebView.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 30/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface VMMWebView : NSView

@property (nonatomic) BOOL usingWkWebView;
@property (nonatomic, strong) NSView* webView;

-(void)showErrorMessage:(NSString*)errorMessage;

-(BOOL)loadURLWithString:(NSString*)website;
-(void)loadHTMLString:(NSString*)htmlPage;
-(void)loadEmptyPage;

@end

