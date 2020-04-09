//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "TSConstants.h"
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Contstructs the per-device-message parameters used when submitting a message to
 * the Signal Web Service.
 *
 * See:
 * https://github.com/signalapp/libsignal-service-java/blob/master/java/src/main/java/org/whispersystems/signalservice/internal/push/OutgoingPushMessage.java
 */
@interface OWSMessageServiceParams : MTLModel <MTLJSONSerializing>

/// 0：普通聊天模式;1:训练者聊天模式
@property (nonatomic, readonly) int msgType;
@property (nonatomic, readonly) int type;
@property (nonatomic, readonly) NSString *destination;
@property (nonatomic, readonly) int destinationDeviceId;
@property (nonatomic, readonly) int destinationRegistrationId;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) BOOL silent;
@property (nonatomic, readonly) BOOL online;
@property (nonatomic, readonly) BOOL trainer; // 是否是训练者发送的消息

/// 训练开启者contact id
@property (nonatomic, readonly, nullable) NSString *trainOpenerId;

@property (nonatomic, readonly) BOOL typing; // 是否正在输入

- (instancetype)initWithType:(TSWhisperMessageType)type
                     msgType:(RadarMessageType)msgType
                 recipientId:(NSString *)destination
                      device:(int)deviceId
                     content:(NSData *)content
                    isSilent:(BOOL)isSilent
                    isOnline:(BOOL)isOnline
                   isTrainer:(BOOL)isTrainer
               trainOpenerId:(NSString *_Nullable)trainOpenerId
                      typing:(BOOL)typing
              registrationId:(int)registrationId;

@end

NS_ASSUME_NONNULL_END
