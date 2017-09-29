//
//  WTAudioTranscoder.h
//  WTAudioTransport
//
//  Created by hongru qi on 29/09/2017.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class WTAudioTranscoder;

typedef void (^ WTAudioTranscoderStreamErrorBlock)(WTAudioTranscoder *transcoder, NSError *error, CFStreamError code);
typedef void (^ WTAudioTranscoderFailedBlock)(WTAudioTranscoder *transcoder);
typedef void (^ WTAudioTranscoderDoneBlock)(WTAudioTranscoder *transcoder);

typedef NS_ENUM(NSInteger, WTAudioTranscoderStatus){
    WTAudioTranscoderIdle,
    WTAudioTranscoderInProgress,
    WTAudioTranscoderDone,
    WTAudioTranscoderStreamError,
    WTAudioTranscoderFailed
};

@protocol WTAudioTranscoderDelegate;

@interface WTAudioTranscoder : NSObject

- (id)initWithURL:(NSURL *)url httpRequestHeaders:(NSDictionary *)httpRequestHeaders  transcodingToUrl:(NSURL *)transcodeToUrl;

- (id)initWithURL:(NSURL *)url transcodingToUrl:(NSURL *)transcodeToUrl;

@property (nonatomic, weak) id<WTAudioTranscoderDelegate> delegate;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURL *transcodeToUrl;
@property (nonatomic, assign, readonly) UInt32 httpStatusCode;
@property (nonatomic, assign, readonly) CFStreamStatus streamStatus;
@property (nonatomic, assign, readonly) CFStreamError streamErrorCode;
@property (nonatomic, strong, readonly) NSError *streamError;
@property (nonatomic, assign, readonly) SInt64 streamLength;
@property (nonatomic, assign, readonly) SInt64 streamPosition;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, assign, readonly) WTAudioTranscoderStatus status;


@property (nonatomic, strong) WTAudioTranscoderStreamErrorBlock streamErrorBlock;
@property (nonatomic, strong) WTAudioTranscoderFailedBlock failedBlock;
@property (nonatomic, strong) WTAudioTranscoderDoneBlock doneBlock;

@property (nonatomic, assign, readonly) BOOL isIdle;
@property (nonatomic, assign, readonly) BOOL isInProgress;
@property (nonatomic, assign, readonly) BOOL isDone;
@property (nonatomic, assign, readonly) BOOL isStreamError;
@property (nonatomic, assign, readonly) BOOL isFailed;

/**
 @property readBufferSize
 @brief  每次转码成功后，返回的NSData 的Size。
 */

@property (nonatomic, assign) UInt32 outputBufferSize;
/**
 @property outputAudioFileType
 @brief  输出文件类型 Default value is kAudioFileCAFType
 */
@property (nonatomic, assign) AudioFileTypeID outputAudioFileType;

/**
 @property outputAudioFormat
 @brief 输出文件格式 format Default value is kAudioFormatLinearPCM
 */
@property (nonatomic, assign) AudioFormatID outputAudioFormat;

/**
 @property outputAudioFormatFlags
 @brief the output file format flags
 Default value is kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
 */
@property (nonatomic, assign) AudioFormatFlags outputAudioFormatFlags;

- (void)start;

- (void)cancel;

- (void)reconnect;

@end

@protocol WTAudioTranscoderDelegate <NSObject>
@optional

/**
 @brief 输出stream 出错，你可以调用 [reconnect] 继续尝试。
 */
- (void)audioTranscoder:(WTAudioTranscoder *)transcoder streamError:(NSError *)error code:(CFStreamError)errorCode;

/**
 @brief 转码出错，可能是不支持输出格式转码，详细参照：
 // From https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/AudioUnitHostingGuide_iOS/ConstructingAudioUnitApps/ConstructingAudioUnitApps.html
 */
- (void)audioTranscoderFailed:(WTAudioTranscoder *)audioTranscoder;

/**
 @brief 成功完成转码
 */
- (void)audioTranscoderDone:(WTAudioTranscoder *)audioTranscoder;
/**

 @brief 将转好的内容返回。
 */
- (void)audioTranscoder:(WTAudioTranscoder*)converter data:(NSData *)data;

@end
