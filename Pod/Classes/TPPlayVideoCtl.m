//
//  TPPlayVideoCtl.m
//  KSMWPhotoBrowser-MWPhotoBrowser
//
//  Created by xzming on 2020/11/30.
//

#import "TPPlayVideoCtl.h"
@import ZFPlayer;
@import KTVHTTPCache;

typedef void (^ProxyRestarted)(void);
static void inline mw_dispatch_main_sync_safe(void (^_Nonnull block)(void))
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}
static void inline mw_dispatch_async(void (^_Nonnull block)(void))
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


@interface TPPlayVideoCtl ()

@property (nonatomic, strong) ZFPlayerController *playCtl;
@property (nonatomic, strong) NSURL *videoLink;

@end

@implementation TPPlayVideoCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    ZFAVPlayerManager *man = [[ZFAVPlayerManager alloc] init];
    _playCtl = [ZFPlayerController playerWithPlayerManager:man containerView:self.view];
    ZFPlayerControlView *ctlview = [ZFPlayerControlView new];
    _playCtl.controlView = ctlview;
    @weakify(self);
    if ([self.videoLink isFileURL]) {
        [self.playCtl setAssetURL:self.videoLink];
        
    } else {
        NSURL *proxyURL = [KTVHTTPCache proxyURLWithOriginalURL:self.videoLink];
        [TPPlayVideoCtl restartProxy:^{
            [weak_self.playCtl setAssetURL:proxyURL];
        }];
    }
    
    [_playCtl setPlayerDidToEnd:^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        if (weak_self.playDone) {
            weak_self.playDone();
        }
    }];
}

- (instancetype)initWithVideoUrl:(NSURL *)videoLink {
    if (self = [super init]) {
        self.videoLink = videoLink;
    }
    return self;
}

- (void)pause{
    [self.playCtl.currentPlayerManager pause];
}

+ (void)restartProxy:(ProxyRestarted)complete {
    if ([KTVHTTPCache proxyIsRunning]) {
        mw_dispatch_main_sync_safe(^{
            if (complete) {
                complete();
            }
        });
        return;
    }

    NSError *error;
    [KTVHTTPCache proxyStart:&error];
    NSLog(@"local cache restart server err:%@", error);
    mw_dispatch_async(^{
        while (![KTVHTTPCache proxyIsRunning]) {
            //check after 1 s
            NSLog(@"wait proxy up...");
            usleep(500 * 1000);
        }
        mw_dispatch_main_sync_safe(^{
            if (complete) {
                complete();
            }
        });
    });
}

@end
