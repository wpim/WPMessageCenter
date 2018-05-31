//
//  WPTextMessage.m
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import "WPTextMessage.h"

@implementation WPTextMessage
- (instancetype)init {
    if (self = [super init]) {
        self.type = WPMessageTypeText;
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date {
    if (self = [super initWithDate:date]) {
        self.type = WPMessageTypeText;
    }
    return self;
}

-(instancetype)initWithDateNow {
    if (self = [super initWithDateNow]) {
        self.type = WPMessageTypeText;
    }
    return self;
}
@end
