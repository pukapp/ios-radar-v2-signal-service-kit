//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <SignalServiceKit/SignalServiceKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSThread;

@interface TSBeTrainerToTrainerOutgoingMessage : TSOutgoingMessage

@property (nullable, nonatomic, readonly) NSString *textMessage;

- (instancetype)initWithThread:(TSThread *)thread
                   textMessage:(NSString *)textMessage
              trainerContactId:(NSString *)trainerContactId
          trainOpenerContactId:(NSString *)trainOpenerContactId;

@end

NS_ASSUME_NONNULL_END
