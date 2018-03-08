//
//  VMMWebView.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 30/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMWebView.h"

#import "NSColor+Extension.h"
#import "NSString+Extension.h"
#import "NSMutableAttributedString+Extension.h"

#import "VMMComputerInformation.h"
#import "VMMLocalizationUtility.h"

@implementation VMMWebViewNavigationBar
@end

@implementation VMMWebView

-(void)setLastAccessedUrl:(NSURL*)lastAccessedUrl
{
    _lastAccessedUrl = lastAccessedUrl;
    
    if (self.hasNavigationBar)
    {
        [_navigationBar.addressBarField setStringValue:_lastAccessedUrl.absoluteString];
    }
}

// WebView needed delegates
-(WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    self.lastAccessedUrl = request.URL;
    return sender;
}
-(void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request
         frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSData* httpBody = request.HTTPBody;
    
    NSURL* url = actionInformation[WebActionOriginalURLKey];
    if (![self shouldLoadUrl:url withHttpBody:httpBody]) return;
    
    [listener use];
}

// WKWebView needed delegates
- (id)webView:(id)webView createWebViewWithConfiguration:(id)configuration forNavigationAction:(id)navigationAction windowFeatures:(id)windowFeatures
{
    NSData* httpBody = ((WKNavigationAction *)navigationAction).request.HTTPBody;
    
    self.lastAccessedUrl = ((WKNavigationAction *)navigationAction).request.URL;
    if (![self shouldLoadUrl:_lastAccessedUrl withHttpBody:httpBody]) return nil;
    
    [self loadURL:_lastAccessedUrl];
    return nil;
}
- (void)webView:(id)webView decidePolicyForNavigationAction:(id)navigationAction decisionHandler:(void (^)(NSInteger))decisionHandler
{
    NSData* httpBody = ((WKNavigationAction *)navigationAction).request.HTTPBody;
    
    NSURL *urlToOpenUrl = ((WKNavigationAction *)navigationAction).request.URL;
    if (![self shouldLoadUrl:urlToOpenUrl withHttpBody:httpBody])
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)webView:(id)webView didCommitNavigation:(id)navigation
{
    self.lastAccessedUrl = [(WKWebView*)self.webView URL];
}

// Initialization private methods
-(void)initializeWebView
{
    _usingWkWebView = IsClassWKWebViewAvailable;
    
    if (_usingWkWebView)
    {
        _webView = [[WKWebView alloc] init];
        WKWebView* webView = (WKWebView*)_webView;
        
        webView.UIDelegate = (id<WKUIDelegate>)self;
        webView.navigationDelegate = (id<WKNavigationDelegate>)self;
        
        webView.allowsMagnification = true;
        
        [webView setValue:@FALSE forKey:@"opaque"];
        
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
        BOOL setDrawsBackgroundExists = [webView respondsToSelector:@selector(_setDrawsBackground:)];
#pragma GCC diagnostic pop
        
        if (setDrawsBackgroundExists)
        {
            [webView setValue:@FALSE forKey:@"drawsBackground"];
        }
        else
        {
            [webView setValue:@TRUE  forKey:@"drawsTransparentBackground"];
        }
    }
    else
    {
        _webView = [[WebView alloc] init];
        WebView* webView = (WebView*)_webView;
        
        webView.UIDelegate = (id<WebUIDelegate>)self;
        webView.policyDelegate = (id<WebPolicyDelegate>)self;
        webView.frameLoadDelegate = (id<WebFrameLoadDelegate>)self;
        
        webView.shouldUpdateWhileOffscreen = false;
        
        [webView setValue:@FALSE forKey:@"opaque"];
        
        [webView setValue:@FALSE forKey:@"drawsBackground"];
    }
    
    [self addSubview:_webView];
    [_webView setAutoresizingMask:NSViewMinYMargin|NSViewMaxXMargin|NSViewMinXMargin|NSViewWidthSizable|NSViewHeightSizable];
}
-(void)initializeNavigationBarWithHeight:(CGFloat)navigationBarHeight
{
    _navigationBar = [[VMMWebViewNavigationBar alloc] init];
    
    [self addSubview:_navigationBar];
    [_navigationBar setAutoresizingMask:NSViewMinYMargin|NSViewMaxXMargin|NSViewMinXMargin|NSViewWidthSizable];
    [_navigationBar setBackgroundColor:self.navigationBarColor];
    
    NSFont* buttonTextFont = self.navigationBarButtonsTextFont;
    if (buttonTextFont != nil)
    {
        buttonTextFont = [NSFont fontWithDescriptor:buttonTextFont.fontDescriptor size:self.navigationBarButtonsTextSize];
    }
    else
    {
        buttonTextFont = [NSFont systemFontOfSize:self.navigationBarButtonsTextSize];
    }
    
    NSFont* addressTextFont = self.navigationBarAddressFieldTextFont;
    if (addressTextFont != nil)
    {
        addressTextFont = [NSFont fontWithDescriptor:addressTextFont.fontDescriptor size:self.navigationBarAddressFieldTextSize];
    }
    else
    {
        addressTextFont = [NSFont systemFontOfSize:self.navigationBarAddressFieldTextSize];
    }
    
    CGFloat fullWidth = _navigationBar.frame.size.width;
    CGFloat leftMargin = self.navigationBarLeftMargin;
    
    _navigationBar.addressBarField = [[NSTextField alloc] init];
    _navigationBar.refreshButton = [[NSButton alloc] init];
    [_navigationBar addSubview:_navigationBar.addressBarField];
    [_navigationBar addSubview:_navigationBar.refreshButton];
    
    
    [_navigationBar.addressBarField setAutoresizingMask:NSViewWidthSizable];
    [_navigationBar.addressBarField setBordered:NO];
    [_navigationBar.addressBarField setEditable:NO];
    [_navigationBar.addressBarField setBackgroundColor:self.navigationBarColor];
    [_navigationBar.addressBarField setFont:addressTextFont];
    [_navigationBar.addressBarField setStringValue:VMMLocalizationNotNeeded(@"Tj")];
    CGFloat addressMaxHeight = _navigationBar.addressBarField.attributedStringValue.size.height;
    [_navigationBar.addressBarField setFrame:NSMakeRect(leftMargin, (navigationBarHeight - addressMaxHeight)/2,
                                                        fullWidth - navigationBarHeight - leftMargin, addressMaxHeight)];
    [_navigationBar.addressBarField setStringValue:@""];
    
    
    [_navigationBar.refreshButton.cell setHighlightsBy:NSNoCellMask];
    [_navigationBar.refreshButton setBordered:NO];
    
    NSMutableAttributedString* title = [[NSMutableAttributedString alloc] initWithString:@"⟳"];
    [title setFont:buttonTextFont];
    [title setFontColor:self.navigationBarButtonsTextColor];
    [_navigationBar.refreshButton setAttributedTitle:title];
    
    [_navigationBar.refreshButton setTarget:self];
    [_navigationBar.refreshButton setAction:@selector(refreshButtonPressed:)];
    [_navigationBar.refreshButton setAutoresizingMask:NSViewMaxYMargin|NSViewMinYMargin|NSViewMinXMargin];
    [_navigationBar.refreshButton setFrame:NSMakeRect(fullWidth - navigationBarHeight, 0, navigationBarHeight, navigationBarHeight)];
}
-(void)initializeErrorLabel
{
    _webViewErrorLabel = [[NSTextField alloc] init];
    
    [self addSubview:_webViewErrorLabel];
    [_webViewErrorLabel setAutoresizingMask:NSViewMaxYMargin|NSViewMinYMargin|NSViewWidthSizable];
    
    NSFont* webViewTextFont = self.webViewErrorLabelTextFont;
    if (webViewTextFont != nil)
    {
        webViewTextFont = [NSFont fontWithDescriptor:webViewTextFont.fontDescriptor size:self.webViewErrorLabelTextSize];
    }
    else
    {
        webViewTextFont = [NSFont systemFontOfSize:self.webViewErrorLabelTextSize];
    }
    [_webViewErrorLabel setFont:webViewTextFont];
    [_webViewErrorLabel setEditable:NO];
    [_webViewErrorLabel setBordered:NO];
    [_webViewErrorLabel setSelectable:NO];
    [_webViewErrorLabel setAlignment:IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR ? NSTextAlignmentCenter : NSCenterTextAlignment];
    [_webViewErrorLabel setBackgroundColor:[NSColor clearColor]];
    [_webViewErrorLabel setTextColor:[NSColor whiteColor]];
    [self setErrorLabelHidden:YES];
}
-(void)initializeOtherComponents
{
    
}
-(void)reloadWebViewIfNeeded
{
    @synchronized(_webView)
    {
        BOOL loadingForTheFirstTime = (_webView == nil);
        
        if (_webViewErrorLabel)
        {
            [_webViewErrorLabel setStringValue:@""];
            [self setErrorLabelHidden:YES];
        }
        
        BOOL hasNavigationBar = self.hasNavigationBar;
        
        CGFloat width = self.frame.size.width;
        CGFloat navigationBarHeight = 0;
        
        if (hasNavigationBar)
        {
            navigationBarHeight = self.navigationBarHeight;
            if (!_navigationBar) [self initializeNavigationBarWithHeight:navigationBarHeight];
        }
        
        if (loadingForTheFirstTime)
        {
            [self initializeWebView];
            [self initializeErrorLabel];
        }
        
        CGFloat webViewHeight = self.frame.size.height - navigationBarHeight;
        
        if (hasNavigationBar)
        {
            [_navigationBar setFrame:NSMakeRect(0, webViewHeight, width, navigationBarHeight)];
        }
        
        [_webView setFrame:NSMakeRect(0, 0, width, webViewHeight)];
        
        if (loadingForTheFirstTime)
        {
            [self initializeOtherComponents];
        }
    }
}

// Private functions
-(IBAction)refreshButtonPressed:(id)sender
{
    [self loadURL:_lastAccessedUrl];
}
-(void)setErrorLabelHidden:(BOOL)isHidden
{
    _webViewErrorLabel.hidden = isHidden;
    _webView.hidden = !isHidden;
    
    if (isHidden)
    {
        [self setBackgroundColor:[NSColor clearColor]];
    }
    else
    {
        [self setBackgroundColor:[NSColor blackColor]];
    }
}

// Private functions that may be overrided
-(BOOL)hasNavigationBar
{
    return _urlLoaded;
}
-(CGFloat)navigationBarLeftMargin
{
    return 20.0;
}
-(CGFloat)navigationBarHeight
{
    return 45.0;
}
-(NSColor*)navigationBarColor
{
    return RGB(209, 207, 209);
}
-(NSFont*)navigationBarAddressFieldTextFont
{
    return nil;
}
-(CGFloat)navigationBarAddressFieldTextSize
{
    return 15.0;
}
-(NSFont*)navigationBarButtonsTextFont
{
    return nil;
}
-(CGFloat)navigationBarButtonsTextSize
{
    return 30.0;
}
-(NSColor*)navigationBarButtonsTextColor
{
    return [NSColor blackColor];
}
-(NSFont*)webViewErrorLabelTextFont
{
    return [NSFont boldSystemFontOfSize:self.webViewErrorLabelTextSize];
}
-(CGFloat)webViewErrorLabelTextSize
{
    return 25.0;
}
-(BOOL)shouldLoadUrl:(NSURL*)urlToOpenUrl withHttpBody:(NSData*)httpBody
{
    return YES;
}

// Public functions
-(BOOL)loadURL:(nonnull NSURL*)url
{
    if (!_usingWkWebView && [url.absoluteString contains:@"://www.youtube.com/v/"])
    {
        NSString* mainFolderPluginPath = @"/Library/Internet Plug-Ins/Flash Player.plugin";
        NSString* userFolderPluginPath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),mainFolderPluginPath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:mainFolderPluginPath] &&
            ![[NSFileManager defaultManager] fileExistsAtPath:userFolderPluginPath])
        {
            [self showErrorMessage:VMMLocalizedString(@"You need Flash Player in order to watch YouTube videos in your macOS version")];
            return NO;
        }
    }
    
    _urlLoaded = true;
    [self reloadWebViewIfNeeded];
    self.lastAccessedUrl = url;
    
    if (_usingWkWebView)
    {
        [(WKWebView*)self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    else
    {
        [((WebView*)self.webView).mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    return YES;
}
-(BOOL)loadURLWithString:(nonnull NSString*)website
{
    if (![website isAValidURL])
    {
        [self showErrorMessage:VMMLocalizedString(@"Invalid URL provided")];
        return NO;
    }
    
    return [self loadURL:[NSURL URLWithString:website]];
}
-(void)loadHTMLString:(nonnull NSString*)htmlPage
{
    _urlLoaded = false;
    [self reloadWebViewIfNeeded];
    NSURL* url = [NSURL URLWithString:@"about:blank"];
    
    if (_usingWkWebView)
    {
        [(WKWebView*)self.webView loadHTMLString:htmlPage baseURL:url];
    }
    else
    {
        [((WebView*)self.webView).mainFrame loadHTMLString:htmlPage baseURL:url];
    }
}
-(void)showErrorMessage:(nonnull NSString*)errorMessage
{
    [self loadHTMLString:@"<HTML><BODY bgcolor=\"black\" style=\"margin: 0; padding: 0; height: 100%%; width: 100%%;\" oncontextmenu=\"return false;\"></BODY></HTML>"];
    
    [_webViewErrorLabel setStringValue:[errorMessage uppercaseString]];
    CGFloat textHeight = _webViewErrorLabel.attributedStringValue.size.height;
    
    [_webViewErrorLabel setFrame:NSMakeRect(0, (self.frame.size.height - textHeight)/2, self.frame.size.width, textHeight)];
    [self setErrorLabelHidden:NO];
}
-(void)loadEmptyPage
{
    [self loadHTMLString:@""];
}

@end

