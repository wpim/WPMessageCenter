//
//  WPMessage.m
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import "WPMessage.h"
#import <YYModel/YYModel.h>

@implementation WPMessage
- (NSData *)messageData {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self = [self yy_modelInitWithCoder:aDecoder];
    }
    return self;
}
@end
