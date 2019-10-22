//
//  SFImagePickerDelegate.m
//  SmartFridge
//
//  Created by 黃彥翔 on 2019/10/21.
//  Copyright © 2019 黃彥翔. All rights reserved.
//

#import "SFImagePickerDelegate.h"

@interface SFImagePickerDelegate ()

@property (nonatomic) NSString *host;

@end

@implementation SFImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self uploadImage:image completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // NSLog(@"%@", response);
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - Private

- (void)uploadImage:(UIImage *)image
  completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    NSURLRequest *request = [self uploadImageRequest:image];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}

- (NSURLRequest *)uploadImageRequest:(UIImage *)image {
    NSData *dataImage = UIImageJPEGRepresentation(image, 1.0f);
    NSString *urlString = [self URLPath:@"upload"];

    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---SmartFridge---";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:dataImage]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    return request;
}

- (NSString *)URLPath:(NSString *)path {
    if (!self.host) {
        self.host = [[NSUserDefaults standardUserDefaults] stringForKey:@"server_ip"];
    }
    return [NSString stringWithFormat:@"http://%@/%@", self.host, path];
}

@end
