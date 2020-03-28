//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "TSTrainerThread.h"

NSString *const TSTrainerThreadPrefix = @"t";

@implementation TSTrainerThread

- (instancetype)initWithContactId:(NSString *)contactId
{
    NSString *uniqueIdentifier = [TSTrainerThreadPrefix stringByAppendingString:contactId];
    
    OWSAssertDebug(contactId.length > 0);
    self = [super initWithUniqueId:uniqueIdentifier];
    
    return self;
}

- (NSString *)name
{
    return @"训练对话";
//    return [SSKEnvironment.shared.contactsManager displayNameForPhoneIdentifier:self.contactIdentifier];
}

@end
