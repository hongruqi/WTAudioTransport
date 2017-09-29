//
//  WTAudioTransport.m
//  WTAudioTransport
//
//  Created by hongru qi on 29/09/2017.
//

#import "WTAudioTransport.h"
#import "WTAudioTranscoder.h"
#import <libkern/OSAtomic.h>

#define SEND_DATA_LENGTH (44100*8)
#define SEND_TIME_INTERVAL         0.2
#define SEND_TIME_TOLERANC         0

@interface WTAudioTransport()<WTAudioTranscoderDelegate>
{
    void* _pcmDataBuffer;
}

@property (nonatomic, strong) NSMutableData *musicData;
@property (nonatomic, strong) dispatch_queue_t audioTransport;
@property (nonatomic, strong) dispatch_source_t sendTimer;
@property (nonatomic, strong) WTAudioTranscoder *transcoder;

@end

@implementation WTAudioTransport

- (id)initWithURL:(NSURL *)url httpRequestHeaders:(NSDictionary *)httpRequestHeaders transcodingToUrl:(NSURL *)transcodeToUrl{
    
    if (self = [super init]) {
        _musicData = [NSMutableData data];
        _audioTransport = dispatch_queue_create("com.AudioTransport.queue", NULL);
        _pcmDataBuffer = malloc(SEND_DATA_LENGTH);
        _transcoder = [[WTAudioTranscoder alloc] initWithURL:url httpRequestHeaders:httpRequestHeaders transcodingToUrl:transcodeToUrl];
        _transcoder.delegate = self;
        _transcoder.outputAudioFileType = kAudioFileWAVEType;
        _transcoder.outputAudioFormat = kAudioFormatLinearPCM;
        _transcoder.outputBufferSize = SEND_DATA_LENGTH;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url transcodingToUrl:(NSURL *)transcodeToUrl{
    return [self initWithURL:url httpRequestHeaders:nil transcodingToUrl:transcodeToUrl];
}

-(void)dealloc{
    if (_pcmDataBuffer) {
        free(_pcmDataBuffer);
    }
    
    _pcmDataBuffer = NULL;
}

- (void)startTransport
{
    dispatch_async(self.audioTransport, ^{
        [self.transcoder start];
        [self createAndStartSendDataTimer];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)createAndStartSendDataTimer
{
    
    self.sendTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.audioTransport);
    
    _pcmDataBuffer = malloc(SEND_DATA_LENGTH);
    
    if (self.sendTimer != NULL) {
        dispatch_source_set_timer(self.sendTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, SEND_TIME_INTERVAL * NSEC_PER_SEC),
                                  SEND_TIME_TOLERANC * NSEC_PER_SEC, 0);
        
        dispatch_source_set_event_handler(self.sendTimer, ^{
            [self readNextPCMData];
        });
        
        dispatch_resume(self.sendTimer);
    }
    
}

- (void)cancel
{
    [self invalidateSendTimer];
    [self.transcoder cancel];
}


- (void)invalidateSendTimer
{
    if (self.sendTimer != NULL) {
        dispatch_source_t timer = self.sendTimer;
        
        dispatch_async(self.audioTransport, ^{
            dispatch_source_cancel(timer);
        });
    }
    
}

- (void)readNextPCMData
{
    long readLength = 0;
    
    if ([self.musicData length] >= SEND_DATA_LENGTH) {
        readLength = SEND_DATA_LENGTH;
        
        [self.musicData getBytes:_pcmDataBuffer range:NSMakeRange(0,SEND_DATA_LENGTH)];
        [self.musicData replaceBytesInRange:NSMakeRange(0, SEND_DATA_LENGTH) withBytes:NULL length:0];
    }else {
        readLength = [self.musicData length];
        [self.musicData getBytes:_pcmDataBuffer range:NSMakeRange(0,readLength)];
        [self.musicData replaceBytesInRange:NSMakeRange(0, readLength) withBytes:NULL length:0];
    }
    
    if (readLength > 0) {
        // send buffer
        NSData *sendData = [NSData dataWithBytes:_pcmDataBuffer length:SEND_DATA_LENGTH];
        [self sendData:sendData];
    }else {
        if (_pcmDataBuffer) {
            free(_pcmDataBuffer);
        }
        
        _pcmDataBuffer = NULL;
    }
}

- (void)sendData:(NSData *)data{
    
    dispatch_async(_audioTransport, ^{
        if (self.progressBlock) {
            self.progressBlock(data);
        }
    });
    
}

#pragma mark - WTAudioTranscoderDelegate

- (void)audioTranscoder:(WTAudioTranscoder *)converter data:(NSData *)data{
    NSLog(@"last buffer size = %lu", (unsigned long)data.length);
    [self.musicData appendData:data];
}

- (void)audioTranscoder:(WTAudioTranscoder *)transcoder streamError:(NSError *)error code:(CFStreamError)errorCode{
    [self invalidateSendTimer];
    
    if (self.failedBlock) {
        self.failedBlock(error);
    }
}

- (void)audioTranscoderDone:(WTAudioTranscoder *)audioTranscoder{
    NSLog(@"audio transcoder done");
    [self invalidateSendTimer];
    
    if (self.doneBlock) {
        self.doneBlock(audioTranscoder.transcodeToUrl);
    }
}

- (void)audioTranscoderFailed:(WTAudioTranscoder *)audioTranscoder{
    [self invalidateSendTimer];
    
    if (self.failedBlock) {
        self.failedBlock(nil);
    }
    
}
@end
