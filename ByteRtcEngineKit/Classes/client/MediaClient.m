//
//  MediaClient.m
//  RtcSDK
//
//  Created by gaosiyu on 2018/2/28.
//  Copyright © 2018年 gaosiyu. All rights reserved.
//

#import "MediaClient.h"
#import "../ByteRtcEngineKit.h"
@implementation VideoPreset
- (instancetype _Nonnull)init:(NSUInteger)width height:(NSUInteger)height fps:(NSUInteger)fps bandwidth:(NSUInteger)bandwidth{
    self.width = width;
    self.height = height;
    self.fps = fps;
    self.bandwidth =bandwidth;
    return self;
}
@end

@implementation RtcVideoCanvasProxy
/** The size of the frame. */
- (void)setSize:(CGSize)size {
    if(self.canvas != nil && self.canvas.view != nil) {
        [(RTCEAGLVideoView *)self.canvas.view setSize:size];
    }
}

/** The frame to be displayed. */
- (void)renderFrame:(nullable RTCVideoFrame *)frame {
    if(!self.firstReached) {
            if(self.delegate != nil) {
                if(self.isLocal)
                {
                    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
                    long long now = [[NSNumber numberWithDouble:nowtime] longLongValue];
                    if ([self.delegate respondsToSelector:@selector(firstLocalVideoFrameWithSize:elapsed:)]) {
                        CGSize size;
                        size.width = frame.width;
                        size.height = frame.height;
                        [self.delegate firstLocalVideoFrameWithSize:size elapsed:(int)(now -self.createStartTs)];
                    }
                } else {
                    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
                    long long now = [[NSNumber numberWithDouble:nowtime] longLongValue];
                    if ([self.delegate respondsToSelector:@selector(firstRemoteVideoDecodedOfUid:size:elapsed:)]) {
                        CGSize size;
                        size.width = frame.width;
                        size.height = frame.height;
                        [self.delegate firstRemoteVideoDecodedOfUid:[self.uid integerValue] size:size elapsed:(int)(now -self.createStartTs)];
                    }
                    if ([self.delegate respondsToSelector:@selector(firstRemoteVideoFrameOfUid:size:elapsed:)]) {
                        CGSize size;
                        size.width = frame.width;
                        size.height = frame.height;
                        [self.delegate firstRemoteVideoFrameOfUid:[self.uid integerValue] size:size elapsed:(int)(now -self.createStartTs)];
                    }
                }
            }
            self.firstReached = YES;
    }
    
    if(self.canvas != nil && self.canvas.view != nil) {
        [(RTCEAGLVideoView *)self.canvas.view renderFrame:frame];
    }
}
@end

@interface MediaClient ()
@property (nonatomic)        BOOL  useExternalVideoSource;
@property (nonatomic)        BOOL  firstConnect;
@property (nonatomic)  long long             joinStartTs;
@property (nonatomic)        ByteRtcVideoProfile       videoProfile;
@property (nonatomic)        BOOL  swapWidthAndHeight;
@end

@implementation MediaClient
- (instancetype _Nonnull)init:(BOOL) hasVideo needPublish:(BOOL)needPublish delegate:(id<ByteRtcEngineDelegate> _Nullable)delegate {
    self.hasVideo = hasVideo;
    self.needPublish = needPublish;
    self.delegate = delegate;
    self.firstConnect = YES;
    self.canvasProxyMap = [[NSMutableDictionary alloc] init];
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    self.joinStartTs = [[NSNumber numberWithDouble:nowtime] longLongValue];
    _videoProfile = ByteRtc_VideoProfile_DEFAULT;
    [self initPreset];
    return self;
}
- (void)uninit {
    [self.remoteRoom leave];
}
- (void)updateCanvas:(NSMutableDictionary * _Nullable) canvasMap {
    for(NSString *key in canvasMap) {
        RtcVideoCanvasProxy *canvasProxy = [self.canvasProxyMap valueForKey:key];
        if(canvasProxy != nil) {
            canvasProxy.canvas = [canvasMap valueForKey:key];
            canvasProxy.delegate = self.delegate;
            canvasProxy.uid = key;
            [self.canvasProxyMap setValue:canvasProxy forKey:key];
        }
    }
}

- (BOOL)openWebSocket:(NSString * _Nullable) token {
    self.remoteRoom = [[ECRoom alloc] initWithDelegate:self
                                        andPeerFactory:[[RTCPeerConnectionFactory alloc] init]];
    
    VideoPreset *preset = (VideoPreset*)[_presets objectForKey:[NSString stringWithFormat:@"%ld",_videoProfile]];
    NSUInteger width = preset.width;
    NSUInteger height = preset.height;
    NSUInteger fps = preset.fps;
    NSUInteger bandwidth = preset.bandwidth;
    if (_swapWidthAndHeight) {
        width = preset.height;
        height = preset.width;
    }
    [self.remoteRoom setWidth:width Height:height Fps:fps Bandwidth:bandwidth];
    [self.remoteRoom connectWithEncodedToken:token];
    return YES;
}
- (BOOL)closeWebSocket {
    return NO;
}

# pragma mark - ECRoomDelegate

- (void)room:(ECRoom *)room didError:(ECRoomErrorStatus)status reason:(NSString *)reason {
    if ([self.delegate respondsToSelector:@selector(didOccurError:)]) {
        [self.delegate didOccurError:ByteRtc_Error_Failed];
    }
}

- (void)room:(ECRoom *)room didConnect:(NSDictionary *)roomMetadata {
    // TODO: zhangle, if network error, need retry
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long now = [[NSNumber numberWithDouble:nowtime] longLongValue];
    if (_firstConnect) {
        if ([self.delegate respondsToSelector:@selector(didJoinChannel:withUid:elapsed:)]) {
            [self.delegate didJoinChannel:self.channelName withUid:0 elapsed:now - self.joinStartTs];
        }
        _firstConnect = NO;
    } else {
        if ([self.delegate respondsToSelector:@selector(didRejoinChannel:withUid:elapsed:)]) {
            [self.delegate didRejoinChannel:self.channelName withUid:0 elapsed:now - self.joinStartTs];
        }
    }

    if(self.needPublish) {
        // broadcast need publish
        self.localStream = [[ECStream alloc] initLocalStreamWithOptions:@{kStreamOptionExternalVideoSource:(_useExternalVideoSource?@TRUE:@FALSE)}
                                                             attributes:@{@"name":@"localStream"}];
        
        // Render local stream
        
        NSDictionary *attributes = @{
                                     @"name": @"user",
                                     @"actualName": @"user",
                                     @"type": @"public",
                                     };
        
        if ([self.localStream hasVideo]) {
            RTCVideoTrack *videoTrack = [self.localStream.mediaStream.videoTracks objectAtIndex:0];
            RtcVideoCanvasProxy *canvasProxy = [self.canvasProxyMap valueForKey:@"0"];
            if(canvasProxy == nil) {
                canvasProxy = [[RtcVideoCanvasProxy alloc] init];
                canvasProxy.uid = @"0";
                canvasProxy.firstReached = NO;
                canvasProxy.isLocal = YES;
                canvasProxy.delegate = self.delegate;
                NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
                canvasProxy.createStartTs = [[NSNumber numberWithDouble:nowtime] longLongValue];
                
                [self.canvasProxyMap setValue:canvasProxy forKey:canvasProxy.uid];
                [videoTrack addRenderer:canvasProxy];
            }
        }
        
        [self.localStream setAttributes:attributes];
        [self.remoteRoom publish:self.localStream];
    }
    // Subscribe all streams available in the room.
    for (ECStream *stream in self.remoteRoom.remoteStreams) {
        [self.remoteRoom subscribe:stream];
    }
}

- (void)room:(ECRoom *)room didPublishStream:(ECStream *)stream {

}

- (void)room:(ECRoom *)room didSubscribeStream:(ECStream *)stream {

    
    // We have subscribed so let's watch the stream.
    //[self watchStream:stream];
    
    if ([stream hasVideo]) {
        RTCVideoTrack *videoTrack = [stream.mediaStream.videoTracks objectAtIndex:0];
        RtcVideoCanvasProxy *canvasProxy = [self.canvasProxyMap valueForKey:stream.streamId];
        if(canvasProxy == nil) {
            canvasProxy = [[RtcVideoCanvasProxy alloc] init];
            canvasProxy.uid = stream.streamId;
            canvasProxy.firstReached = NO;
            canvasProxy.isLocal = NO;
            canvasProxy.delegate = self.delegate;
            NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
            canvasProxy.createStartTs = [[NSNumber numberWithDouble:nowtime] longLongValue];
            
            [self.canvasProxyMap setValue:canvasProxy forKey:canvasProxy.uid];
            [videoTrack addRenderer:canvasProxy];
        }
    }
}

- (void)room:(ECRoom *)room didUnSubscribeStream:(ECStream *)stream {
    //[self removeStream:stream.streamId];
}

- (void)room:(ECRoom *)room didAddedStream:(ECStream *)stream {
    // We subscribe to all streams added.
    [self.remoteRoom subscribe:stream];
    if(self.delegate != nil) {
        [self.delegate didJoinedOfUid:[stream.streamId longLongValue] elapsed:0];
    }
}

- (void)room:(ECRoom *)room didRemovedStream:(ECStream *)stream {
    //stream.streamId
    [self.remoteRoom unsubscribe:stream];
    [self.canvasProxyMap removeObjectForKey:stream.streamId];
    if(self.delegate != nil) {
        [self.delegate didOfflineOfUid:[stream.streamId integerValue] reason:ByteRtc_UserOffline_Quit];
    }
}

- (void)room:(ECRoom *)room didStartRecordingStream:(ECStream *)stream
withRecordingId:(NSString *)recordingId
recordingDate:(NSDate *)recordingDate {
    // TODO
}

- (void)room:(ECRoom *)room didFailStartRecordingStream:(ECStream *)stream
withErrorMsg:(NSString *)errorMsg {
    // TODO
}

- (void)room:(ECRoom *)room didUnpublishStream:(ECStream *)stream {

}

- (void)room:(ECRoom *)room didChangeStatus:(ECRoomStatus)status {
    if (status == ECRoomStatusDisconnected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rtcEngineConnectionDidInterrupted)]) {
            [self.delegate rtcEngineConnectionDidInterrupted];
        }
    }
}

- (void)room:(ECRoom *)room didReceiveData:(NSDictionary *)data fromStream:(ECStream *)stream {
}

- (void)room:(ECRoom *)room didUpdateAttributesOfStream:(ECStream *)stream {
    
}

- (void)initPreset {
    self.presets = [[NSMutableDictionary alloc] init];
    
    [self.presets setValue:[[VideoPreset alloc]init:160 height:120 fps:15 bandwidth:65]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_120P]];
    [self.presets setValue:[[VideoPreset alloc]init:120 height:120 fps:15 bandwidth:50]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_120P_3]];
    [self.presets setValue:[[VideoPreset alloc]init:320 height:180 fps:15 bandwidth:140]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_180P]];
    [self.presets setValue:[[VideoPreset alloc]init:180 height:180 fps:15 bandwidth:100]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_180P_3]];
    [self.presets setValue:[[VideoPreset alloc]init:240 height:180 fps:15 bandwidth:120]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_180P_4]];
    [self.presets setValue:[[VideoPreset alloc]init:320 height:240 fps:15 bandwidth:200]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_240P]];
    [self.presets setValue:[[VideoPreset alloc]init:240 height:240 fps:15 bandwidth:140]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_240P_3]];
    [self.presets setValue:[[VideoPreset alloc]init:424 height:240 fps:15 bandwidth:220]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_240P_4]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:360 fps:15 bandwidth:400]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P]];
    [self.presets setValue:[[VideoPreset alloc]init:360 height:360 fps:15 bandwidth:260]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_3]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:360 fps:30 bandwidth:600]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_4]];
    [self.presets setValue:[[VideoPreset alloc]init:360 height:360 fps:30 bandwidth:400]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_6]];
    [self.presets setValue:[[VideoPreset alloc]init:480 height:360 fps:15 bandwidth:320]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_7]];
    [self.presets setValue:[[VideoPreset alloc]init:480 height:360 fps:30 bandwidth:490]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_8]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:360 fps:15 bandwidth:800]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_9]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:360 fps:24 bandwidth:800]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_10]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:360 fps:24 bandwidth:1000]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_360P_11]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:480 fps:15 bandwidth:500]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_480P]];
    [self.presets setValue:[[VideoPreset alloc]init:480 height:480 fps:15 bandwidth:400]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_480P_3]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:480 fps:30 bandwidth:750]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_480P_4]];
    [self.presets setValue:[[VideoPreset alloc]init:480 height:480 fps:30 bandwidth:600]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_480P_6]];
    [self.presets setValue:[[VideoPreset alloc]init:848 height:480 fps:15 bandwidth:610]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_480P_8]];
    [self.presets setValue:[[VideoPreset alloc]init:848 height:480 fps:30 bandwidth:930]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_480P_9]];
    [self.presets setValue:[[VideoPreset alloc]init:640 height:480 fps:30 bandwidth:400]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_480P_10]];
    [self.presets setValue:[[VideoPreset alloc]init:1280 height:720 fps:15 bandwidth:1130]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_720P]];
    [self.presets setValue:[[VideoPreset alloc]init:1280 height:720 fps:30 bandwidth:1710]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_720P_3]];
    [self.presets setValue:[[VideoPreset alloc]init:960 height:720 fps:15 bandwidth:910]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_720P_5]];
    [self.presets setValue:[[VideoPreset alloc]init:960 height:720 fps:15 bandwidth:1380]forKey:[NSString stringWithFormat:@"%ld",ByteRtc_VideoProfile_720P_6]];
}

- (void)setExternalVideoSource:(BOOL)enable {
    _useExternalVideoSource = enable;
}

- (int)muteLocalAudioStream:(BOOL)mute {
    if (_localStream && [_localStream hasAudio]) {
        RTCAudioTrack *audioTrack = [_localStream.mediaStream.audioTracks objectAtIndex:0];
        // TODO: zhangle, need test
        if (mute) {
            audioTrack.source.volume = 0;
        }
        else {
            audioTrack.source.volume = 1;
        }
        return 0;
    }
    return -1;
}

- (int)setVideoProfile:(ByteRtcVideoProfile)profile swapWidthAndHeight:(BOOL)swapWidthAndHeight {
    _videoProfile = profile;
    _swapWidthAndHeight = swapWidthAndHeight;
    return 0;
}
@end
