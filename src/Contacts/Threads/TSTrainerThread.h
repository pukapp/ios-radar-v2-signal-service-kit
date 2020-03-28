//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <SignalServiceKit/SignalServiceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSTrainerThread : TSContactThread

- (instancetype)initWithContactId:(NSString *)contactId;

@end

NS_ASSUME_NONNULL_END
