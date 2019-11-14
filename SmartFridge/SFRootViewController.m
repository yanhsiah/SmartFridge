//
//  SFRootViewController.m
//  SmartFridge
//
//  Created by 黃彥翔 on 2019/10/21.
//  Copyright © 2019 黃彥翔. All rights reserved.
//

#import "SFRootViewController.h"
#import "SFImagePickerController.h"
#import "SFImagePickerDelegate.h"

@import SocketIO;

@interface SFRootViewController ()

@property (nonatomic) SFImagePickerController *camera;
@property (nonatomic) SFImagePickerDelegate *cameraDelegate;

@end

@implementation SFRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // [self setupSocketConnections];

    if (!self.camera) {
        self.cameraDelegate = [[SFImagePickerDelegate alloc] init];
        self.camera = [[SFImagePickerController alloc] init];
        self.camera.delegate = self.cameraDelegate;
    }

    UIButton *photoButton = [[UIButton alloc] init];
    [photoButton addTarget:self action:@selector(snapshot) forControlEvents:UIControlEventTouchUpInside];
    [photoButton setTitle:@"Snapshot" forState:UIControlStateNormal];
    photoButton.frame = CGRectMake(0, 0, 160.0, 40.0);
    [self.view addSubview:photoButton];
    photoButton.center = self.view.center;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Priavet methods

- (void)snapshot {
    __weak typeof(self) weakSelf = self;
    [weakSelf presentViewController:weakSelf.camera animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.camera takePicture];
        });
    }];
}

- (void)setupSocketConnections {
    NSURL* url = [[NSURL alloc] initWithString:@"http://192.168.0.24:3000"];
    SocketManager* manager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @YES, @"compress": @YES}];
    SocketIOClient* socket = manager.defaultSocket;

    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
    }];

    [socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
        double cur = [[data objectAtIndex:0] floatValue];

        [[socket emitWithAck:@"canUpdate" with:@[@(cur)]] timingOutAfter:0 callback:^(NSArray* data) {
            [socket emit:@"update" with:@[@{@"amount": @(cur + 2.50)}]];
        }];

        [ack with:@[@"Got your currentAmount, ", @"dude"]];
    }];
    
    [socket on:@"welcome" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"welcome from server!~");
    }];
    [socket on:@"upload" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"welcome from server!~");
    }];

    [socket connect];
}

#pragma mark - <>


@end
