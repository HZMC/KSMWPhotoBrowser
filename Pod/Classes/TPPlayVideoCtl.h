//
//  TPPlayVideoCtl.h
//  KSMWPhotoBrowser-MWPhotoBrowser
//
//  Created by xzming on 2020/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TPPlayOverCall)(void);

@interface TPPlayVideoCtl : UIViewController
@property (nonatomic, copy) TPPlayOverCall playDone;
@property (nonatomic, strong) NSDictionary *customHeader;

- (instancetype)initWithVideoUrl:(NSURL *)videoLink;

- (void)pause;

@end

NS_ASSUME_NONNULL_END
