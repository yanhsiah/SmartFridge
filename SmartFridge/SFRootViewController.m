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

// https://github.com/socketio/socket.io-client-swift
@import SocketIO;

@interface SFRootViewController ()

@property (nonatomic) SFImagePickerController *camera;
@property (nonatomic) SFImagePickerDelegate *cameraDelegate;

@property (nonatomic) SocketManager *socketManager;

@end

@implementation SFRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupCamera];
    [self setupSocketManager];

    UIButton *snapshotBtn = [[UIButton alloc] init];
    [snapshotBtn addTarget:self action:@selector(snapshot) forControlEvents:UIControlEventTouchUpInside];
    [snapshotBtn setTitle:@"Snapshot" forState:UIControlStateNormal];
    [self.view addSubview:snapshotBtn];
    snapshotBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:snapshotBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:snapshotBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
    ]];
}

#pragma mark - Priavet methods

- (void)setupCamera {
    if (!self.camera) {
        self.cameraDelegate = [[SFImagePickerDelegate alloc] init];
        self.camera = [[SFImagePickerController alloc] init];
        self.camera.delegate = self.cameraDelegate;
    }
}

- (void)snapshot {
    __weak typeof(self) weakSelf = self;
    [weakSelf presentViewController:weakSelf.camera animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.camera takePicture];
        });
    }];
}

- (void)setupSocketManager {
    if (!self.socketManager) {
        NSURL* url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"server_ip"]]];
        self.socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @YES, @"compress": @YES}];
        SocketIOClient *socket = self.socketManager.defaultSocket;
        __weak typeof (self) weakSelf = self;
        [socket on:@"snapshot" callback:^(NSArray* data, SocketAckEmitter* ack) {
            [weakSelf snapshot];
        }];
        [socket connect];
    }
}

@end
