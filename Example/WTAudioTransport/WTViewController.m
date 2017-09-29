//
//  WTViewController.m
//  WTAudioTransport
//
//  Created by Walter on 09/29/2017.
//  Copyright (c) 2017 Walter. All rights reserved.
//

#import "WTViewController.h"
#import "WTAudioTransport.h"

@interface WTViewController ()

@property (nonatomic, strong) WTAudioTransport *audioTransport;

@end

@implementation WTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //http://m128.xiami.net/46/15046/130555/1326590_2360054_l.mp3?auth_key=1507258800-0-0-6696df3aa52c174c479466f91f77d234
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths lastObject];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directryPath = [path stringByAppendingPathComponent:@"Audio"];
    [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *filePath = [directryPath stringByAppendingPathComponent:@"output3.caf"];
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];

    NSURL* outputURL = [NSURL fileURLWithPath:filePath];
    
    _audioTransport = [[WTAudioTransport alloc] initWithURL:[NSURL URLWithString:@"http://m128.xiami.net/46/15046/130555/1326590_2360054_l.mp3?auth_key=1507258800-0-0-6696df3aa52c174c479466f91f77d234"] httpRequestHeaders:nil transcodingToUrl:nil];
    
    [_audioTransport startTransport];
    
    _audioTransport.failedBlock = ^(NSError *error){
        NSLog(@"transport error");
    };
    
    _audioTransport.doneBlock = ^(NSURL *output){
        NSLog(@"transport done");
    };
    
    _audioTransport.progressBlock = ^(NSData *pcmData){
        NSLog(@"transport data %lu", (unsigned long)pcmData.length);
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
