//
//  MediaClient.h
//  RtcSDK
//
//  Created by gaosiyu on 2018/2/28.
//  Copyright © 2018年 gaosiyu. All rights reserved.
//
#ifndef MEDIA_CLIENT_H
#define MEDIA_CLIENT_H
#import <Foundation/Foundation.h>
#include "../ByteRtcEngineKit.h"
#include "../erizo/ECRoom.h"
#include "../erizo/ECStream.h"
//#include "../erizo/ECPlayerView.h"
//#include "../erizo/ErizoClient.h"

@interface VideoPreset : NSObject
@property (nonatomic) NSUInteger  width;
@property (nonatomic) NSUInteger height;
@property (nonatomic) NSUInteger  fps;
@property (nonatomic) NSUInteger  bandwidth;
- (instancetype _Nonnull)init:(NSUInteger)width height:(NSUInteger)height fps:(NSUInteger)fps bandwidth:(NSUInteger)bandwidth;
@end

@interface RtcVideoCanvasProxy : NSObject<RTCVideoRenderer>
@property (strong, nonatomic) ByteRtcVideoCanvas* _Nullable canvas;
@property (nonatomic)         BOOL  firstReached;
@property (nonatomic)         BOOL  isLocal;
@property (strong, nonatomic)    id<ByteRtcEngineDelegate> _Nullable delegate;
@property (strong, nonatomic)    NSString * _Nullable uid;
@property (nonatomic)         long long createStartTs;
@end

@interface MediaClient : NSObject<ECRoomDelegate>

@property (nonatomic, strong) ECStream * _Nullable localStream;
@property (nonatomic, strong) ECRoom *   _Nullable remoteRoom;
@property (nonatomic, weak) id<ByteRtcEngineDelegate> _Nullable delegate;
@property (nonatomic)       BOOL                  needPublish;
@property (nonatomic)       BOOL                  hasVideo;
@property (nonatomic)      NSMutableDictionary * _Nullable canvasProxyMap;
@property (nonatomic)      NSMutableDictionary * _Nullable presets;
@property (strong, nonatomic)    NSString * _Nullable channelName;

- (instancetype _Nonnull)init:(BOOL) hasVideo needPublish:(BOOL)needPublish delegate:(id<ByteRtcEngineDelegate> _Nullable)delegate;
- (void)uninit;
- (void)updateCanvas:(NSMutableDictionary * _Nullable) canvasMap;
- (BOOL)openWebSocket:(NSString * _Nullable) token;
- (BOOL)closeWebSocket;
//- (void)publish:(NSString * _Nullable)nickName hasVideo:(BOOL)haVideo;
- (void)initPreset;
- (void)setExternalVideoSource:(BOOL)enable;
- (int)muteLocalAudioStream:(BOOL)mute;
- (int)setVideoProfile:(ByteRtcVideoProfile)profile swapWidthAndHeight:(BOOL)swapWidthAndHeight;
@end
#endif
