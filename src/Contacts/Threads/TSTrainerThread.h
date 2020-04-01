//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <SignalServiceKit/SignalServiceKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const TSTrainerThreadPrefix;

@class SignalServiceAddress;

@interface TSTrainerThread : TSThread

@property (nonatomic, readonly, nullable) NSString *trainOpenerContactId;
@property (nonatomic, readonly, nullable) NSString *beTrainerContactId;
@property (nonatomic) BOOL hasDismissedOffers;

- (instancetype)initWithUniqueId:(NSString *)uniqueId
                    archivalDate:(nullable NSDate *)archivalDate
       archivedAsOfMessageSortId:(nullable NSNumber *)archivedAsOfMessageSortId
           conversationColorName:(ConversationColorName)conversationColorName
                    creationDate:(nullable NSDate *)creationDate
isArchivedByLegacyTimestampForSorting:(BOOL)isArchivedByLegacyTimestampForSorting
                 lastMessageDate:(nullable NSDate *)lastMessageDate
                    messageDraft:(nullable NSString *)messageDraft
                  mutedUntilDate:(nullable NSDate *)mutedUntilDate
           shouldThreadBeVisible:(BOOL)shouldThreadBeVisible
              hasDismissedOffers:(BOOL)hasDismissedOffers
NS_SWIFT_NAME(init(uniqueId:archivalDate:archivedAsOfMessageSortId:conversationColorName:creationDate:isArchivedByLegacyTimestampForSorting:lastMessageDate:messageDraft:mutedUntilDate:shouldThreadBeVisible:hasDismissedOffers:));


- (instancetype)initWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                          beTrainerContactId:(NSString *)beTrainerContactId;

+ (instancetype)getOrCreateThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                       beTrainerContactId:(NSString *)beTrainerContactId;

+ (instancetype)getOrCreateThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                       beTrainerContactId:(NSString *)beTrainerContactId
                                           anyTransaction:(SDSAnyWriteTransaction *)transaction;

+ (nullable instancetype)getThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                        beTrainerContactId:(NSString *)beTrainerContactId
                                               transaction:(YapDatabaseReadTransaction *)transaction;

+ (nullable instancetype)getThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                        beTrainerContactId:(NSString *)beTrainerContactId
                                            anyTransaction:(SDSAnyReadTransaction *)transaction;

- (NSString *)contactIdentifier;

+ (NSString *)conversationColorNameForRecipientId:(NSString *)recipientId
                                      transaction:(SDSAnyReadTransaction *)transaction;
@end

NS_ASSUME_NONNULL_END
