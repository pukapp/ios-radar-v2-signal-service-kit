//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSSyncManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class ContactsUpdater;
@class MessageSenderJobQueue;
@class OWS2FAManager;
@class OWSAttachmentDownloads;
@class OWSBatchMessageProcessor;
@class OWSBlockingManager;
@class OWSDisappearingMessagesJob;
@class OWSIdentityManager;
@class OWSLinkPreviewManager;
@class OWSMessageDecrypter;
@class OWSMessageManager;
@class OWSMessageReceiver;
@class OWSMessageSender;
@class OWSOutgoingReceiptManager;
@class OWSPrimaryStorage;
@class OWSReadReceiptManager;
@class SDSDatabaseStorage;
@class SSKPreKeyStore;
@class SSKSessionStore;
@class SSKSignedPreKeyStore;
@class StickerManager;
@class TSAccountManager;
@class TSNetworkManager;
@class TSSocketManager;
@class YapDatabaseConnection;
@class MessageFetcherJob;
@class MessageProcessing;
@class StorageCoordinator;


@protocol ContactsManagerProtocol;
@protocol NotificationsProtocol;
@protocol OWSCallMessageHandler;
@protocol ProfileManagerProtocol;
@protocol OWSUDManager;
@protocol SSKReachabilityManager;
@protocol OWSSyncManagerProtocol;
@protocol OWSTypingIndicators;

@interface SSKEnvironment : NSObject

- (instancetype)initWithContactsManager:(id<ContactsManagerProtocol>)contactsManager
                     linkPreviewManager:(OWSLinkPreviewManager *)linkPreviewManager
                          messageSender:(OWSMessageSender *)messageSender
                  messageSenderJobQueue:(MessageSenderJobQueue *)messageSenderJobQueue
                         profileManager:(id<ProfileManagerProtocol>)profileManager
                         primaryStorage:(OWSPrimaryStorage *)primaryStorage
                        contactsUpdater:(ContactsUpdater *)contactsUpdater
                         networkManager:(TSNetworkManager *)networkManager
                         messageManager:(OWSMessageManager *)messageManager
                        blockingManager:(OWSBlockingManager *)blockingManager
                        identityManager:(OWSIdentityManager *)identityManager
                           sessionStore:(SSKSessionStore *)sessionStore
                      signedPreKeyStore:(SSKSignedPreKeyStore *)signedPreKeyStore
                            preKeyStore:(SSKPreKeyStore *)preKeyStore
                              udManager:(id<OWSUDManager>)udManager
                       messageDecrypter:(OWSMessageDecrypter *)messageDecrypter
                  batchMessageProcessor:(OWSBatchMessageProcessor *)batchMessageProcessor
                        messageReceiver:(OWSMessageReceiver *)messageReceiver
                          socketManager:(TSSocketManager *)socketManager
                       tsAccountManager:(TSAccountManager *)tsAccountManager
                          ows2FAManager:(OWS2FAManager *)ows2FAManager
                disappearingMessagesJob:(OWSDisappearingMessagesJob *)disappearingMessagesJob
                     readReceiptManager:(OWSReadReceiptManager *)readReceiptManager
                 outgoingReceiptManager:(OWSOutgoingReceiptManager *)outgoingReceiptManager
                    reachabilityManager:(id<SSKReachabilityManager>)reachabilityManager
                            syncManager:(id<OWSSyncManagerProtocol>)syncManager
                       typingIndicators:(id<OWSTypingIndicators>)typingIndicators
                    attachmentDownloads:(OWSAttachmentDownloads *)attachmentDownloads
                         stickerManager:(StickerManager *)stickerManager
                      messageProcessing:(MessageProcessing *)messageProcessing
                      messageFetcherJob:(MessageFetcherJob *)messageFetcherJob
                     storageCoordinator:(StorageCoordinator *)storageCoordinator
                        databaseStorage:(SDSDatabaseStorage *)databaseStorage NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly, class) SSKEnvironment *shared;

+ (void)setShared:(SSKEnvironment *)env;

#ifdef DEBUG
// Should only be called by tests.
+ (void)clearSharedForTests;
#endif

+ (BOOL)hasShared;


@property (nonatomic, readonly) id<ContactsManagerProtocol> contactsManager;
@property (nonatomic, readonly) OWSLinkPreviewManager *linkPreviewManager;
@property (nonatomic, readonly) OWSMessageSender *messageSender;
@property (nonatomic, readonly) MessageSenderJobQueue *messageSenderJobQueue;
@property (nonatomic, readonly) id<ProfileManagerProtocol> profileManager;
@property (nonatomic, readonly) OWSPrimaryStorage *primaryStorage;
@property (nonatomic, readonly) ContactsUpdater *contactsUpdater;
@property (nonatomic, readonly) TSNetworkManager *networkManager;
@property (nonatomic, readonly) OWSMessageManager *messageManager;
@property (nonatomic, readonly) OWSBlockingManager *blockingManager;
@property (nonatomic, readonly) OWSIdentityManager *identityManager;
@property (nonatomic, readonly) SSKSessionStore *sessionStore;
@property (nonatomic, readonly) SSKSignedPreKeyStore *signedPreKeyStore;
@property (nonatomic, readonly) SSKPreKeyStore *preKeyStore;
@property (nonatomic, readonly) id<OWSUDManager> udManager;
@property (nonatomic, readonly) OWSMessageDecrypter *messageDecrypter;
@property (nonatomic, readonly) OWSBatchMessageProcessor *batchMessageProcessor;
@property (nonatomic, readonly) OWSMessageReceiver *messageReceiver;
@property (nonatomic, readonly) TSSocketManager *socketManager;
@property (nonatomic, readonly) TSAccountManager *tsAccountManager;
@property (nonatomic, readonly) OWS2FAManager *ows2FAManager;
@property (nonatomic, readonly) OWSDisappearingMessagesJob *disappearingMessagesJob;
@property (nonatomic, readonly) OWSReadReceiptManager *readReceiptManager;
@property (nonatomic, readonly) OWSOutgoingReceiptManager *outgoingReceiptManager;
@property (nonatomic, readonly) id<OWSSyncManagerProtocol> syncManager;
@property (nonatomic, readonly) id<SSKReachabilityManager> reachabilityManager;
@property (nonatomic, readonly) id<OWSTypingIndicators> typingIndicators;
@property (nonatomic, readonly) OWSAttachmentDownloads *attachmentDownloads;
@property (nonatomic, readonly) MessageFetcherJob *messageFetcherJob;
@property (nonatomic, readonly) MessageProcessing *messageProcessing;


@property (nonatomic, readonly) StickerManager *stickerManager;
@property (nonatomic, readonly) SDSDatabaseStorage *databaseStorage;

// This property is configured after Environment is created.
@property (atomic, nullable) id<OWSCallMessageHandler> callMessageHandler;
// This property is configured after Environment is created.
@property (atomic) id<NotificationsProtocol> notificationsManager;

@property (atomic, readonly) YapDatabaseConnection *objectReadWriteConnection;
@property (atomic, readonly) YapDatabaseConnection *migrationDBConnection;
@property (atomic, readonly) YapDatabaseConnection *analyticsDBConnection;

@property (nonatomic, readonly) StorageCoordinator *storageCoordinator;


- (BOOL)isComplete;


/// 被训练者 查找当前对话是否有 训练者，若有则表示训练者是连接状态，无则表示训练者已断开
- (NSString *)beTrainerFindTrainerContactIdWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                              andBeTrainerContactId:(NSString *)beTrainerContactId;

/// 被训练者 申请分配训练者成功时，以当前对话信息存储训练者
- (void)beTrainerStoreTrainerContactId:(NSString *)trainerContactId
              withTrainOpenerContactId:(NSString *)trainOpenerContactId
                 andBeTrainerContactId:(NSString *)beTrainerContactId;

/// 被训练者 收到 TRAINER_OFF 的 NOTICE 时，找到当前对话存储的 训练者 然后删除
- (void)beTrainerRemoveTrainerWithTrainOpenerContactId:(NSString *)trainOpenerContactId
                                 andBeTrainerContactId:(NSString *)beTrainerContactId;

/// 存储对我设置了AI的人的AI状态
- (void)storeContactAIState:(BOOL)state withHisContactId:(NSString *)contactId;

/// 获取对我设置了AI的人的AI状态
- (BOOL)findHisContactAIStateWithContactId:(NSString *)contactId;


/// 存储我的AI状态
- (void)storeMyAIState:(BOOL)state withContactId:(NSString *)contactId;

/// 获取我的AI状态
- (BOOL)findMyAIStateWithContactId:(NSString *)contactId;

@end

NS_ASSUME_NONNULL_END
