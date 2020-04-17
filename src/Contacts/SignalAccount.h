//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "TSYapDatabaseObject.h"

NS_ASSUME_NONNULL_BEGIN

@class Contact;
@class SignalRecipient;
@class YapDatabaseReadTransaction;

// This class represents a single valid Signal account.
//
// * Contacts with multiple signal accounts will correspond to
//   multiple instances of SignalAccount.
// * For non-contacts, the contact property will be nil.
@interface SignalAccount : TSYapDatabaseObject

// An E164 value identifying the signal account.
//
// This is the key property of this class and it
// will always be non-null.
@property (nonatomic, readonly) NSString *recipientId;

// This property is optional and will not be set for
// non-contact account.
@property (nonatomic, nullable) Contact *contact;

@property (nonatomic) BOOL hasMultipleAccountContact;

// For contacts with more than one signal account,
// this is a label for the account.
@property (nonatomic) NSString *multipleAccountLabelText;

- (nullable NSString *)contactFullName;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSignalRecipient:(SignalRecipient *)signalRecipient;

- (instancetype)initWithRecipientId:(NSString *)recipientId;

+ (SignalAccount *)makeRobotAccount;

+ (SignalAccount *)makeWalletAccount;

+ (SignalAccount *)makeTradeAccount;

+ (SignalAccount *)makeMallAccount;

- (BOOL)isRobot;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithUniqueId:(NSString *)uniqueId
                         contact:(nullable Contact *)contact
       hasMultipleAccountContact:(BOOL)hasMultipleAccountContact
        multipleAccountLabelText:(NSString *)multipleAccountLabelText
                     recipientId:(NSString *)recipientId
NS_SWIFT_NAME(init(uniqueId:contact:hasMultipleAccountContact:multipleAccountLabelText:recipientId:));

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END
