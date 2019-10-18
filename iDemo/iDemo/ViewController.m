//
//  ViewController.m
//  iDemo
//
//  Created by mac on 2019/9/18.
//  Copyright © 2019 com.xman-sao. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"
#import "NSData+AES.h"
#import "GTMBase64.h"
#import <objc/message.h>
#import "Tools.h"
#import "WXApi.h"

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WXApiDelegate>
@property (nonatomic, strong)  WKWebView* webView;
@property WebViewJavascriptBridge* bridge;
@property (nonatomic, strong) dispatch_source_t gcdTimer;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *duration;
@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)loadWebView:(WKWebView *)webview{
    NSURL *url = [NSURL URLWithString:[Tools loadUrl]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webview loadRequest:request];
}
- (void)refreshEvn{
    [self loadWebView:self.webView];
}
- (void)reloadView{
    [self.webView reload];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
    [noti addObserver:self selector:@selector(refreshEvn) name:@"changeUrl" object:nil];
    
    NSNotificationCenter *fgNoti = [NSNotificationCenter defaultCenter];
    [fgNoti addObserver:self selector:@selector(reloadView) name:@"checkWhenEnterForeground" object:nil];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.webView];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView: self.webView];
    [_bridge setWebViewDelegate:self];
    //=====================================获取设备信息=========================================
    [_bridge registerHandler:@"gotUserDeviceInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *deviceInfo = @{@"IDFA":[Tools loadIDFA],
                                     @"openUDID":[Tools loadOpenUDID],
                                     @"ip":[Tools loadRealIP],
                                     @"phoneType":[Tools platformString],
                                     @"appVersion":[Tools appVersion],
                                     @"iOSVersison":[Tools iOSVersion],
                                     @"boundleID":[Tools appIdentifier],
                                     @"isJailBreak":[NSString stringWithFormat:@"%d",[Tools isJailBreak]]
                                     };
        responseCallback(deviceInfo);
    }];
    //=========================================修改环境===========================================

//    [_bridge registerHandler:@"changeEnv" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSDictionary *jsInfo = data;
//        NSString *envURL = jsInfo[@"envUrl"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:envURL]];
//        [self.webView loadRequest:request];
//    }];
    //=========================================开启后台刷新===========================================
    
    [_bridge registerHandler:@"checkWhenEnterForeground" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *jsInfo = data;
        [Tools sharedInstance].isOpen = [jsInfo[@"isOpen"] integerValue];
    }];
    //=========================================加密===========================================
    [_bridge registerHandler:@"encrypt" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *infoData = data;
        NSString *reqStr = [Tools encriptWithJSInfo:infoData];
        responseCallback( @{@"dataSign":[Tools md532BitUpper:reqStr],@"dataReq":reqStr});
    }];
    //========================================解密==============================================
    [_bridge registerHandler:@"decrpt" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *jsInfo = data;
        NSString *dataReqStr = jsInfo[@"dataReq"];
        if (dataReqStr.length ==0) {
            return ;
        }
        if ([jsInfo[@"dataSign"] isEqualToString:[Tools md532BitUpper:dataReqStr]]) {
            NSDictionary *data = [Tools decriptWithJSInfo:jsInfo[@"dataReq"]];
            responseCallback(@{@"info":data});
        }else{
            responseCallback(@{@"info":@"dataSign error"});
        }
    }];
    //=======================================显示分享链接===========================================
    [_bridge registerHandler:@"showLinkPasteView" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dataDic = data;
        [Tools genreateLinkOnView:self.view withInfo:dataDic];
    }];
    //=======================================显示分享二维码==========================================
    [_bridge registerHandler:@"showQRShareView" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dataDic = data;
        [Tools generateQRCodeOnView:self.view withInfo:dataDic];
    }];
    //=======================================开启服务器设备校验========================================
    [_bridge registerHandler:@"startServerCheckDeviceInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dataDic = data;
        [self openRelationshipWithUrl:dataDic[@"dfUrl"]];
    }];
    //========================================使用微信登陆=========================================
    [_bridge registerHandler:@"loginByWechat" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self wxLogin];
        responseCallback(@{@"info":@"wxlogin"});

    }];
    //========================================分享给微信===========================================
    [_bridge registerHandler:@"shareToWechat" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dataDic = data;
        NSString *urlString = dataDic[@"url"];
        NSURL *shareUrl = [NSURL URLWithString:urlString];
        NSArray *items = @[shareUrl];
//        [Tools shareToWechatWithInfo:dataDic];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }];
    //========================================打开本地应用========================================
    [_bridge registerHandler:@"openLoApplic" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *recData =data;
        NSString *className = recData[@"cn"];
        NSString *methodName = recData[@"mn"];
        NSString *bdid = recData[@"bdid"];
        const  char *methodStr = [methodName UTF8String];
        BOOL isOpen = ((BOOL (*)(id, SEL,id))objc_msgSend)( [NSClassFromString(className) new], sel_registerName(methodStr),bdid);
        if (isOpen) {
            NSDictionary *rsp = @{@"info":@"isOpen"};
            responseCallback(rsp);
        }else{
            NSDictionary *rsp = @{@"info":@"notOpen"};
            responseCallback(rsp);
        }
    }];
    //===================================检查设备是否充电状态==========================================
    [_bridge registerHandler:@"checkDeviceChargeState" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *state = [Tools loadCurrentChargeState];
        NSDictionary *rspData = @{@"chargeState":state};
        responseCallback(rspData);
    }];
    //============================检查设备已安装应用 iOS 11以上不可用====================================
    //
    [_bridge registerHandler:@"checkDeviceJailbreakState" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@{@"info":@"unimplementation"});
    }];
    //======================================启动本地定时器==========================================
    [_bridge registerHandler:@"startLoaclTimer" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 启动任务，GCD计时器创建后需要手动启动
        NSDictionary *recData =data;
        NSString *duration = recData[@"duration"];
        [self StartTimerWithDuration:duration];
        
        responseCallback(@{@"info":@"startTimer"});
    }];
    //======================================停止本地定时器==========================================
    [_bridge registerHandler:@"stopLoaclTimer" handler:^(id data, WVJBResponseCallback responseCallback) {
        dispatch_suspend(self.gcdTimer);
        responseCallback(@{@"info":@"StopTimer"});
    }];
   
    //========================================隐藏导航栏==================================================
    [_bridge registerHandler:@"hiddenNavigationBar" handler:^(id data, WVJBResponseCallback responseCallback) {
        self.navigationController.navigationBarHidden = YES;
    }];
    //========================================建立师徒关系==================================================
    [_bridge registerHandler:@"buildRelationShip" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dataDic = data;
        [self openRelationshipWithUrl:dataDic[@"rsUrl"]];
    }];
    //===========================================END===============================================
    
    self.gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
}
- (void)StartTimerWithDuration:(NSString *)duration{
    if ([duration isEqualToString:@""] || duration == nil) {
        NSDictionary *data = @{@"info": @"TimerError",
                               };
        [_bridge callHandler:@"errorDuration" data:data responseCallback:^(id responseData) {
        }];
        return;
    }
    
    int durationInt = [duration intValue];
    self.startTime = [Tools currentTime];
    self.endTime = [Tools affterCurrentTime:durationInt];
    dispatch_source_set_timer(self.gcdTimer, DISPATCH_TIME_NOW, durationInt*1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_gcdTimer, ^{
        if ([self.endTime isEqualToString:[Tools currentTime]]) {
            dispatch_suspend(self.gcdTimer);
            __weak __typeof(self) weakself= self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself stopTime];
            });
        }
    });
    dispatch_resume(self.gcdTimer);
}
- (void)stopTime{
    NSDictionary *data = @{@"info": @"EndTimer",
                           @"time":[Tools currentTime]
                           };
    [_bridge callHandler:@"stopTimer" data:data responseCallback:^(id responseData) {
        dispatch_suspend(self.gcdTimer);
    }];
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//OC调用JS
//- (void)callHandler:(id)sender {
//
//    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
//        NSLog(@"testJavascriptHandler responded: %@", response);
//        [self.view makeToast:[NSString stringWithFormat:@"%@", response?response:@"error"] duration:1.5 position:CSToastPositionCenter];
//    }];
//}

- (void)wxLogin{
    //    SendAuthReq* req = [[SendAuthReq alloc] init];
    //    req.scope = @"snsapi_userinfo";
    //    req.state = @"App";
    //    [WXApi sendAuthReq:req viewController:self delegate:self];
    if([WXApi isWXAppInstalled]){//判断用户是否已安装微信App
        
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.state = @"wx_oauth_authorization_state";//用于保持请求和回调的状态，授权请求或原样带回
        req.scope = @"snsapi_userinfo";//授权作用域：获取用户个人信息
        //唤起微信
        [WXApi sendReq:req];
    }else{
        //自己简单封装的alert
        //        [self.view makeToast:@"未安装微信应用或版本过低" duration:1.5 position:CSToastPositionCenter];
    }
}

-(void)onResp:(BaseResp*)resp {
    if([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp* authResp = (SendAuthResp*)resp;
        /* Prevent Cross Site Request Forgery */
        if (![authResp.state isEqualToString:@"App"]) {
            //            if (self.delegate && [self.delegate respondsToSelector:@selector(wxAuthDenied)])
            //                [self.delegate wxAuthDenied];
            return;
        }
        
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"RESP:code:%@,state:%@\n", authResp.code, authResp.state);
                //                if (self.delegate && [self.delegate respondsToSelector:@selector(wxAuthSucceed:)])
                //                    [self.delegate wxAuthSucceed:authResp.code];
                break;
            case WXErrCodeAuthDeny:
                //                if (self.delegate && [self.delegate respondsToSelector:@selector(wxAuthDenied)])
                //                    [self.delegate wxAuthDenied];
                break;
            case WXErrCodeUserCancel:
                //                if (self.delegate && [self.delegate respondsToSelector:@selector(wxAuthCancel)])
                //                    [self.delegate wxAuthCancel];
            default:
                break;
        }
    }
}

- (void)sendWXInfo:(NSNotification *)noti{
    NSDictionary *wxInfo = noti.userInfo;
    NSDictionary *data = @{@"info": wxInfo};
    [_bridge callHandler:@"gotWeChatUserInfo" data:data responseCallback:^(id responseData) {
    }];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"weiChatOK" object:self];
}

- (void)textFieldEditChanged:(UITextField*)textField{
    self.urlStr = textField.text;
}
-(void)openRelationshipWithUrl:(NSString*)urlStrl{
    NSURL *url = [ [ NSURL alloc ] initWithString:urlStrl];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
