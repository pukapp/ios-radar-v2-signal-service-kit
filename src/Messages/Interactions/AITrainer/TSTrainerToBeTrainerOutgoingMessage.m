//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "TSTrainerToBeTrainerOutgoingMessage.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import "TSAccountManager.h"

@implementation TSTrainerToBeTrainerOutgoingMessage

- (instancetype)initWithThread:(TSThread *)thread textMessage:(NSString *)textMessage
{
    self = [super initOutgoingMessageWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                          inThread:thread
                                       messageBody:textMessage
                                     attachmentIds:[NSMutableArray new]
                                  expiresInSeconds:0
                                   expireStartedAt:0
                                    isVoiceMessage:NO
                                  groupMetaMessage:TSGroupMetaMessageUnspecified
                                     quotedMessage:nil
                                      contactShare:nil
                                       linkPreview:nil
                                    messageSticker:nil
               perMessageExpirationDurationSeconds:0];
    if (!self) {
        return self;
    }
    
    _textMessage = textMessage;
    
    return self;
}

- (BOOL)isTrainer
{
    return YES;
}

- (RadarMessageType)radarMessageType
{
    return RadarMessageTypeTrainer;
}

- (NSString *)trainOpenerId
{
    NSArray<NSString *> *components = [self.uniqueThreadId componentsSeparatedByString:@"-"];
    OWSAssertDebug(components.count > 1);
    return components[1];
}

- (SSKProtoDataMessageBuilder *)dataMessageBuilder
{
    SSKProtoDataMessageBuilder *_Nullable dataMessageBuilder = [super dataMessageBuilder];
    
    [dataMessageBuilder setFlags:SSKProtoDataMessageFlagsAiTrainerToBetrainerMessage];
    
    SSKProtoDataMessageAITrainModeInfoBuilder *trainInfoBuilder = [SSKProtoDataMessageAITrainModeInfo builder];
    
    NSArray<NSString *> *components = [self.uniqueThreadId componentsSeparatedByString:@"-"];
    NSString *beTrainerId = components.lastObject;
    NSString *trainOpenerId = components[1];
    
    [trainInfoBuilder setTrainerID:[TSAccountManager.sharedInstance localNumber]];
    [trainInfoBuilder setBeTrainerID:beTrainerId];
    [trainInfoBuilder setTrainOpenerID:trainOpenerId];
    
    NSError *error;
    SSKProtoDataMessageAITrainModeInfo *trainInfoProto = [trainInfoBuilder buildAndReturnError:&error];
    if (error) {
        OWSFailDebug(@"could not build protobuf: %@.", error);
    }
    
    [dataMessageBuilder setAiTrainModeInfo:trainInfoProto];
    
    return dataMessageBuilder;
}

- (TSThread *)thread
{
    NSString *beTrainerId = [[self.uniqueThreadId componentsSeparatedByString:@"-"] lastObject];
    OWSAssertDebug(beTrainerId);
    return [[TSContactThread alloc] initWithContactId:beTrainerId];
}
@end

