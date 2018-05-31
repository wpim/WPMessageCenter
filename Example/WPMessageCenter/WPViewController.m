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
    
    self.view.backgroundColor = [UIColor blueColor];
	
    [WPMessageCenter setupSocketWithUid:@"123" params:nil];
    WPMessageCenter *center = [WPMessageCenter sharedCenter];
    [center addObserver:self];
    [center connect];
    
    [[WPMessageCenter sharedCenter] sendText:@"123" toUid:@"456"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WPMessageObserver
- (void)didConnectServer {
    
}

- (void)didCloseServer {
    
}

- (void)didReceiveMessage:(WPMessageEntity *)message {
    NSLog(@"%@", message);
    [[WPMessageCenter sharedCenter] sendText:@"234" toUid:@"344"];
}
@end
