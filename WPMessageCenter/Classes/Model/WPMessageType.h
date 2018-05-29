//
//  WPMessageType.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/29.
//

#ifndef WPMessageType_h
#define WPMessageType_h


/**
 消息类型
 - WPMessageTypeUnknown: 未知类型
 - WPMessageTypeText: 文本消息
 - WPMessageTypeImage: 图片下次
 */
typedef NS_ENUM(NSInteger, WPMessageType) {
    WPMessageTypeUnknown,
    WPMessageTypeText,
    WPMessageTypeImage
};


#endif /* WPMessageType_h */
