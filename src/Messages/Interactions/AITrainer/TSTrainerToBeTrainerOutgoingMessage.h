//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <SignalServiceKit/SignalServiceKit.h>

/// 训练者 发给 被训练者 的消息

NS_ASSUME_NONNULL_BEGIN

@class TSThread;

@interface TSTrainerToBeTrainerOutgoingMessage : TSOutgoingMessage

@property (nullable, nonatomic, readonly) NSString *textMessage;

- (instancetype)initWithThread:(TSThread *)thread textMessage:(NSString *)textMessage;

@end

NS_ASSUME_NONNULL_END
