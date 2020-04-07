//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "TSTrainerToTrainOpenerOutgoingMessage.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <SignalServiceKit/TSAccountManager.h>

@implementation TSTrainerToTrainOpenerOutgoingMessage


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

- (BOOL)shouldBeSaved
{
    return NO;
}

- (SSKProtoDataMessageBuilder *)dataMessageBuilder
{
    SSKProtoDataMessageBuilder *_Nullable dataMessageBuilder = [super dataMessageBuilder];
    
    [dataMessageBuilder setFlags:SSKProtoDataMessageFlagsAiTrainerToTrainopenerMessage];
    
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

- (TSThread *)thread {
    NSString *trainOpenerId = [self.uniqueThreadId componentsSeparatedByString:@"-"][1];
    OWSAssertDebug(trainOpenerId);
    return [[TSContactThread alloc] initWithContactId:trainOpenerId];
}

@end


