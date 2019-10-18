//
//  NSData+AES.h
//  iOS_AES
//
//  Created by FM-13 on 16/6/8.
//  Copyright © 2016年 cong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)


//加密 
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;


//解密
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

//
//NSString *key = @"8D4F16E8F94796FC";
//NSString *iv = @"0102030405060708";
//
//
//NSString *str1 = @"you are not that into me";
//NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
////加密
//data1 = [data1 AES128EncryptWithKey:key iv:iv];
////解密
//NSData *data2 = [data1 AES128DecryptWithKey:key iv:iv];
//NSString *str2 = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
//NSLog(@"str2:%@", str2);
//
//
//
////server处理
////server 会对AES加密后的data1 进行base64加密，然后将str提供给前端处理
//NSData *data3 = [GTMBase64 encodeData:data1];
//NSString *str3 = [[NSString alloc] initWithData:data3 encoding:NSUTF8StringEncoding];
//NSLog(@"str3:%@", str3);
//
////前端处理
//NSData *data4 = [str3 dataUsingEncoding:NSUTF8StringEncoding];
//data4 = [GTMBase64 decodeData:data4];
//NSData *data5 = [data4 AES128DecryptWithKey:key iv:iv];
//NSString *str4 = [[NSString alloc] initWithData:data5 encoding:NSUTF8StringEncoding];
//NSLog(@"str4:%@", str4);
+(NSString *)convertToJsonData:(NSDictionary *)dict;
+(NSDictionary *)dictionaryFromJSONData:(NSData *)jsonData;
@end
