#import "WKWebViewExternalScreen.h"
#import <Cordova/CDVPluginResult.h>

@implementation ExternalScreen

NSString* WEBVIEW_UNAVAILABLE = @"External Web View Unavailable";
NSString* WEBVIEW_OK = @"OK";
NSString* SCREEN_NOTIFICATION_HANDLERS_OK =@"External screen notification handlers initialized";
NSString* SCREEN_CONNECTED =@"connected";
NSString* SCREEN_DISCONNECTED =@"disconnected";

//listen to events when screen is (dis)connected
- (void) addEventListener:(CDVInvokedUrlCommand*)command
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleScreenConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];

    self._callbackId = command.callbackId;
    [self attemptSecondScreenView];
}

- (void)checkAvailability:(CDVInvokedUrlCommand*)command
{
    BOOL result = ([[UIScreen screens] count] > 1);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (WKWebView*)getWebView {
    if (!self.externalWebView) {
        UIScreen* externalScreen = [[UIScreen screens] objectAtIndex: 1];
        CGRect screenBounds = externalScreen.bounds;

        self.externalWebView = [[WKWebView alloc] initWithFrame: screenBounds
                                                  configuration: [[WKWebViewConfiguration alloc] init]];
        self.externalWindow = [[UIWindow alloc] initWithFrame: screenBounds];
        externalScreen.overscanCompensation = UIScreenOverscanCompensationNone;
        [self.externalWebView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        self.externalWindow.screen = externalScreen;
        self.externalWindow.clipsToBounds = YES;
        [self.externalWindow addSubview:self.externalWebView];
        [self.externalWindow makeKeyAndVisible];
        self.externalWindow.hidden = NO;
    }
    return self.externalWebView;
}

- (void)invokeJavaScript:(CDVInvokedUrlCommand*)command
{
    if ([[UIScreen screens] count] > 1) {
        NSArray *arguments = command.arguments;
        NSString *stringObtainedFromJavascript = [arguments objectAtIndex:0];
        [[self getWebView] evaluateJavaScript:stringObtainedFromJavascript completionHandler:nil];
    }
}

- (void)disconnect:(CDVInvokedUrlCommand*)command
{
    if ([[UIScreen screens] count] > 1) {
       [self.externalWindow addSubview:self.webView];
    }
}

- (void)loadHTML:(CDVInvokedUrlCommand*)command {
    if ([[UIScreen screens] count] > 1) {
        // NSArray *arguments = command.arguments;
        // NSString *file = [arguments objectAtIndex:0];

        // NSString* baseURLAddress = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
        // NSString* a = @"file://";
        // baseURLAddress = [a stringByAppendingString:baseURLAddress];
        // NSString* path = [NSString stringWithFormat:@"%@/%@", baseURLAddress, file];
        // NSURL *nsurl = [NSURL URLWithString:[file stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        // NSURLRequest *request=[NSURLRequest requestWithURL:nsurl];
        // [[self getWebView] loadRequest: request];
        // CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
        // [self.commandDelegate sendPluginResult: result
        //                             callbackId: command.callbackId];

        NSArray *arguments = command.arguments;
        NSString *file = [arguments objectAtIndex:0];
        self.baseURL = [NSURL URLWithString:[file stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        self._callbackId = command.callbackId;
        [self attemptSecondScreenView];
    }
}

//invoked when an additional screen is connected to iOS device (VGA or Airplay)
- (void)handleScreenConnectNotification:(NSNotification*)aNotification
{
    if (!self.externalWindow)
    {
        [self attemptSecondScreenView];
    }
}

//invoked when an additional screen is disconnected
- (void)handleScreenDisconnectNotification:(NSNotification*)aNotification
{
    if (self.externalWindow)
    {
        self.externalWindow.hidden = YES;
        self.externalWindow = nil;
    }
    
    if (self.externalWebView)
    {
        self.externalWebView = nil;
    }
    
    if (self._callbackId) {
        // Send notification
        [self sendNotification:SCREEN_DISCONNECTED];
    }
}


// Show external screen web view
- (void) show:(CDVInvokedUrlCommand*)command
{
    if (!self.externalWindow)
    {
        [self attemptSecondScreenView];
    } else {
        self.externalWindow.hidden = NO;
    }
}

// Hide external screen web view
- (void) hide:(CDVInvokedUrlCommand*)command
{
    self.externalWindow.hidden = YES;
}


- (void) attemptSecondScreenView
{
    if ([[UIScreen screens] count] > 1) {
        // externalScreen = [[UIScreen screens] objectAtIndex:1];
        
        // CGRect        screenBounds = externalScreen.bounds;
        
        // externalWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        // externalWindow.screen = externalScreen;
        
        // externalWindow.frame = screenBounds;
        // externalWindow.clipsToBounds = YES;
        
        // webView = [[UIWebView alloc] initWithFrame:screenBounds];

        // baseURLAddress = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
        
        // baseURL = [NSURL URLWithString:baseURLAddress];


        // NSString* baseURLAddress = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
        // // NSString* a = @"file://";
        // baseURLAddress = [a stringByAppendingString:baseURLAddress];
        // NSString* path = [NSString stringWithFormat:@"%@/%@", baseURLAddress, file];
        NSURLRequest *request=[NSURLRequest requestWithURL:self.baseURL];
        [[self getWebView] loadRequest: request];
        if (self._callbackId) {
            self.screenNeedsInit = YES;
            [self sendNotification:SCREEN_CONNECTED];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult: result
                                    callbackId: self._callbackId];
        }else{
            [self makeScreenVisible];
        }

        // If we have a callback we don't want to initialise the screen with a loading message, instead notify javascript and make visible later.
        // if (_callbackId) {
        //     screenNeedsInit = YES;
            
        //     // Since we have a callback we're going to assume that content is about to be loaded so we probably want a black background
        //     [webView setBackgroundColor:[UIColor blackColor]];

        //     // Send notification
        //     [self sendNotification:SCREEN_CONNECTED];
        // }
        // else {
        //     [webView loadHTMLString:@"loading..." baseURL:baseURL];

        //     [self makeScreenVisible];
        // }
    }
    else
    {
        self.externalWindow.hidden = YES;
    }
}

// Make the second screen visible.
- (void) makeScreenVisible
{
    [self.externalWindow addSubview:self.externalWebView];
    [self.externalWindow makeKeyAndVisible];
    self.externalWindow.hidden = NO;
    self.screenNeedsInit = NO;
}

// Let javascript know that the screen connection status has changed.
- (void) sendNotification:(NSString*)message
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: message];

    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self._callbackId];
}


@end
