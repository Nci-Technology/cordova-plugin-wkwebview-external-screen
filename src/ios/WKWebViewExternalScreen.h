#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>

@interface ExternalScreen : CDVPlugin

@property (nonatomic, strong)UIWindow* externalWindow;
@property (nonatomic, strong) WKWebView* externalWebView;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString* _callbackId;
@property (nonatomic) BOOL screenNeedsInit;

- (void)addEventListener:(CDVInvokedUrlCommand*)command;
- (void)checkAvailability:(CDVInvokedUrlCommand*)command;
- (void)invokeJavaScript:(CDVInvokedUrlCommand*)command;
- (void)loadHTML:(CDVInvokedUrlCommand*)command;
- (WKWebView*) getWebView;

//Instance Method
- (void) attemptSecondScreenView;
- (void) handleScreenConnectNotification:(NSNotification*)aNotification;
- (void) handleScreenDisconnectNotification:(NSNotification*)aNotification;
- (void) makeScreenVisible;
- (void) sendNotification:(NSString*)message;

@end
