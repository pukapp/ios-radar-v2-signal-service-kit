//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <SignalServiceKit/SignalServiceKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const TSTrainerThreadPrefix;

@class SignalServiceAddress;

@interface TSTrainerThread : TSThread


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


- (instancetype)initWithContactId:(NSString *)contactId;

@property (nonatomic) BOOL hasDismissedOffers;

+ (instancetype)getOrCreateThreadWithContactId:(NSString *)contactId NS_SWIFT_NAME(getOrCreateThread(contactId:));

+ (instancetype)getOrCreateThreadWithContactId:(NSString *)contactId
                                   transaction:(YapDatabaseReadWriteTransaction *)transaction;

+ (instancetype)getOrCreateThreadWithContactId:(NSString *)contactId
                                anyTransaction:(SDSAnyWriteTransaction *)transaction;

// Unlike getOrCreateThreadWithContactId, this will _NOT_ create a thread if one does not already exist.
+ (nullable instancetype)getThreadWithContactId:(NSString *)contactId transaction:(YapDatabaseReadTransaction *)transaction;
+ (nullable instancetype)getThreadWithContactId:(NSString *)contactId
                                 anyTransaction:(SDSAnyReadTransaction *)transaction;

- (NSString *)contactIdentifier;
- (SignalServiceAddress *)contactAddress;

+ (NSString *)contactIdFromThreadId:(NSString *)threadId;

+ (NSString *)threadIdFromContactId:(NSString *)contactId;

+ (NSString *)conversationColorNameForRecipientId:(NSString *)recipientId
                                      transaction:(SDSAnyReadTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
