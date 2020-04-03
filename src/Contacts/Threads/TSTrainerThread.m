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
    NSArray<NSString *> *components = [uniqueId componentsSeparatedByString:@"-"];
    _trainOpenerContactId = components.firstObject;
    _beTrainerContactId = components.lastObject;
    
    return self;
}

- (instancetype)initWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                          beTrainerContactId:(NSString *)beTrainerContactId
{
    OWSAssertDebug(trainOpenerContactId.length > 0);
    OWSAssertDebug(beTrainerContactId.length > 0);
    
    NSString *uniqueId = [[NSString alloc] initWithFormat:@"t-%@-%@", trainOpenerContactId, beTrainerContactId];
    self = [super initWithUniqueId:uniqueId];
    
    _trainOpenerContactId = trainOpenerContactId;
    _beTrainerContactId = beTrainerContactId;
    
    return self;
}

+ (instancetype)getOrCreateThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                       beTrainerContactId:(NSString *)beTrainerContactId
{
    OWSAssertDebug(trainOpenerContactId.length > 0);
    OWSAssertDebug(beTrainerContactId.length > 0);
    
    __block TSTrainerThread *thread;
    [[self dbReadWriteConnection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        thread = [self getThreadWithTrainOpenerContactId:trainOpenerContactId
                                      beTrainerContactId:beTrainerContactId
                                             transaction:transaction];
    }];
    
    return thread;
}

+ (instancetype)getOrCreateThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                       beTrainerContactId:(NSString *)beTrainerContactId
                                           anyTransaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(trainOpenerContactId.length > 0);
    OWSAssertDebug(beTrainerContactId.length > 0);
    NSString *uniqueId = [[NSString alloc] initWithFormat:@"t-%@-%@", trainOpenerContactId, beTrainerContactId];
    TSTrainerThread *thread = (TSTrainerThread *)[self anyFetchWithUniqueId:uniqueId transaction:transaction];
    if (!thread) {
        thread = [[TSTrainerThread alloc] initWithTrainOpenerContactId:trainOpenerContactId
                                                    beTrainerContactId:beTrainerContactId];
        [thread anyInsertWithTransaction:transaction];
    }
    return thread;
}

+ (nullable instancetype)getThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                               beTrainerContactId:(NSString *)beTrainerContactId
                                      transaction:(YapDatabaseReadTransaction *)transaction
{
    OWSAssertDebug(trainOpenerContactId.length > 0);
    OWSAssertDebug(beTrainerContactId.length > 0);
    NSString *uniqueId = [[NSString alloc] initWithFormat:@"t-%@-%@", trainOpenerContactId, beTrainerContactId];
    TSTrainerThread *thread = [self fetchObjectWithUniqueID:uniqueId transaction:transaction];
    return thread;
}

+ (nullable instancetype)getThreadWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                               beTrainerContactId:(NSString *)beTrainerContactId
                                   anyTransaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(trainOpenerContactId.length > 0);
    OWSAssertDebug(beTrainerContactId.length > 0);
    NSString *uniqueId = [[NSString alloc] initWithFormat:@"t-%@-%@", trainOpenerContactId, beTrainerContactId];
    TSTrainerThread *thread = (TSTrainerThread *)[self anyFetchWithUniqueId:uniqueId transaction:transaction];
    return thread;
}


- (BOOL)isGroupThread {
    return NO;
}

- (BOOL)isTrainerThread {
    return YES;
}

- (NSString *)name
{
    NSArray<NSString *> *components = [self.uniqueId componentsSeparatedByString:@"-"];
    NSString *item1 = [components[1] substringFromIndex:12];
    NSString *item2 = [components[2] substringFromIndex:12];
    return [[NSString alloc] initWithFormat:@"训练对象(%@%@)", item1, item2];
}

- (NSString *)contactIdentifier {
    NSString *beTrainerId = [[self.uniqueId componentsSeparatedByString:@"-"] lastObject];
    OWSAssertDebug(beTrainerId);
    return beTrainerId;
}

- (NSArray<NSString *> *)recipientIdentifiers
{
    
    return @[[self contactIdentifier]];
}

- (BOOL)hasSafetyNumbers
{
    return !![[OWSIdentityManager sharedManager] identityKeyForRecipientId:[self contactIdentifier]];
}

- (SignalServiceAddress *)contactAddress
{
    return [[SignalServiceAddress alloc] initWithPhoneNumber:self.contactIdentifier];
}

+ (NSString *)conversationColorNameForRecipientId:(NSString *)recipientId
                                      transaction:(SDSAnyReadTransaction *)transaction
{
    OWSAssertDebug(recipientId.length > 0);
    
    TSContactThread *_Nullable contactThread =
    [TSContactThread getThreadWithContactId:recipientId anyTransaction:transaction];
    if (contactThread) {
        return contactThread.conversationColorName;
    }
    return [self stableColorNameForNewConversationWithString:recipientId];
}
@end

NS_ASSUME_NONNULL_END

