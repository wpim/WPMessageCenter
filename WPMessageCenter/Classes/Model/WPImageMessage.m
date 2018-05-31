//
//  WPImageMessage.m
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import "WPImageMessage.h"

@implementation WPImageMessage
- (instancetype)init {
    if (self = [super init]) {
        self.type = WPMessageTypeImage;
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date {
    if (self = [super initWithDate:date]) {
        self.type = WPMessageTypeImage;
    }
    return self;
}

-(instancetype)initWithDateNow {
    if (self = [super initWithDateNow]) {
        self.type = WPMessageTypeImage;
    }
    return self;
}
@end
