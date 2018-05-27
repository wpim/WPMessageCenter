//
//  WPViewController.m
//  WPMessageCenter
//
//  Created by gwpp on 05/26/2018.
//  Copyright (c) 2018 gwpp. All rights reserved.
//

#import "WPViewController.h"
#import <WPMessageCenter/WPMessageCenter.h>

@interface WPViewController ()<WPMessageObserver>

@end

@implementation WPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    WPMessageCenter *center = [WPMessageCenter sharedCenter];
    [center addObserver:self];
    [center connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WPMessageObserver
- (void)didConnectServer {
    WPTextMessage *msg = [[WPTextMessage alloc] init];
    msg.text = @"123";
    [[WPMessageCenter sharedCenter] sendMessage:msg];
}

- (void)didCloseServer {
    
}

- (void)didReceiveMessage:(WPMessage *)message {
    
}
@end
