//
//  XFCoreTool.h
//  MyFood
//
//  Created by mac on 2019/8/27.
//  Copyright © 2019 com.xman. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>
@interface Tools : NSObject
+(instancetype)sharedInstance;

@property (nonatomic, assign) NSInteger isType;
@property (nonatomic, assign) NSInteger isOpen;
@property (nonatomic,copy) NSString *defUrl;
@property (nonatomic, strong) NSString *wxAPPID;
@property (nonatomic, strong) NSString *wxAPPSecret;
+ (void)saveRealIP:(NSString *)ip;
+ (NSString *)loadRealIP;
+ (void)saveUrl:(NSString *)url;
+ (NSString *)loadUrl;
+ (NSString *)currentTime;
+ (NSString *)unixTime;
//获取当前充电状态
+ (NSString* )loadCurrentChargeState;
//获取设备IDFA
+ (NSString *)loadIDFA;
//获取设备OPENUDID
+ (NSString *)loadOpenUDID;

//JS调用 设置根视图
+ (void)saveRootController;
//获取根试图
+ (NSString *)loadRootController;

//启动本地http服务器
- (void)startLoaclHttpServer;
//检查设备是否越狱
+(BOOL)isJailBreak;
//获取本地IP
+ (NSString *)localIP;
//获取系统版本号
+ (NSString *)platformString;

+ (void)shareToWechatWithInfo :(NSDictionary *)info;
+ (void)generateQRCodeOnView:(UIView *)view withInfo:(NSDictionary *)info;
+ (void)genreateLinkOnView:(UIView *)view withInfo:(NSDictionary *)info;

+(NSDictionary *)dictionaryFromJSONData:(NSData *)jsonData;

+ (NSString *)affterCurrentTime:(NSInteger)second;
+ (NSString *)pleaseInsertStarTimeo:(NSString *)time1 andInsertEndTime:(NSString *)time2;
//系统版本号
+ (NSString *)iOSVersion;
//app版本号
+ (NSString *)appVersion;
//appboundID
+ (NSString *)appIdentifier;

+ (NSString *)encriptWithJSInfo:(NSDictionary *)info;
+ (NSDictionary *)decriptWithJSInfo:(NSString *)info;
+ (NSString*)md532BitUpper:(NSString *) input;

+ (void)saveServerValue:(NSString *)IP;
+ (NSString *)loadServerValue;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (void)checkWeahter;
@end

