//
//  WPMessage.m
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import "WPMessage.h"
#import <YYModel/YYModel.h>

@implementation WPMessage
#pragma mark - init
- (instancetype)initWithDate:(NSDate *)date {
    if (self = [super init]) {
        _timestamp = [date timeIntervalSince1970];
    }
    return self;
}

- (instancetype)initWithDateNow {
    if (self = [super init]) {
        _timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self = [self yy_modelInitWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"ID" : @"id"
             };
}

- (NSString *)description {
    return [self yy_modelDescription];
}
#pragma mark - public
- (NSData *)messageData {
    NSData *json = [self yy_modelToJSONData];
    return json;
}

@end
