//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "TSBeTrainerToTrainerOutgoingMessage.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/TSAccountManager.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

@interface TSBeTrainerToTrainerOutgoingMessage ()

@property (nullable) NSString *trainerContactId;

@property (nullable) NSString *trainOpenerContactId;

@end

@implementation TSBeTrainerToTrainerOutgoingMessage

- (instancetype)initWithThread:(TSThread *)thread
                   textMessage:(NSString *)textMessage
              trainerContactId:(NSString *)trainerContactId
          trainOpenerContactId:(NSString *)trainOpenerContactId
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
    _trainerContactId = trainerContactId;
    _trainOpenerContactId = trainOpenerContactId;
    
    return self;
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (RadarMessageType)radarMessageType
{
    return RadarMessageTypeTrainer;
}

- (NSString *)trainOpenerId
{
    OWSAssertDebug(_trainOpenerContactId);
    return _trainOpenerContactId;
}

- (SSKProtoDataMessageBuilder *)dataMessageBuilder
{
    SSKProtoDataMessageBuilder *_Nullable dataMessageBuilder = [super dataMessageBuilder];
    
    [dataMessageBuilder setFlags:SSKProtoDataMessageFlagsAiBetrainerToTrainerMessage];
    
    SSKProtoDataMessageAITrainModeInfoBuilder *trainInfoBuilder = [SSKProtoDataMessageAITrainModeInfo builder];
    
    [trainInfoBuilder setTrainerID:self.trainerContactId];
    [trainInfoBuilder setBeTrainerID:[TSAccountManager.sharedInstance localNumber]];
    [trainInfoBuilder setTrainOpenerID:self.trainOpenerContactId];
    
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
    OWSAssertDebug(_trainerContactId);
    return [[TSContactThread alloc] initWithContactId:_trainerContactId];
}

@end
