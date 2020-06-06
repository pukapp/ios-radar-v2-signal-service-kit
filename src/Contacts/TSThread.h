//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "TSYapDatabaseObject.h"

NS_ASSUME_NONNULL_BEGIN

BOOL IsNoteToSelfEnabled(void);

@class OWSDisappearingMessagesConfiguration;
@class SDSAnyReadTransaction;
@class SDSAnyWriteTransaction;
@class TSInteraction;
@class TSInvalidIdentityKeyReceivingErrorMessage;

typedef NSString *ConversationColorName NS_STRING_ENUM;

extern ConversationColorName const ConversationColorNameCrimson;
extern ConversationColorName const ConversationColorNameVermilion;
extern ConversationColorName const ConversationColorNameBurlap;
extern ConversationColorName const ConversationColorNameForest;
extern ConversationColorName const ConversationColorNameWintergreen;
extern ConversationColorName const ConversationColorNameTeal;
extern ConversationColorName const ConversationColorNameBlue;
extern ConversationColorName const ConversationColorNameIndigo;
extern ConversationColorName const ConversationColorNameViolet;
extern ConversationColorName const ConversationColorNamePlum;
extern ConversationColorName const ConversationColorNameTaupe;
extern ConversationColorName const ConversationColorNameSteel;

extern ConversationColorName const kConversationColorName_Default;

extern NSString *const OWSRobotThreadContactIdentifier;
extern NSString *const OWSSecurityThreadContactIdentifier;
extern NSString *const OWSTradeThreadContactIdentifier;
extern NSString *const OWSWalletThreadContactIdentifier;
extern NSString *const OWSMallThreadContactIdentifier;
extern NSString *const OWSWebOrderThreadContactIdentifier;
extern NSString *const OWSOTCOrderThreadContactIdentifier;

/**
 *  TSThread is the superclass of TSContactThread and TSGroupThread
 */
@interface TSThread : TSYapDatabaseObject

@property (nonatomic) BOOL shouldThreadBeVisible;
@property (nonatomic, readonly, nullable) NSDate *creationDate;
@property (nonatomic, readonly) BOOL isArchivedByLegacyTimestampForSorting;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

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
NS_SWIFT_NAME(init(uniqueId:archivalDate:archivedAsOfMessageSortId:conversationColorName:creationDate:isArchivedByLegacyTimestampForSorting:lastMessageDate:messageDraft:mutedUntilDate:shouldThreadBeVisible:));

// clang-format on

// --- CODE GENERATION MARKER

/**
 *  Whether the object is a group thread or not.
 *
 *  @return YES if is a group thread, NO otherwise.
 */
- (BOOL)isGroupThread;


/// 训练者聊天
- (BOOL)isTrainerThread;

/**
 *  Returns the name of the thread.
 *
 *  @return The name of the thread.
 */
- (NSString *)name;

@property (nonatomic, readonly) ConversationColorName conversationColorName;

- (void)updateConversationColorName:(ConversationColorName)colorName
                        transaction:(YapDatabaseReadWriteTransaction *)transaction;
+ (ConversationColorName)stableColorNameForNewConversationWithString:(NSString *)colorSeed;
@property (class, nonatomic, readonly) NSArray<ConversationColorName> *conversationColorNames;

/**
 * @returns
 *   Signal Id (e164) of the contact if it's a contact thread.
 */
- (nullable NSString *)contactIdentifier;

/**
 * @returns recipientId for each recipient in the thread
 */
@property (nonatomic, readonly) NSArray<NSString *> *recipientIdentifiers;

- (BOOL)isNoteToSelf;

- (BOOL)isRobot;

- (BOOL)isTradeThread;

- (BOOL)isWalletThread;

- (BOOL)isMallThread;
    
- (BOOL)isSecurityThread;

- (BOOL)isWebOrderThread;

- (BOOL)isOTCOrderThread;

#pragma mark Interactions

/**
 *  @return The number of interactions in this thread.
 */
- (NSUInteger)numberOfInteractionsWithTransaction:(SDSAnyReadTransaction *)transaction;

/**
 * Get all messages in the thread we weren't able to decrypt
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSArray<TSInvalidIdentityKeyReceivingErrorMessage *> *)receivedMessagesForInvalidKey:(NSData *)key;
#pragma clang diagnostic pop

- (BOOL)hasSafetyNumbers;

- (void)markAllAsReadWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;

/**
 *  Returns the string that will be displayed typically in a conversations view as a preview of the last message
 *received in this thread.
 *
 *  @return Thread preview string.
 */
- (NSString *)lastMessageTextWithTransaction:(SDSAnyReadTransaction *)transaction
    NS_SWIFT_NAME(lastMessageText(transaction:));

- (nullable TSInteraction *)lastInteractionForInboxWithTransaction:(SDSAnyReadTransaction *)transaction
    NS_SWIFT_NAME(lastInteractionForInbox(transaction:));

/**
 *  Updates the thread's caches of the latest interaction.
 *
 *  @param lastMessage Latest Interaction to take into consideration.
 *  @param transaction Database transaction.
 */
- (void)updateWithLastMessage:(TSInteraction *)lastMessage transaction:(YapDatabaseReadWriteTransaction *)transaction;

#pragma mark Archival

/**
 * @return YES if no new messages have been sent or received since the thread was last archived.
 */
- (BOOL)isArchivedWithTransaction:(YapDatabaseReadTransaction *)transaction;

/**
 *  Archives a thread
 *
 *  @param transaction Database transaction.
 */
- (void)archiveThreadWithTransaction:(SDSAnyWriteTransaction *)transaction;

/**
 *  Unarchives a thread
 *
 *  @param transaction Database transaction.
 */
- (void)unarchiveThreadWithTransaction:(SDSAnyWriteTransaction *)transaction;

- (void)removeAllThreadInteractionsWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;


#pragma mark Disappearing Messages

- (OWSDisappearingMessagesConfiguration *)disappearingMessagesConfigurationWithTransaction:
    (YapDatabaseReadTransaction *)transaction;
- (uint32_t)disappearingMessagesDurationWithTransaction:(YapDatabaseReadTransaction *)transaction;

#pragma mark Drafts

/**
 *  Returns the last known draft for that thread. Always returns a string. Empty string if nil.
 *
 *  @param transaction Database transaction.
 *
 *  @return Last known draft for that thread.
 */
- (NSString *)currentDraftWithTransaction:(YapDatabaseReadTransaction *)transaction;

/**
 *  Sets the draft of a thread. Typically called when leaving a conversation view.
 *
 *  @param draftString Draft string to be saved.
 *  @param transaction Database transaction.
 */
- (void)updateWithDraft:(NSString *)draftString transaction:(SDSAnyWriteTransaction *)transaction;

@property (atomic, readonly) BOOL isMuted;
@property (atomic, readonly, nullable) NSDate *mutedUntilDate;

#pragma mark - Update With... Methods

- (void)updateWithMutedUntilDate:(NSDate *)mutedUntilDate transaction:(YapDatabaseReadWriteTransaction *)transaction;

+ (BOOL)shouldInteractionAppearInInbox:(TSInteraction *)interaction;

@end

NS_ASSUME_NONNULL_END
