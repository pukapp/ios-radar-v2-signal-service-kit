//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "SDSCrossProcess.h"
#import <SignalCoreKit/OWSAsserts.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <notify.h>

NS_ASSUME_NONNULL_BEGIN

// NOTE: CFNotificationCenterGetDarwinNotifyCenter() might offer a better / equivalent solution,
//       but it wasn't working for me and so I moved on.

pid_t localPid(void)
{
    static dispatch_once_t onceToken;
    static pid_t pid;
    dispatch_once(&onceToken, ^{
        pid = getpid();
    });
    return pid;
}

#pragma mark -

@interface SDSCrossProcess ()

@property (nonatomic) int notifyToken;

@end

#pragma mark -

@implementation SDSCrossProcess

- (id)init
{
    if (self = [super init]) {
        self.notifyToken = DarwinNotificationInvalidObserver;

        [self start];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
}

- (void)start
{
    [self stop];

    __weak SDSCrossProcess *weakSelf = self;
    self.notifyToken = [DarwinNotificationCenter addObserverForName:DarwinNotificationName.sdsCrossProcess
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(int token) {
                                                             [weakSelf handleNotification:token];
                                                         }];
//    const char *name = [[self notificationName] cStringUsingEncoding:NSUTF8StringEncoding];
//    int notifyToken;
//    notify_register_dispatch(name, &notifyToken, dispatch_get_main_queue(), ^(int token) {
//        [weakSelf handleNotification:token];
//    });
//    self.notifyToken = notifyToken;
}

- (void)handleNotification:(int)token
{
    OWSAssertIsOnMainThread();

//    uint64_t fromPid;
//    // notify_get_state() & notify_set_state() are vulnerable to races.
//    notify_get_state(token, &fromPid);
//    BOOL isLocal = fromPid == (uint64_t)localPid();
//    if (isLocal) {
//        return;
//    }
    uint64_t fromPid = [DarwinNotificationCenter getStateForObserver:token];
    BOOL isLocal = fromPid == (uint64_t)localPid();
    if (isLocal) {
        return;
    }

    OWSLogVerbose(@"Cross process write from %llu", fromPid);
    if (self.callback) {
        self.callback();
    }
}

- (void)stop
{
    if ([DarwinNotificationCenter isValidObserver:self.notifyToken]) {
        [DarwinNotificationCenter removeObserver:self.notifyToken];
    }
    self.notifyToken = DarwinNotificationInvalidObserver;

//    if (!notify_is_valid_token(self.notifyToken)) {
//        return;
//    }
//
//    notify_cancel(self.notifyToken);
//    self.notifyToken = NOTIFY_TOKEN_INVALID;
}

- (void)notifyChanged
{
    OWSAssertIsOnMainThread();

    dispatch_async(dispatch_get_main_queue(), ^{
        if (![DarwinNotificationCenter isValidObserver:self.notifyToken]) {
            [self start];
        }
        [DarwinNotificationCenter setState:localPid() forObserver:self.notifyToken];
        [DarwinNotificationCenter postNotificationName:DarwinNotificationName.sdsCrossProcess];
        
    });
}
    
//    if (!notify_is_valid_token(self.notifyToken)) {
//        [self start];
//    }
//
//    const char *name = [[self notificationName] cStringUsingEncoding:NSUTF8StringEncoding];
//    // notify_get_state() & notify_set_state() are vulnerable to races.
//    notify_set_state(self.notifyToken, localPid());
//    notify_post(name);


- (NSString *)notificationName
{
    return @"org.radar.sdscrossprocess";
}

@end

NS_ASSUME_NONNULL_END
