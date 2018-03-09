//
//  APIClient.h
//  RtcSDK
//
//  Created by gaosiyu on 2018/2/28.
//  Copyright © 2018年 gaosiyu. All rights reserved.
//
#ifndef API_CLIENT_H
#define API_CLIENT_H
#import <Foundation/Foundation.h>
#include "../ByteRtcEngineKit.h"
@interface APIClient : NSObject

@property (nonatomic, weak)  id<ByteRtcEngineDelegate> _Nullable delegate;
@property (nonatomic, strong)  NSString * _Nullable nuveIP;
@property (nonatomic)        NSInteger            nuvePort;
@property (nonatomic)        BOOL      secure;
@property (nonatomic, strong)  NSString * _Nullable roomid;
@property (nonatomic, strong)  NSString * _Nullable roomName;
@property (nonatomic, strong)  NSString * _Nullable username;
@property (nonatomic, strong)  NSString * _Nullable role;
@property (nonatomic, strong)  NSString * _Nullable appid;
@property (nonatomic, strong)  NSString * _Nullable appkey;
@property (nonatomic, strong)  NSString * _Nullable wsHost;
@property (nonatomic, strong)  NSString * _Nullable token;

@property (nonatomic, weak)  id<ByteRtcEngineDelegate> _Nullable globalDelegate;
- (BOOL)in:(NSString * _Nullable)roomName;
- (instancetype _Nonnull)init:(NSString * _Nullable)nuveIP nuvePort:(NSInteger)nuvePort secure:(BOOL)secure roomName:(NSString * _Nullable)roomName userName:(NSString * _Nullable)userName role:(NSString * _Nullable) role appid:(NSString * _Nullable) appid appkey:(NSString * _Nullable) appkey delegate:(id<ByteRtcEngineDelegate> _Nullable)delegate;
- (BOOL)getRoom;
- (BOOL)createRoom;
- (BOOL)createToken;
- (NSString * _Nullable)getToken;
//- (BOOL)openWebSocket;
//- (BOOL)closeWebSocket;
- (NSString * _Nullable)generateAuthHeader;
- (NSString * _Nullable)hmacsha1:(NSString * _Nullable)text;
- (id _Nullable)parseResponse:(NSData *)data;
- (NSString * _Nullable)performRequest:(NSString * _Nullable)path
                     method:(NSString * _Nullable)method
                   postData:(NSDictionary * _Nullable)postData
                         authorization:(NSString * _Nullable)authorization;
@end
#endif
