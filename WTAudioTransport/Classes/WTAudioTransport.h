//
//  WTAudioTransport.h
//  WTAudioTransport
//
//  Created by hongru qi on 29/09/2017.
//

#import <Foundation/Foundation.h>

typedef void (^ WTAudioTransportFailedBlock)(NSError *error);

typedef void (^ WTAudioTransportDoneBlock)(NSURL *outputUrl);

typedef void (^ WTAudioTransportProgressBlock)(NSData *pcmData);

@interface WTAudioTransport : NSObject

@property (nonatomic, copy) WTAudioTransportFailedBlock failedBlock;
@property (nonatomic, copy) WTAudioTransportDoneBlock doneBlock;
@property (nonatomic, copy) WTAudioTransportProgressBlock progressBlock;

- (id)initWithURL:(NSURL *)url httpRequestHeaders:(NSDictionary *)httpRequestHeaders  transcodingToUrl:(NSURL *)transcodeToUrl;

- (id)initWithURL:(NSURL *)url transcodingToUrl:(NSURL *)transcodeToUrl;

- (void)startTransport;

- (void)cancel;

@end
