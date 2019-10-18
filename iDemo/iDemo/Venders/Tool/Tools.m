//
//  XFCoreTool.m
//  MyFood
//
//  Created by mac on 2019/8/27.
//  Copyright © 2019 com.xman. All rights reserved.
//

#import "Tools.h"
#import "OpenUDID.h"
#import <ifaddrs.h>
#import <net/if.h>
#import <arpa/inet.h>
#import <sys/utsname.h>
#import "WXApi.h"
#import "UIImage+QR.h"
#import<CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <AdSupport/AdSupport.h>
#import "NSData+AES.h"
#import "GTMBase64.h"

@interface Tools()<UIGestureRecognizerDelegate>
//{
//    HTTPServer *httpServer;
//}
@property (nonatomic, strong) UIView *bgView ;
@end

@implementation Tools

NSString *pasteStr;
UIView *delegateView;

NSString *aesKey = @"8D4F16E8F94796FC";
NSString *aesIv = @"0102030405060708";

+(instancetype)sharedInstance{
    
    static Tools *cTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        cTool = [[Tools alloc]init];
    });
    return cTool;
}

+ (NSString *)xfCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    return timeString;
}
+ (NSString *)unixTime{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    long long int currentTime = (long long int)time;
    NSString *unixTime = [NSString stringWithFormat:@"%lld000", currentTime];
    return unixTime;
}

+ (NSString* )loadCurrentChargeState{
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    NSString *chargeStr = @"";
    switch (batteryState) {
        case UIDeviceBatteryStateUnknown:
            chargeStr = @"未知";
            NSLog(@"未知");
            break;
        case UIDeviceBatteryStateUnplugged:
            NSLog(@"未充电");
            chargeStr = @"未充电";
            break;
        case UIDeviceBatteryStateCharging:
            NSLog(@"正在充电");
            chargeStr = @"正在充电";
            break;
        case UIDeviceBatteryStateFull:
            NSLog(@"满电");
            chargeStr = @"满电";
            break;
        default:
            break;
    }
    return chargeStr;
}

+ (NSString *)loadIDFA{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}
+ (NSString *)loadOpenUDID{
    return [OpenUDID value];
}

+ (void)saveRootController{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:@"XFContactUSController" forKey:@"saveRootController"];
}
+ (NSString *)loadRootController{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *rootVC = [userDef objectForKey:@"saveRootController"];
    return rootVC?rootVC:@"XFRootController";
}

- (void)startServer{
//    NSError *error;
//    if([httpServer start:&error])
//    {
//        NSUserDefaults *userdefault =  [NSUserDefaults standardUserDefaults];
//        [userdefault setObject:[NSString stringWithFormat:@"%hu",[httpServer listeningPort]] forKey:@"port"];
//        NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
//        NSUserDefaults *usefault = [NSUserDefaults standardUserDefaults];
//        [usefault setObject:[NSString stringWithFormat:@"%hu",[httpServer listeningPort]] forKey:@"port"];
//    }
//    else
//    {
//        NSLog(@"Error starting HTTP Server: %@", error);
//
//    }
}

- (void)startLoaclHttpServer{
//    httpServer = [[HTTPServer alloc] init];
//    [httpServer setType:@"_http._tcp."];
//    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@""];
//    NSLog(@"Setting document root: %@", webPath);
//    [httpServer setDocumentRoot:webPath];
//    [self edustartServer];
}


+(BOOL)isJailBreak
{
    return  ([Tools isJailBreakWithAllAppName] || [Tools isJailBreakWithCydia]);
}

+ (BOOL)isJailBreakWithCydia
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isJailBreakWithAllAppName
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"])
    {
        return YES;
    }
    
    return NO;
}
+ (NSString *)localIP
{
    return [[Tools sharedInstance] localIP];
}

- (NSString *)localIP
{
    return @"";
}
+ (void)saveRealIP:(NSString *)ip{
    NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
    [defau setObject:ip forKey:@"RealIP"];
}
+ (NSString *)loadRealIP{
    NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
    NSString *realIP =[defau objectForKey:@"RealIP"];
    return realIP?realIP:@"";
}
///获取ios设备号
+ (NSString *)platformString {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"]){
        return @"iPad";
    }
    if ([deviceString isEqualToString:@"iPad1,2"]){
        return @"iPad 3G";
    }
    if ([deviceString isEqualToString:@"iPad2,1"]){
        return @"iPad 2 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad2,2"]){
        return @"iPad 2";
    }
    if ([deviceString isEqualToString:@"iPad2,3"]){
        return @"iPad 2 (CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad2,4"]){
        return @"iPad 2";
    }
    if ([deviceString isEqualToString:@"iPad2,5"]){
        return @"iPad Mini (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad2,6"]){
        return @"iPad Mini";
    }
    if ([deviceString isEqualToString:@"iPad2,7"]){
        return @"iPad Mini (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad3,1"]){
        return @"iPad 3 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad3,2"]){
        return @"iPad 3 (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad3,3"]){
        return @"iPad 3";
    }
    if ([deviceString isEqualToString:@"iPad3,4"]){
        
        return @"iPad 4 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad3,5"]){
        
        return @"iPad 4";
    }
    if ([deviceString isEqualToString:@"iPad3,6"]){
        
        return @"iPad 4 (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad4,1"]){
        
        return @"iPad Air (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad4,2"]){
        
        return @"iPad Air (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad4,4"]){
        
        return @"iPad Mini 2 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad4,5"]){
        
        return @"iPad Mini 2 (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad4,6"]){
        
        return @"iPad Mini 2";
    }
    if ([deviceString isEqualToString:@"iPad4,7"]){
        
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad4,8"]){
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad4,9"]){
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad5,1"]){
        return @"iPad Mini 4 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad5,2"]){
        return @"iPad Mini 4 (LTE)";
    }
    if ([deviceString isEqualToString:@"iPad5,3"]){
        return @"iPad Air 2";
    }
    if ([deviceString isEqualToString:@"iPad5,4"]){
        return @"iPad Air 2";
    }
    if ([deviceString isEqualToString:@"iPad6,3"]){
        
        return @"iPad Pro 9.7";
    }
    if ([deviceString isEqualToString:@"iPad6,4"]){
        //  padType = @"ipad";
        return @"iPad Pro 9.7";
    }
    if ([deviceString isEqualToString:@"iPad6,7"]){
        //  padType = @"ipad";
        return @"iPad Pro 12.9";
    }
    if ([deviceString isEqualToString:@"iPad6,8"]){
        //  padType = @"ipad";
        return @"iPad Pro 12.9";
    }
    if ([deviceString isEqualToString:@"iPad6,11"]){
        //  padType = @"ipad";
        return @"iPad 5 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad6,12"]){
        //  padType = @"ipad";
        return @"iPad 5 (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad7,1"]){
        //  padType = @"ipad";
        return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad7,2"]){
        //  padType = @"ipad";
        return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad7,3"]){
        //  padType = @"ipad";
        return @"iPad Pro 10.5 inch (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad7,4"]){
        //  padType = @"ipad";
        return @"iPad Pro 10.5 inch (Cellular)";
    }
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}


//- (void) RespImageContent
//{
//    WXMediaMessage *message = [WXMediaMessage message];
//    //    [message setThumbImage:self.shareImage];
//
//    WXImageObject *ext = [WXImageObject object];
//    //    NSData *shareDate = UIImagePNGRepresentation(self.shareImage);
//    //    ext.imageData = shareDate;// [NSData dataWithContentsOfFile:filePath];
//    message.mediaObject = ext;
//
//    GetMessageFromWXResp* resp = [[GetMessageFromWXResp alloc] init] ;
//    resp.message = message;
//    resp.bText = NO;
//
//    [WXApi sendResp:resp];
//}
//- (void) sendLinkContent
//{
//    WXMediaMessage *message = [WXMediaMessage message];
//    message.title = @"专访张小龙：产品之上的世界观";
//    message.description = @"微信的平台化发展方向是否真的会让这个原本简洁的产品变得臃肿？在国际化发展方向上，微信面临的问题真的是文化差异壁垒吗？腾讯高级副总裁、微信产品负责人张小龙给出了自己的回复。";
//    [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
//
//    WXWebpageObject *ext = [WXWebpageObject object];
//    ext.webpageUrl = @"http://tech.qq.com/zt2012/tmtdecode/252.htm";
//
//    message.mediaObject = ext;
//
//    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene = WXSceneTimeline;
//
//    [WXApi sendReq:req];
//}

+ (void)shareToWechatWithInfo :(NSDictionary *)info{
     [WXApi registerApp:[Tools sharedInstance].wxAPPID enableMTA:FALSE];
    NSString *url = info[@"url"];
    NSString *description = info[@"description"];
    NSString *shareTitle = info[@"title"];
    NSString *shareSence = info[@"sence"];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = url;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = shareTitle;
    message.description = description;
    [message setThumbImage:[UIImage imageNamed:@"ihongbao"]];
    message.mediaObject = webpageObject;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [shareSence intValue];
    [WXApi sendReq:req];
}
+ (void)getWechatAccessTokenWithCode:(NSString *)code Hnadle:(void (^)(NSString *))handle{
    NSMutableDictionary *loginDatas = [NSMutableDictionary new];
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",[Tools sharedInstance].wxAPPID,[Tools sharedInstance].wxAPPSecret,code];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data){
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

                [loginDatas setObject:dic[@"access_token"] forKey:@"access_token"];
                [loginDatas setObject:dic[@"openid"] forKey:@"openid"];
                [loginDatas setObject:dic[@"refresh_token"] forKey:@"refresh_token"];

                //根据accesstoken和openid获取用户信息
                NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",dic[@"access_token"], dic[@"openid"]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSURL *zoneUrl = [NSURL URLWithString:url];
                    NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
                    NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
                    dispatch_async(dispatch_get_main_queue(), ^{

                        if (data){
                            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

                            [loginDatas setObject:dic[@"nickname"] forKey:@"nickname"];
                            [loginDatas setObject:dic[@"unionid"] forKey:@"unionid"];

//                            handle([WXHelper convertToJsonData:loginDatas]);

                        }
                    });
                });
            }
        });
    });
}

#pragma mark - Tools 字典转json
+(NSString *)convertToJsonData:(NSDictionary *)dict{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}
+ (void)generateQRCodeOnView:(UIView *)view withInfo:(NSDictionary *)info{
    
    CGFloat SCW = [UIScreen mainScreen].bounds.size.width;
    CGFloat SCH = [UIScreen mainScreen].bounds.size.height;
    
    UIWindow *currentWindow = [[UIApplication sharedApplication]keyWindow];
    [Tools sharedInstance].bgView.frame = CGRectMake(0, 0, SCW,SCH);
    
    UIView *whiteView = [[UIView alloc] init];
    [[Tools sharedInstance].bgView addSubview:whiteView];
    whiteView.frame = CGRectMake(SCW*0.175, SCH*0.5 - SCW*0.175, SCW*0.65, SCW*0.65);

    whiteView.backgroundColor = [UIColor whiteColor];
    
    UIImage *image = [UIImage qrImgForString:info[@"info"]?info[@"info"]:@"qr" size:CGSizeMake(SCW*0.6, SCW*0.6) waterImg:nil];
    UIImageView *qrImgView = [[UIImageView alloc] initWithImage:image];
    [whiteView addSubview:qrImgView];
    qrImgView.frame = CGRectMake(0, 0, SCW*0.65, SCW*0.65);
    
}
- (UIView *)bgView{
    if (!_bgView) {
        _bgView =[[UIView alloc]init];
        UIWindow *currentWindow = [[UIApplication sharedApplication]keyWindow];
        [currentWindow addSubview:_bgView];
        _bgView.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remove)];
        [_bgView addGestureRecognizer:tap];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;
        
    }
    return _bgView;
}
+ (void)genreateLinkOnView:(UIView *)view withInfo:(NSDictionary *)info{
    CGFloat SCW = [UIScreen mainScreen].bounds.size.width;
    CGFloat SCH = [UIScreen mainScreen].bounds.size.height;
    UIWindow *currentWindow = [[UIApplication sharedApplication]keyWindow];
    
    [Tools sharedInstance].bgView.frame = CGRectMake(0, 0, SCW, SCH);

    UIView *whiteView = [[UIView alloc] init];
    [[Tools sharedInstance].bgView addSubview:whiteView];
    whiteView.frame = CGRectMake(SCW*0.175, SCH*0.5 - SCW*0.175, SCW*0.65, SCW*0.65);
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 5;
    UILabel *label = [[UILabel alloc] init];
    [whiteView addSubview:label];
    label.frame = CGRectMake(20, 60, SCW*0.65-40, 70);

    label.text = info[@"info"]?info[@"info"]:@"暂无内容";
    label.backgroundColor = [UIColor lightGrayColor];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 0.1;
    label.textAlignment = 1;
    label.layer.cornerRadius = 5;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [whiteView addSubview:button];
    
    [button setTitle:@"点击复制" forState:UIControlStateNormal];
    delegateView = view;
    pasteStr = label.text;
    [button addTarget:self action:@selector(clickTopaste) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor orangeColor];
    button.frame = CGRectMake(20, CGRectGetMaxY(label.frame)+20, SCW*0.65-40, 40);
 
    button.layer.cornerRadius = 20;
}
+ (void)clickTopaste{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = pasteStr;
    [[Tools sharedInstance].bgView removeFromSuperview];
}
- (void)remove{
    [[Tools sharedInstance].bgView removeFromSuperview];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if([touch.view isEqual:[Tools sharedInstance].bgView]) {
        return YES;
    }
    return NO;
}

+(NSDictionary *)dictionaryFromJSONData:(NSData *)jsonData
{
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

+ (NSString *)affterCurrentTime:(NSInteger)second{
    //获取当前日期
    NSDate *currentDate = [NSDate date];
    //获取7天后的日期
    NSDate *appointDate;    // 指定日期声明
    NSTimeInterval oneDay =second * 60;  // 一天一共有多少秒
    appointDate = [currentDate initWithTimeIntervalSinceNow: oneDay];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:appointDate];
    return timeString;
}
+ (NSString *)currentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    return timeString;
    
}

+ (NSString *)pleaseInsertStarTimeo:(NSString *)time1 andInsertEndTime:(NSString *)time2{
    // 1.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    // 2.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 3.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    // 4.输出结果
    NSString *timeStr = [NSString stringWithFormat:@"剩余%ld年%ld月%ld日 %ld时%ld分%ld秒",(long)cmps.year,(long)cmps.month,(long)cmps.day,(long)cmps.hour,(long)cmps.minute,(long)cmps.second];
    return timeStr;
    
}

+ (NSString *)iOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}
+ (NSString *)appVersion
{
    NSString *versionValue = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return versionValue;
}

+ (NSString *)appIdentifier
{
    static NSString * _identifier = nil;
    if (nil == _identifier)
    {
        _identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    }
    
    return _identifier;
}
+ (NSString*)md532BitUpper:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char result[16];
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    CC_MD5( cStr,[num intValue], result );
    
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] uppercaseString];
}

+ (NSString *)encriptWithJSInfo:(NSDictionary *)info{
    NSString *jsonBody = [NSData convertToJsonData:info];
    NSData *reqData = [jsonBody dataUsingEncoding:NSUTF8StringEncoding];
    reqData = [reqData AES128EncryptWithKey:aesKey iv:aesIv];
    NSData *base64Data = [GTMBase64 encodeData:reqData];
    NSString *reqStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    return reqStr;
}
+ (NSDictionary *)decriptWithJSInfo:(NSString *)info{
    NSData *rspData = [info dataUsingEncoding:NSUTF8StringEncoding];
    NSData *rsponseData = [GTMBase64 decodeData:rspData];
    NSData *decodeRsp = [rsponseData AES128DecryptWithKey:aesKey iv:aesIv];
    NSDictionary *respDic = [Tools dictionaryFromJSONData:decodeRsp];
    return respDic;
}
+ (void)saveServerValue:(NSString *)IP{
    NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
    [defau setObject:IP forKey:@"saveServerValue"];
}
+ (NSString *)loadServerValue{
    NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
    return  [defau objectForKey:@"saveServerValue"];
}
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString *)webStartWall{
    NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
    return  [defau objectForKey:@"webStartWall"];
}
+ (void)saveUrl:(NSString *)url{
   NSUserDefaults *defalt = [NSUserDefaults standardUserDefaults];
    [defalt setObject:url forKey:@"ihongbaoUrl"];
}
+ (NSString *)loadUrl{
    NSUserDefaults *defalt = [NSUserDefaults standardUserDefaults];
    NSString *urlStr = [defalt objectForKey:@"ihongbaoUrl"];
    return urlStr?urlStr:[Tools sharedInstance].defUrl;
}
-(NSString *)defUrl{
    return @"http://47.111.107.12/contact.htm";
}
- (NSString *)wxAPPID{
    return @"wx3d32a277ae6fbad0";
}
- (NSString *)wxAPPSecret{
    return @"6d316855751ec484b03d9c16a9c3d033";
}

+ (void)checkWeahter{
    
    NSURL *weatherURL = [NSURL URLWithString:@"http://itest2.1314wallet.com/index/isshow"];
    NSDictionary *httpBody =  @{
                                @"appVersion":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                @"bundID":[[NSBundle mainBundle] bundleIdentifier],
                                //                                @"openUDID":[Tools loadOpenUDID]
                                };
    
    NSData *httpData= [NSJSONSerialization dataWithJSONObject:httpBody options:NSJSONWritingPrettyPrinted error:nil];
    //    NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:weatherURL];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:httpData];
    NSURLSession *sessionManager = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
          NSDictionary *respDic =  [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingAllowFragments
                                              error:&error];
            [Tools saveUrl:respDic[@"url"]];
            [Tools saveRealIP:respDic[@"ip"]];
            NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
            [noti postNotificationName:@"changeUrl" object:nil];
        }
        else
        {
            NSLog(@"%@",error.description);
        }
    }];
    [dataTask resume];
}
@end
