//
//  VMMWebView.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 30/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "VMMWebView.h"

#import "NSString+Extension.h"

#import "NSComputerInformation.h"

@implementation VMMWebView

// WebView needed delegates
-(WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    return sender;
}
-(void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request
         frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSURL *urlToOpenUrl = actionInformation[WebActionOriginalURLKey];
    if (![self shouldLoadUrl:urlToOpenUrl withHttpBody:request.HTTPBody]) return;
    
    [listener use];
}

// WKWebView needed delegates
- (id)webView:(id)webView createWebViewWithConfiguration:(id)configuration forNavigationAction:(id)navigationAction windowFeatures:(id)windowFeatures
{
    return webView;
}
- (void)webView:(id)webView decidePolicyForNavigationAction:(id)navigationAction decisionHandler:(void (^)(NSInteger))decisionHandler
{
    NSURL *urlToOpenUrl = ((WKNavigationAction *)navigationAction).request.URL;
    if (![self shouldLoadUrl:urlToOpenUrl withHttpBody:((WKNavigationAction *)navigationAction).request.HTTPBody])
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// Private methods
-(void)reloadWebViewIfNeeded
{
    @synchronized(_webView)
    {
        if (!_webView)
        {
            _usingWkWebView = IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR;
            
            if (_usingWkWebView)
            {
                _webView = [[WKWebView alloc] init];
                WKWebView* webView = (WKWebView*)_webView;
                
                webView.UIDelegate = (id<WKUIDelegate>)self;
                webView.navigationDelegate = (id<WKNavigationDelegate>)self;
                
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
            [_webView setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
            [_webView setAutoresizingMask:NSViewMaxYMargin|NSViewMinYMargin|NSViewMaxXMargin|NSViewMinXMargin|
             NSViewWidthSizable|NSViewHeightSizable];
        }
    }
}

// Private functions that may be overrided
-(BOOL)shouldLoadUrl:(NSURL*)urlToOpenUrl withHttpBody:(NSData*)httpBody
{
    return YES;
}
-(NSString*)errorHTMLWithMessage:(NSString*)message
{
    // TODO: The text is not centered since a Sierra update
    NSString* result;
    
    @autoreleasepool
    {
        // BODY related values
        NSString* bodyStyle = @"margin: 0; padding: 0; height: 100%%; width: 100%%;";
        NSString* avoidRightClickVar = @"oncontextmenu=\"return false;\"";
        NSString* openBody = [NSString stringWithFormat:@"<BODY bgcolor=\"black\" style=\"%@\" %@>",bodyStyle,avoidRightClickVar];
        
        // DIV related values
        NSString* fontStyleVars = @"color:#FFFFFF; font-family: 'Helvetica Neue', Helvetica;";
        NSString* centeredStyleVars = @"position: absolute; top: 50%%; left: 50%%; transform: translateX(-50%%) translateY(-50%%); -webkit-transform: translate(-50%%, -50%%); -ms-transform: translateX(-50%%) translateY(-50%%); -webkit-transform: translateX(-50%%) translateY(-50%%); -moz-transform: translateX(-50%%) translateY(-50%%); -o-transform: translateX(-50%%) translateY(-50%%);";
        NSString* unselectableStyleVars = @"-webkit-touch-callout: none; -webkit-user-select: none; -khtml-user-select: none; -moz-user-select: none; -ms-user-select: none; user-select: none;";
        NSString* div = [NSString stringWithFormat:@"<div style=\"%@ %@ %@\">%@</div>",unselectableStyleVars,centeredStyleVars,fontStyleVars,message];
        
        result = [NSString stringWithFormat:@"<HTML><HEAD></HEAD>%@<center>%@</center></BODY></HTML>",openBody,div];
    }
    
    return result;
}

// Public functions
-(void)showErrorMessage:(NSString*)errorMessage
{
    [self reloadWebViewIfNeeded];
    [self loadHTMLString:[self errorHTMLWithMessage:[errorMessage uppercaseString]]];
}
-(BOOL)loadURL:(NSURL*)url
{
    if (!_usingWkWebView && [url.absoluteString contains:@"://www.youtube.com/v/"])
    {
        NSString* mainFolderPluginPath = @"/Library/Internet Plug-Ins/Flash Player.plugin";
        NSString* userFolderPluginPath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),mainFolderPluginPath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:mainFolderPluginPath] &&
            ![[NSFileManager defaultManager] fileExistsAtPath:userFolderPluginPath])
        {
            [self showErrorMessage:NSLocalizedString(@"You need Flash Player in order to watch YouTube videos in your macOS version",nil)];
            return NO;
        }
    }
    
    [self reloadWebViewIfNeeded];
    
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
-(BOOL)loadURLWithString:(NSString*)website
{
    if (![website isAValidURL])
    {
        [self showErrorMessage:NSLocalizedString(@"Invalid URL provided",nil)];
        return NO;
    }
    
    return [self loadURL:[NSURL URLWithString:website]];
}
-(void)loadHTMLString:(NSString*)htmlPage
{
    [self reloadWebViewIfNeeded];
    
    if (_usingWkWebView)
    {
        [(WKWebView*)self.webView loadHTMLString:htmlPage baseURL:[NSURL URLWithString:@"about:blank"]];
    }
    else
    {
        [((WebView*)self.webView).mainFrame loadHTMLString:htmlPage baseURL:[NSURL URLWithString:@"about:blank"]];
    }
}
-(void)loadEmptyPage
{
    [self loadHTMLString:@""];
}

@end

