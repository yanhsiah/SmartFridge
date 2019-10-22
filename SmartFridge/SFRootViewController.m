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

@interface SFRootViewController ()

@property (nonatomic) SFImagePickerController *camera;
@property (nonatomic) SFImagePickerDelegate *cameraDelegate;

@end

@implementation SFRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

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

- (void)snapshot {
    __weak typeof(self) weakSelf = self;
    [weakSelf presentViewController:weakSelf.camera animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.camera takePicture];
        });
    }];
}

@end
