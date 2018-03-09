//
//  RtcEngineKit.m
//  RtcEngineKit
//
//  Created by gaosiyu on 2018/2/28.
//  Copyright © 2018年 gaosiyu. All rights reserved.
//

#import "ByteRtcEngineKit.h"
#import "APIClient.h"
#import "MediaClient.h"

static NSString * appHost;

@interface ByteRtcEngineKit ()
@property (nonatomic, strong)  NSString *  _Nullable appId;
@property (nonatomic, strong)  NSString *  _Nullable appKey;
@property (nonatomic, strong)  NSString *  _Nullable appHost;
@property (nonatomic)        ByteRtcVideoProfile       videoProfile;
@property (nonatomic)        ByteRtcClientRole         clientRole;
@property (nonatomic)        BOOL                  hasVideo;
@property (nonatomic, strong)  NSString *  _Nullable nickName;
@property (nonatomic      )  long long             joinStartTs;
@property (nonatomic, strong)  id<ByteRtcEngineDelegate> _Nullable delegate;
@property (nonatomic, strong)  APIClient * _Nullable apiClient;
@property (nonatomic, strong)  MediaClient * _Nullable mediaClient;
@property (nonatomic, strong)  NSMutableDictionary    *canvasMap;
@property (nonatomic)        BOOL  useExternalVideoSource;
@property (nonatomic)        BOOL  swapWidthAndHeight;
@end


@implementation ByteRtcVideoCanvas
@end

@implementation ByteVideoFrame
@end

CVPixelBufferRef copyDataFromBuffer(const unsigned char*buffer, size_t w, size_t h) {
    NSDictionary *pixelBufferAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    
    CVPixelBufferRef pixelBuffer;
    CVPixelBufferCreate(NULL, w, h, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, (__bridge CFDictionaryRef)(pixelBufferAttributes), &pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    size_t d = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    const unsigned char* src = buffer;
    unsigned char* dst = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    for (unsigned int rIdx = 0; rIdx < h; ++rIdx, dst += d, src += w) {
        memcpy(dst, src, w);
    }
    
    d = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    dst = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    h = h >> 1;
    for (unsigned int rIdx = 0; rIdx < h; ++rIdx, dst += d, src += w) {
        memcpy(dst, src, w);
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}

@implementation ByteRtcEngineKit

+ (instancetype _Nonnull)sharedEngineWithAppId:(NSString * _Nonnull)appId
appKey:(NSString * _Nonnull)appKey delegate:(id<ByteRtcEngineDelegate> _Nullable)delegate {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        ByteRtcEngineKit *temp = [[self alloc] init];
        temp.appId = appId;
        temp.appKey = appKey;
        temp.appHost = @"47.89.243.189";
        temp.nickName = @"user";
        temp.joinStartTs = 0;
        temp.delegate = delegate;
        temp.hasVideo = YES;
        temp.videoProfile = ByteRtc_VideoProfile_DEFAULT;
        temp.canvasMap = [[NSMutableDictionary alloc] init];
        sharedInstance = temp;
    });
    return sharedInstance;
}

+ (void)setApiHost:(NSString * ) host {
    appHost = host;
}

- (int)setupLocalVideo:(ByteRtcVideoCanvas * _Nullable)local {
    local.uid = 0;
    [self.canvasMap setValue:local forKey:[NSString stringWithFormat: @"%ld", local.uid]];
    [self.mediaClient updateCanvas:self.canvasMap];
    return 0;
}

- (int)setupRemoteVideo:(ByteRtcVideoCanvas * _Nonnull)remote {
    [self.canvasMap setValue:remote forKey:[NSString stringWithFormat: @"%ld", remote.uid]];
    [self.mediaClient updateCanvas:self.canvasMap];
    return 0;
}

- (int)joinChannelByKey:(NSString * _Nullable)channelKey
channelName:(NSString * _Nonnull)channelName
info:(NSString * _Nullable)info
uid:(NSUInteger)uid {
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    self.joinStartTs = [[NSNumber numberWithDouble:nowtime] longLongValue];
    if(self.mediaClient != nil) {
        [self.mediaClient uninit];
    }
    self.mediaClient = [[MediaClient alloc] init: self.hasVideo needPublish:self.clientRole == ByteRtc_ClientRole_Broadcaster delegate:self.delegate];
    _mediaClient.channelName = channelName;
    [_mediaClient setVideoProfile:_videoProfile swapWidthAndHeight:_swapWidthAndHeight];
    [_mediaClient setExternalVideoSource:_useExternalVideoSource];

//    APIClient *oldClient = nil;
//    if(self.apiClient != nil) {
//        oldClient = self.apiClient;
//    }

    self.apiClient = [[APIClient alloc] init:self.appHost nuvePort:3000 secure:NO roomName:channelName userName:self.nickName role:@"presenter" appid:self.appId appkey:self.appKey delegate:self.delegate];
    do {
        if(![self.apiClient getRoom]) {
            if(![self.apiClient createRoom]) {
                break;
            }
        }
        if(![self.apiClient createToken]) {
            break;
        }
        if([self.mediaClient openWebSocket:[self.apiClient getToken]]) {
            break;
        }

//        if(self.delegate != nil) {
//            NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
//            long long now = [[NSNumber numberWithDouble:nowtime] longLongValue];
//            if(oldClient != nil && [oldClient in:channelName]) {
//                if ([self.delegate respondsToSelector:@selector(didRejoinChannel:withUid:elapsed:)]) {
//                    [self.delegate didRejoinChannel:channelName withUid:0 elapsed:now - self.joinStartTs];
//                }
//            } else {
//                if ([self.delegate respondsToSelector:@selector(didJoinChannel:withUid:elapsed:)]) {
//                    [self.delegate didJoinChannel:channelName withUid:0 elapsed:now - self.joinStartTs];
//                }
//            }
//        }
    } while (false);
    return 0;
}

- (int)setVideoProfile:(ByteRtcVideoProfile)profile swapWidthAndHeight:(BOOL)swapWidthAndHeight {
    self.videoProfile = profile;
    _swapWidthAndHeight = swapWidthAndHeight;
    return 0;
}

- (int)setClientRole:(ByteRtcClientRole)role withKey:(NSString * _Nullable)permissionKey {
    self.clientRole = role;
    return 0;
}

- (int)leaveChannel {
    if(self.mediaClient != nil) {
      [self.mediaClient uninit];
      self.mediaClient = nil;
    }
    if(self.apiClient != nil) {
        self.apiClient = nil;
    }
    return 0;
}

- (int)enableVideo {
    self.hasVideo = YES;
    return 0;
}

- (int)disableVideo {
    self.hasVideo = NO;
    return 0;
}
- (UIView * _Nullable)createRenderView:(CGRect) frame {
    return [[RTCEAGLVideoView alloc] initWithFrame:frame];
}

- (void)setExternalVideoSource:(BOOL)enable useTexture:(BOOL)useTexture pushMode:(BOOL)pushMode {
    _useExternalVideoSource = enable;
    if (_mediaClient) {
        [_mediaClient setExternalVideoSource:enable];
    }
    assert(!useTexture);
    assert(pushMode);
}

- (BOOL)pushExternalVideoFrame:(ByteVideoFrame * _Nonnull)frame {
    assert(frame.format == 8 || frame.format == 12 || "only support NV12 and 'ios texture'");
    int width = frame.strideInPixels;
    int height = frame.height;
    int cropLeft = frame.cropLeft;
    if (cropLeft < 0) {
        cropLeft = 0;
    }
    int cropRight = frame.cropRight;
    if (cropRight < 0) {
        cropRight = 0;
    }
    int cropTop = frame.cropTop;
    if (cropTop < 0) {
        cropTop = 0;
    }
    int cropBottom = frame.cropBottom;
    if (cropBottom < 0) {
        cropBottom = 0;
    }
    int crop_w = width - cropRight - cropLeft;
    int crop_h = height - cropBottom - cropTop;
    if (crop_w <= 0) {
        crop_w = 1;
    }
    if (crop_h <= 0) {
        crop_h = 1;
    }
    
    CVPixelBufferRef cvBuffer = nil;
    if (frame.format == 8) {
        unsigned char* buffer = (unsigned char*) frame.dataBuf.bytes;
        cvBuffer = copyDataFromBuffer(buffer, width, height);
    }
    else if (frame.format == 12) {
        cvBuffer = frame.textureBuf;
    }

    if (cvBuffer) {
        RTCCVPixelBuffer *rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:cvBuffer
                                                                            adaptedWidth:width
                                                                           adaptedHeight:height
                                                                               cropWidth:crop_w
                                                                              cropHeight:crop_h
                                                                                   cropX:cropLeft
                                                                                   cropY:cropTop];
        RTCVideoFrame * rtcFrame = [[RTCVideoFrame alloc]
                                    initWithBuffer:rtcPixelBuffer rotation:RTCVideoRotation_0
                                    timeStampNs:frame.time.value * 1000000000 / frame.time.timescale];
        
        [_mediaClient.localStream pushExternalVideoFrame:rtcFrame];
        
        if (frame.format == 8) {
            CVPixelBufferRelease(cvBuffer);
        }
        
        return YES;
    }
    
    return NO;
}

- (int)setEnableSpeakerphone:(BOOL)enableSpeaker {
    // TODO: zhangle
    return 0;
}

- (int)muteLocalAudioStream:(BOOL)mute {
    if (_mediaClient) {
        return [_mediaClient muteLocalAudioStream:mute];
    }
    return -1;
}

- (int)setLogFile:(NSString*_Nullable)filePath {
    return 0;
}

@end
