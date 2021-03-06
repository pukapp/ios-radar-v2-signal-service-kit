//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSMessageServiceParams.h"
#import "TSConstants.h"
#import <SignalCoreKit/NSData+OWS.h>

NS_ASSUME_NONNULL_BEGIN

@implementation OWSMessageServiceParams

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return [NSDictionary mtl_identityPropertyMapWithModel:[self class]];
}

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
                     message:(NSString *_Nullable)message
              registrationId:(int)registrationId
{
    self = [super init];

    if (!self) {
        return self;
    }

    _type = type;
    _msgType = msgType;
    _destination = destination;
    _destinationDeviceId = deviceId;
    _destinationRegistrationId = registrationId;
    _content = [content base64EncodedString];
    _silent = isSilent;
    _online = isOnline;
    _trainer = isTrainer;
    _trainOpenerId = trainOpenerId;
    _typing = typing;
    _message = message;

    return self;
}

@end

NS_ASSUME_NONNULL_END
