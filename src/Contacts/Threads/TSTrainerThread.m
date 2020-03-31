//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "TSTrainerThread.h"
#import "ContactsManagerProtocol.h"
#import "ContactsUpdater.h"
#import "NotificationsProtocol.h"
#import "OWSIdentityManager.h"
#import "SSKEnvironment.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <YapDatabase/YapDatabaseConnection.h>
#import <YapDatabase/YapDatabaseTransaction.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const TSTrainerThreadPrefix = @"t";

@implementation TSTrainerThread

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
{
    self = [super initWithUniqueId:uniqueId
                      archivalDate:archivalDate
         archivedAsOfMessageSortId:archivedAsOfMessageSortId
             conversationColorName:conversationColorName
                      creationDate:creationDate
isArchivedByLegacyTimestampForSorting:isArchivedByLegacyTimestampForSorting
                   lastMessageDate:lastMessageDate
                      messageDraft:messageDraft
                    mutedUntilDate:mutedUntilDate
             shouldThreadBeVisible:shouldThreadBeVisible];
    
    if (!self) {
        return self;
    }
    
    _hasDismissedOffers = hasDismissedOffers;
    
    return self;
}


- (instancetype)initWithContactId:(NSString *)contactId {
    NSString *uniqueIdentifier = [[self class] threadIdFromContactId:contactId];
    
    OWSAssertDebug(contactId.length > 0);
    
    self = [super initWithUniqueId:uniqueIdentifier];
    
    return self;
}

+ (instancetype)getOrCreateThreadWithContactId:(NSString *)contactId
                                   transaction:(YapDatabaseReadWriteTransaction *)transaction {
    OWSAssertDebug(contactId.length > 0);
    
    TSTrainerThread *thread =
    [self fetchObjectWithUniqueID:[self threadIdFromContactId:contactId] transaction:transaction];
    
    if (!thread) {
        thread = [[TSTrainerThread alloc] initWithContactId:contactId];
        [thread saveWithTransaction:transaction];
    }
    
    return thread;
}

+ (instancetype)getOrCreateThreadWithContactId:(NSString *)contactId
                                anyTransaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(contactId.length > 0);
    
    NSString *uniqueId = [self threadIdFromContactId:contactId];
    TSTrainerThread *thread = (TSTrainerThread *)[self anyFetchWithUniqueId:uniqueId transaction:transaction];
    
    if (!thread) {
        thread = [[TSTrainerThread alloc] initWithContactId:contactId];
        [thread anyInsertWithTransaction:transaction];
    }
    
    return thread;
}

+ (instancetype)getOrCreateThreadWithContactId:(NSString *)contactId
{
    OWSAssertDebug(contactId.length > 0);
    
    __block TSTrainerThread *thread;
    [[self dbReadWriteConnection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        thread = [self getOrCreateThreadWithContactId:contactId transaction:transaction];
    }];
    
    return thread;
}

+ (nullable instancetype)getThreadWithContactId:(NSString *)contactId
                                    transaction:(YapDatabaseReadTransaction *)transaction
{
    return [TSTrainerThread fetchObjectWithUniqueID:[self threadIdFromContactId:contactId] transaction:transaction];
}

+ (nullable instancetype)getThreadWithContactId:(NSString *)contactId
                                 anyTransaction:(SDSAnyReadTransaction *)transaction
{
    return (TSTrainerThread *)[TSTrainerThread anyFetchWithUniqueId:[self threadIdFromContactId:contactId]
                                                        transaction:transaction];
}

- (NSString *)contactIdentifier {
    return [[self class] contactIdFromThreadId:self.uniqueId];
}

- (SignalServiceAddress *)contactAddress
{
    return [[SignalServiceAddress alloc] initWithPhoneNumber:self.contactIdentifier];
}

- (NSArray<NSString *> *)recipientIdentifiers
{
    return @[self.contactIdentifier];
}

- (BOOL)isGroupThread {
    return NO;
}

- (BOOL)isTrainerThread {
    return YES;
}

- (BOOL)hasSafetyNumbers
{
    return !![[OWSIdentityManager sharedManager] identityKeyForRecipientId:self.contactIdentifier];
}


- (NSString *)name
{
    return [SSKEnvironment.shared.contactsManager displayNameForPhoneIdentifier:self.contactIdentifier];
}

+ (NSString *)threadIdFromContactId:(NSString *)contactId {
    return [TSTrainerThreadPrefix stringByAppendingString:contactId];
}

+ (NSString *)contactIdFromThreadId:(NSString *)threadId {
    return [threadId substringWithRange:NSMakeRange(1, threadId.length - 1)];
}

+ (NSString *)conversationColorNameForRecipientId:(NSString *)recipientId
                                      transaction:(SDSAnyReadTransaction *)transaction
{
    OWSAssertDebug(recipientId.length > 0);
    
    TSTrainerThread *_Nullable contactThread =
    [TSTrainerThread getThreadWithContactId:recipientId anyTransaction:transaction];
    if (contactThread) {
        return contactThread.conversationColorName;
    }
    return [self stableColorNameForNewConversationWithString:recipientId];
}

@end

NS_ASSUME_NONNULL_END

