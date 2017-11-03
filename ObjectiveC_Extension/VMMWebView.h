//
//  VMMWebView.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 30/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface VMMWebViewNavigationBar : NSView
@property (nonatomic, strong) NSColor* backgroundColor;
@property (nonatomic, strong) NSTextField* addressBarField;
@property (nonatomic, strong) NSButton* refreshButton;
@end

@interface VMMWebView : NSView

@property (nonatomic) BOOL urlLoaded;
@property (nonatomic) BOOL usingWkWebView;
@property (nonatomic, strong) NSView* webView;
@property (nonatomic, strong) VMMWebViewNavigationBar* navigationBar;

@property (nonatomic, strong) NSURL* lastAccessedUrl;

-(void)showErrorMessage:(NSString*)errorMessage;

-(BOOL)loadURL:(NSURL*)url;
-(BOOL)loadURLWithString:(NSString*)website;
-(void)loadHTMLString:(NSString*)htmlPage;
-(void)loadEmptyPage;

@end

