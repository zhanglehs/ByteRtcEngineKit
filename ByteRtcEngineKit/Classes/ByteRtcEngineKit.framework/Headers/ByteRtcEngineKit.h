//
//  RtcEngineKit.h
//  RtcEngineKit
//
//  Created by gaosiyu on 2018/2/28.
//  Copyright © 2018年 gaosiyu. All rights reserved.
//
#import <CoreMedia/CMTime.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ByteRtcRenderMode) {
    ByteRtc_Render_Hidden = 1,
    ByteRtc_Render_Fit = 2,
    ByteRtc_Render_Adaptive = 3,
};
typedef NS_ENUM(NSUInteger, ByteRtcUserOfflineReason) {
    ByteRtc_UserOffline_Quit = 0,
    ByteRtc_UserOffline_Dropped = 1,
    ByteRtc_UserOffline_BecomeAudience = 2,
};

typedef NS_ENUM(NSInteger, ByteRtcClientRole) {
    ByteRtc_ClientRole_Broadcaster = 1,
    ByteRtc_ClientRole_Audience = 2,
};

typedef NS_ENUM(NSInteger, ByteRtcVideoProfile) {
    // res       fps  kbps
    ByteRtc_VideoProfile_Invalid = -1,
    ByteRtc_VideoProfile_120P = 0,         // 160x120   15   65
#if TARGET_OS_IPHONE
    ByteRtc_VideoProfile_120P_3 = 2,        // 120x120   15   50
    ByteRtc_VideoProfile_180P = 10,        // 320x180   15   140
    ByteRtc_VideoProfile_180P_3 = 12,        // 180x180   15   100
    ByteRtc_VideoProfile_180P_4 = 13,        // 240x180   15   120
#endif
    ByteRtc_VideoProfile_240P = 20,        // 320x240   15   200
#if TARGET_OS_IPHONE
    ByteRtc_VideoProfile_240P_3 = 22,        // 240x240   15   140
    ByteRtc_VideoProfile_240P_4 = 23,        // 424x240   15   220
#endif
    ByteRtc_VideoProfile_360P = 30,        // 640x360   15   400
#if TARGET_OS_IPHONE
    ByteRtc_VideoProfile_360P_3 = 32,        // 360x360   15   260
#endif
    ByteRtc_VideoProfile_360P_4 = 33,        // 640x360   30   600
    ByteRtc_VideoProfile_360P_6 = 35,        // 360x360   30   400
    ByteRtc_VideoProfile_360P_7 = 36,        // 480x360   15   320
    ByteRtc_VideoProfile_360P_8 = 37,        // 480x360   30   490
    ByteRtc_VideoProfile_360P_9 = 38,      // 640x360   15   800
    ByteRtc_VideoProfile_360P_10 = 39,     // 640x360   24   800
    ByteRtc_VideoProfile_360P_11 = 100,    // 640x360   24   1000
    ByteRtc_VideoProfile_480P = 40,        // 640x480   15   500
#if TARGET_OS_IPHONE
    ByteRtc_VideoProfile_480P_3 = 42,        // 480x480   15   400
#endif
    ByteRtc_VideoProfile_480P_4 = 43,        // 640x480   30   750
    ByteRtc_VideoProfile_480P_6 = 45,        // 480x480   30   600
    ByteRtc_VideoProfile_480P_8 = 47,        // 848x480   15   610
    ByteRtc_VideoProfile_480P_9 = 48,        // 848x480   30   930
    ByteRtc_VideoProfile_480P_10 = 49,        // 640x480   10   400
    ByteRtc_VideoProfile_720P = 50,        // 1280x720  15   1130
    ByteRtc_VideoProfile_720P_3 = 52,        // 1280x720  30   1710
    ByteRtc_VideoProfile_720P_5 = 54,        // 960x720   15   910
    ByteRtc_VideoProfile_720P_6 = 55,        // 960x720   30   1380
    ByteRtc_VideoProfile_1080P = 60,        // 1920x1080 15   2080
    ByteRtc_VideoProfile_1080P_3 = 62,        // 1920x1080 30   3150
    ByteRtc_VideoProfile_1080P_5 = 64,        // 1920x1080 60   4780
    ByteRtc_VideoProfile_1440P = 66,        // 2560x1440 30   4850
    ByteRtc_VideoProfile_1440P_2 = 67,        // 2560x1440 60   7350
    ByteRtc_VideoProfile_4K = 70,            // 3840x2160 30   8190
    ByteRtc_VideoProfile_4K_3 = 72,        // 3840x2160 60   13500
    ByteRtc_VideoProfile_DEFAULT = ByteRtc_VideoProfile_360P,
};

typedef NS_ENUM(NSInteger, ByteRtcErrorCode) {
    ByteRtc_Error_NoError = 0,
    ByteRtc_Error_Failed = 1,
    ByteRtc_Error_InvalidArgument = 2,
    ByteRtc_Error_NotReady = 3,
    ByteRtc_Error_NotSupported = 4,
    ByteRtc_Error_Refused = 5,
    ByteRtc_Error_BufferTooSmall = 6,
    ByteRtc_Error_NotInitialized = 7,
    ByteRtc_Error_NoPermission = 9,
    ByteRtc_Error_TimedOut = 10,
    ByteRtc_Error_Canceled = 11,
    ByteRtc_Error_TooOften = 12,
    ByteRtc_Error_BindSocket = 13,
    ByteRtc_Error_NetDown = 14,
    ByteRtc_Error_NoBufs = 15,
    ByteRtc_Error_JoinChannelRejected = 17,
    ByteRtc_Error_LeaveChannelRejected = 18,
    ByteRtc_Error_AlreadyInUse = 19,
    
    ByteRtc_Error_InvalidAppId = 101,
    ByteRtc_Error_InvalidChannelName = 102,
    ByteRtc_Error_ChannelKeyExpired = 109,
    ByteRtc_Error_InvalidChannelKey = 110,
    ByteRtc_Error_ConnectionInterrupted = 111, // only used in web sdk
    ByteRtc_Error_ConnectionLost = 112, // only used in web sdk
    ByteRtc_Error_NotInChannel = 113,
    ByteRtc_Error_SizeTooLarge = 114,
    ByteRtc_Error_BitrateLimit = 115,
    ByteRtc_Error_TooManyDataStreams = 116,
    ByteRtc_Error_DecryptionFailed = 120,
    
    ByteRtc_Error_LoadMediaEngine = 1001,
    ByteRtc_Error_StartCall = 1002,
    ByteRtc_Error_StartCamera = 1003,
    ByteRtc_Error_StartVideoRender = 1004,
    ByteRtc_Error_Adm_GeneralError = 1005,
    ByteRtc_Error_Adm_JavaResource = 1006,
    ByteRtc_Error_Adm_SampleRate = 1007,
    ByteRtc_Error_Adm_InitPlayout = 1008,
    ByteRtc_Error_Adm_StartPlayout = 1009,
    ByteRtc_Error_Adm_StopPlayout = 1010,
    ByteRtc_Error_Adm_InitRecording = 1011,
    ByteRtc_Error_Adm_StartRecording = 1012,
    ByteRtc_Error_Adm_StopRecording = 1013,
    ByteRtc_Error_Adm_RuntimePlayoutError = 1015,
    ByteRtc_Error_Adm_RuntimeRecordingError = 1017,
    ByteRtc_Error_Adm_RecordAudioFailed = 1018,
    ByteRtc_Error_Adm_Play_Abnormal_Frequency = 1020,
    ByteRtc_Error_Adm_Record_Abnormal_Frequency = 1021,
    ByteRtc_Error_Adm_Init_Loopback  = 1022,
    ByteRtc_Error_Adm_Start_Loopback = 1023,
    // 1025, as warning for interruption of adm on ios
    // 1026, as warning for route change of adm on ios
    // VDM error code starts from 1500
    ByteRtc_Error_Vdm_Camera_Not_Authorized = 1501,
    
    // VCM error code starts from 1600
    ByteRtc_Error_Vcm_Unknown_Error = 1600,
    ByteRtc_Error_Vcm_Encoder_Init_Error = 1601,
    ByteRtc_Error_Vcm_Encoder_Encode_Error = 1602,
    ByteRtc_Error_Vcm_Encoder_Set_Error = 1603,
};

__attribute__((visibility("default"))) @interface ByteRtcVideoCanvas : NSObject
@property (strong, nonatomic) UIView* _Nullable view;
@property (assign, nonatomic) ByteRtcRenderMode renderMode;
@property (assign, nonatomic) NSUInteger uid;
@end

__attribute__((visibility("default"))) @interface ByteVideoFrame : NSObject
// INFO: zhangle, only support NV12 and "ios texture"
@property (assign, nonatomic) NSInteger format; /* 10: android texture (GL_TEXTURE_2D)
                                                 11: android texture (OES, typically from camera)
                                                 12: ios texture (CVPixelBufferRef)
                                                 1: I420
                                                 2: BGRA
                                                 3: NV21
                                                 4: RGBA
                                                 5: IMC2
                                                 6: BGRA (same as 2)
                                                 7: ARGB
                                                 8: NV12
                                                 */
@property (assign, nonatomic) CMTime time; // time for this frame.
@property (assign, nonatomic) int stride DEPRECATED_MSG_ATTRIBUTE("use strideInPixels instead");
@property (assign, nonatomic) int strideInPixels; // how many pixels between 2 consecutive rows. Note: in pixel, not byte.
// in case of ios texture, it is not used
@property (assign, nonatomic) int height; // how many rows of pixels, in case of ios texture, it is not used

@property (assign, nonatomic) CVPixelBufferRef _Nullable textureBuf;

@property (strong, nonatomic) NSData * _Nullable dataBuf;  // raw data buffer. in case of ios texture, it is not used
@property (assign, nonatomic) int cropLeft;   // how many pixels to crop on the left boundary
@property (assign, nonatomic) int cropTop;    // how many pixels to crop on the top boundary
@property (assign, nonatomic) int cropRight;  // how many pixels to crop on the right boundary
@property (assign, nonatomic) int cropBottom; // how many pixels to crop on the bottom boundary
@property (assign, nonatomic) int rotation;   // 0, 90, 180, 270. See document for rotation calculation
/* Note
 * 1. strideInPixels
 *    Stride is in unit of pixel, not byte
 * 2. About frame width and height
 *    No field defined for width. However, it can be deduced by:
 *       croppedWidth = (strideInPixels - cropLeft - cropRight)
 *    And
 *       croppedHeight = (height - cropTop - cropBottom)
 * 3. About crop
 *    _________________________________________________________________.....
 *    |                        ^                                      |  ^
 *    |                        |                                      |  |
 *    |                     cropTop                                   |  |
 *    |                        |                                      |  |
 *    |                        v                                      |  |
 *    |                ________________________________               |  |
 *    |                |                              |               |  |
 *    |                |                              |               |  |
 *    |<-- cropLeft -->|          valid region        |<- cropRight ->|
 *    |                |                              |               | height
 *    |                |                              |               |
 *    |                |_____________________________ |               |  |
 *    |                        ^                                      |  |
 *    |                        |                                      |  |
 *    |                     cropBottom                                |  |
 *    |                        |                                      |  |
 *    |                        v                                      |  v
 *    _________________________________________________________________......
 *    |                                                               |
 *    |<---------------- strideInPixels ----------------------------->|
 *
 *    If your buffer contains garbage data, you can crop them. E.g. frame size is
 *    360 x 640, often the buffer stride is 368, i.e. there extra 8 pixels on the
 *    right are for padding, and should be removed. In this case, you can set:
 *    strideInPixels = 368;
 *    height = 640;
 *    cropRight = 8;
 *    // cropLeft, cropTop, cropBottom are default to 0
 */
@end

@class ByteRtcEngineKit;

@protocol ByteRtcEngineDelegate <NSObject>
@optional

/**
 *  Event of the user joined the channel.
 *
 *  @param channel The channel name
 *  @param uid     The remote user id
 *  @param elapsed The elapsed time (ms) from session beginning
 */
- (void) didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed;

/**
 *  Event of the user rejoined the channel
 *
 *  @param channel The channel name
 *  @param uid     The user id
 *  @param elapsed The elapsed time (ms) from session beginning
 */
- (void) didRejoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed;

/**
 *  Event of API call executed
 *
 *  @param api    The API description
 *  @param error  The error code
 */
- (void)didApiCallExecute:(NSString * _Nonnull)api error:(NSInteger)error;

/**
 *  Event of remote user joined
 *
 *  @param uid     The remote user id
 *  @param elapsed The elapsed time(ms) from the beginning of the session.
 */
- (void)didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

/**
 *  Event of remote user offlined
 *
 *  @param uid    The remote user id
 *  @param reason Reason of user offline, quit, drop or became audience
 */
- (void)didOfflineOfUid:(NSUInteger)uid reason:(ByteRtcUserOfflineReason)reason;

/**
 *  Event of the first local frame starts rendering on the screen.
 *
 *  @param size    The size of local video stream
 *  @param elapsed The elapsed time(ms) from the beginning of the session.
 */
- (void)firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed;

/**
 *  Event of the first frame of remote user is rendering on the screen.
 *
 *  @param uid     The remote user id
 *  @param size    The size of video stream
 *  @param elapsed The elapsed time(ms) from the beginning of the session.
 */
- (void)firstRemoteVideoFrameOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

- (void)firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

- (void)didOccurError:(ByteRtcErrorCode)errorCode;

- (void)rtcEngineConnectionDidInterrupted;
@end

__attribute__((visibility("default"))) @interface ByteRtcEngineKit : NSObject

/**
 *  Initializes the AgoraRtcEngineKit object.
 *
 *  @param appId The appId is issued to the application developers by Agora.
 *  @param delegate The AgoraRtcEngineDelegate
 *
 *  @return an object of AgoraRtcEngineKit class
 */
+ (instancetype _Nonnull)sharedEngineWithAppId:(NSString * _Nonnull)appId
appKey:(NSString * _Nonnull)appKey delegate:(id<ByteRtcEngineDelegate> _Nullable)delegate;

/**
 *  Initializes the Env.
 */
+ (void)setApiHost:(NSString * _Nonnull)host;

/**
 *  Set up the local video view. The video canvus is initialized with video display setting. And it could be called before entering a channel.
 *
 *  @param local the canvas is composed of view, renderMode and uid. How to initialize 'local'? please take a look at 'AgoraRtcVideoCanvas'
 *
 *  @return 0 when executed successfully. return negative value if failed.
 */

- (int)setupLocalVideo:(ByteRtcVideoCanvas * _Nullable)local;
/**
 *  Set up the remote video view. The video canvus is initialized with video display setting. It could be called after receiving the remote video streams to configure the video settings.
 *
 *  @param remote the canvas is composed of view, renderMode and uid. How to initialize 'remote'? please take a look at 'AgoraRtcVideoCanvas'
 *
 *  @return 0 when executed successfully. return negative value if failed.
 */
- (int)setupRemoteVideo:(ByteRtcVideoCanvas * _Nonnull)remote;
/**
 *  Create an open UDP socket to the AgoraRtcEngineKit cloud service to join a channel.
 Users in the same channel can talk to each other with same vendor key.
 Users using different vendor keys cannot call each other.
 The method is asynchronous.
 *
 *  @param channelKey        Channel key generated by APP using sign certificate.
 *  @param channelName       Joining in the same channel indicates those clients have entered in one room.
 *  @param info              Optional, this argument can be whatever the programmer likes personally.
 *  @param uid               Optional, this argument is the unique ID for each member in one channel.
 If not specified, or set to 0, the SDK automatically allocates an ID, and the id could be gotten in onJoinChannelSuccess.
 *  @param joinSuccessBlock  This callback indicates that the user has successfully joined the specified channel. Same as rtcEngine:didJoinChannel:withUid:elapsed:. If nil, the callback rtcEngine:didJoinChannel:withUid:elapsed: will works.
 *
 *  @return 0 when executed successfully, and return negative value when failed.
 */
- (int)joinChannelByKey:(NSString * _Nullable)channelKey
            channelName:(NSString * _Nonnull)channelName
                   info:(NSString * _Nullable)info
                    uid:(NSUInteger)uid;
/**
 *  set video profile, including resolution, fps, kbps
 *
 *  @param profile enumeration definition about the video resolution, fps and max kbps
 *
 *  @return 0 when executed successfully. return negative value if failed.
 */
- (int)setVideoProfile:(ByteRtcVideoProfile)profile swapWidthAndHeight:(BOOL)swapWidthAndHeight;
/**
 *  Set the role of user: such as broadcaster, audience
 *
 *  @param role the role of client
 *  @param permissionKey the permission key of role change
 *
 *  @return 0 when executed successfully. return negative value if failed.
 */
- (int)setClientRole:(ByteRtcClientRole)role withKey:(NSString * _Nullable)permissionKey;

/**
 *  lets the user leave a channel, i.e., hanging up or exiting a call.
 After joining a channel, the user must call the leaveChannel method to end the call before joining another one.
 It is synchronous, i.e., it only returns until the call ends and all resources are released.
 *  @param leaveChannelBlock indicate the statistics of this call, from joinChannel to leaveChannel, including duration, tx bytes and rx bytes in the call.
 *
 *  @return 0 if executed successfully, or return negative value if failed.
 */
- (int)leaveChannel;
/**
 *  Enables video mode.  Switches from audio to video mode. It could be called during a call and before entering a channel.
 *
 *  @return 0 when this method is called successfully, or negative value when this method failed.
 */
- (int)enableVideo;
/**
 *  Disable video mode. Switch from video to audio mode. It could be called during a call and before entering a channel.
 *
 *  @return 0 when this method is called successfully, or negative value when this method failed.
 */
- (int)disableVideo;
/**
 */
- (UIView * _Nullable)createRenderView:(CGRect) frame;

#pragma mark External media source
// If external video source is to use, call this API before enableVideo/startPreview
- (void)setExternalVideoSource:(BOOL)enable useTexture:(BOOL)useTexture pushMode:(BOOL)pushMode;
// Push a video frame to SDK
- (BOOL)pushExternalVideoFrame:(ByteVideoFrame * _Nonnull)frame;

- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;
- (int)muteLocalAudioStream:(BOOL)mute;
- (int)setLogFile:(NSString*_Nullable)filePath;

@end
