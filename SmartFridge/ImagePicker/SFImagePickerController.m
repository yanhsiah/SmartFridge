//
//  SFImagePickerController.m
//  SmartFridge
//
//  Created by 黃彥翔 on 2019/10/21.
//  Copyright © 2019 黃彥翔. All rights reserved.
//

#import "SFImagePickerController.h"

@implementation SFImagePickerController

- (instancetype)init {
    if (self = [super init]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.showsCameraControls = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
