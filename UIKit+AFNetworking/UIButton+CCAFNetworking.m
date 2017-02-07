// UIButton+CCAFNetworking.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIButton+CCAFNetworking.h"

#import <objc/runtime.h>

#if TARGET_OS_IOS || TARGET_OS_TV

#import "UIImageView+CCAFNetworking.h"
#import "CCAFImageDownloader.h"

@interface UIButton (_CCAFNetworking)
@end

@implementation UIButton (_CCAFNetworking)

#pragma mark -

static char CCAFImageDownloadReceiptNormal;
static char CCAFImageDownloadReceiptHighlighted;
static char CCAFImageDownloadReceiptSelected;
static char CCAFImageDownloadReceiptDisabled;

static const char * CCAF_imageDownloadReceiptKeyForState(UIControlState state) {
    switch (state) {
        case UIControlStateHighlighted:
            return &CCAFImageDownloadReceiptHighlighted;
        case UIControlStateSelected:
            return &CCAFImageDownloadReceiptSelected;
        case UIControlStateDisabled:
            return &CCAFImageDownloadReceiptDisabled;
        case UIControlStateNormal:
        default:
            return &CCAFImageDownloadReceiptNormal;
    }
}

- (CCAFImageDownloadReceipt *)CCAF_imageDownloadReceiptForState:(UIControlState)state {
    return (CCAFImageDownloadReceipt *)objc_getAssociatedObject(self, CCAF_imageDownloadReceiptKeyForState(state));
}

- (void)CCAF_setImageDownloadReceipt:(CCAFImageDownloadReceipt *)imageDownloadReceipt
                           forState:(UIControlState)state
{
    objc_setAssociatedObject(self, CCAF_imageDownloadReceiptKeyForState(state), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

static char CCAFBackgroundImageDownloadReceiptNormal;
static char CCAFBackgroundImageDownloadReceiptHighlighted;
static char CCAFBackgroundImageDownloadReceiptSelected;
static char CCAFBackgroundImageDownloadReceiptDisabled;

static const char * CCAF_backgroundImageDownloadReceiptKeyForState(UIControlState state) {
    switch (state) {
        case UIControlStateHighlighted:
            return &CCAFBackgroundImageDownloadReceiptHighlighted;
        case UIControlStateSelected:
            return &CCAFBackgroundImageDownloadReceiptSelected;
        case UIControlStateDisabled:
            return &CCAFBackgroundImageDownloadReceiptDisabled;
        case UIControlStateNormal:
        default:
            return &CCAFBackgroundImageDownloadReceiptNormal;
    }
}

- (CCAFImageDownloadReceipt *)CCAF_backgroundImageDownloadReceiptForState:(UIControlState)state {
    return (CCAFImageDownloadReceipt *)objc_getAssociatedObject(self, CCAF_backgroundImageDownloadReceiptKeyForState(state));
}

- (void)CCAF_setBackgroundImageDownloadReceipt:(CCAFImageDownloadReceipt *)imageDownloadReceipt
                                     forState:(UIControlState)state
{
    objc_setAssociatedObject(self, CCAF_backgroundImageDownloadReceiptKeyForState(state), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIButton (CCAFNetworking)

+ (CCAFImageDownloader *)sharedImageDownloader {

    return objc_getAssociatedObject(self, @selector(sharedImageDownloader)) ?: [CCAFImageDownloader defaultInstance];
}

+ (void)setSharedImageDownloader:(CCAFImageDownloader *)imageDownloader {
    objc_setAssociatedObject(self, @selector(sharedImageDownloader), imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)setImageForState:(UIControlState)state
                 withURL:(NSURL *)url
{
    [self setImageForState:state withURL:url placeholderImage:nil];
}

- (void)setImageForState:(UIControlState)state
                 withURL:(NSURL *)url
        placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageForState:state withURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageForState:(UIControlState)state
          withURLRequest:(NSURLRequest *)urlRequest
        placeholderImage:(nullable UIImage *)placeholderImage
                 success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                 failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{
    if ([self isActiveTaskURLEqualToURLRequest:urlRequest forState:state]) {
        return;
    }

    [self cancelImageDownloadTaskForState:state];

    CCAFImageDownloader *downloader = [[self class] sharedImageDownloader];
    id <CCAFImageRequestCache> imageCache = downloader.imageCache;

    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache imageforRequest:urlRequest withAdditionalIdentifier:nil];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            [self setImage:cachedImage forState:state];
        }
        [self CCAF_setImageDownloadReceipt:nil forState:state];
    } else {
        if (placeholderImage) {
            [self setImage:placeholderImage forState:state];
        }

        __weak __typeof(self)weakSelf = self;
        NSUUID *downloadID = [NSUUID UUID];
        CCAFImageDownloadReceipt *receipt;
        receipt = [downloader
                   downloadImageForURLRequest:urlRequest
                   withReceiptID:downloadID
                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf CCAF_imageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (success) {
                               success(request, response, responseObject);
                           } else if(responseObject) {
                               [strongSelf setImage:responseObject forState:state];
                           }
                           [strongSelf CCAF_setImageDownloadReceipt:nil forState:state];
                       }

                   }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf CCAF_imageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (failure) {
                               failure(request, response, error);
                           }
                           [strongSelf  CCAF_setImageDownloadReceipt:nil forState:state];
                       }
                   }];

        [self CCAF_setImageDownloadReceipt:receipt forState:state];
    }
}

#pragma mark -

- (void)setBackgroundImageForState:(UIControlState)state
                           withURL:(NSURL *)url
{
    [self setBackgroundImageForState:state withURL:url placeholderImage:nil];
}

- (void)setBackgroundImageForState:(UIControlState)state
                           withURL:(NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setBackgroundImageForState:state withURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setBackgroundImageForState:(UIControlState)state
                    withURLRequest:(NSURLRequest *)urlRequest
                  placeholderImage:(nullable UIImage *)placeholderImage
                           success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                           failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{
    if ([self isActiveBackgroundTaskURLEqualToURLRequest:urlRequest forState:state]) {
        return;
    }

    [self cancelBackgroundImageDownloadTaskForState:state];

    CCAFImageDownloader *downloader = [[self class] sharedImageDownloader];
    id <CCAFImageRequestCache> imageCache = downloader.imageCache;

    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache imageforRequest:urlRequest withAdditionalIdentifier:nil];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            [self setBackgroundImage:cachedImage forState:state];
        }
        [self CCAF_setBackgroundImageDownloadReceipt:nil forState:state];
    } else {
        if (placeholderImage) {
            [self setBackgroundImage:placeholderImage forState:state];
        }

        __weak __typeof(self)weakSelf = self;
        NSUUID *downloadID = [NSUUID UUID];
        CCAFImageDownloadReceipt *receipt;
        receipt = [downloader
                   downloadImageForURLRequest:urlRequest
                   withReceiptID:downloadID
                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf CCAF_backgroundImageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (success) {
                               success(request, response, responseObject);
                           } else if(responseObject) {
                               [strongSelf setBackgroundImage:responseObject forState:state];
                           }
                           [strongSelf CCAF_setBackgroundImageDownloadReceipt:nil forState:state];
                       }

                   }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf CCAF_backgroundImageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (failure) {
                               failure(request, response, error);
                           }
                           [strongSelf  CCAF_setBackgroundImageDownloadReceipt:nil forState:state];
                       }
                   }];

        [self CCAF_setBackgroundImageDownloadReceipt:receipt forState:state];
    }
}

#pragma mark -

- (void)cancelImageDownloadTaskForState:(UIControlState)state {
    CCAFImageDownloadReceipt *receipt = [self CCAF_imageDownloadReceiptForState:state];
    if (receipt != nil) {
        [[self.class sharedImageDownloader] cancelTaskForImageDownloadReceipt:receipt];
        [self CCAF_setImageDownloadReceipt:nil forState:state];
    }
}

- (void)cancelBackgroundImageDownloadTaskForState:(UIControlState)state {
    CCAFImageDownloadReceipt *receipt = [self CCAF_backgroundImageDownloadReceiptForState:state];
    if (receipt != nil) {
        [[self.class sharedImageDownloader] cancelTaskForImageDownloadReceipt:receipt];
        [self CCAF_setBackgroundImageDownloadReceipt:nil forState:state];
    }
}

- (BOOL)isActiveTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest forState:(UIControlState)state {
    CCAFImageDownloadReceipt *receipt = [self CCAF_imageDownloadReceiptForState:state];
    return [receipt.task.originalRequest.URL.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}

- (BOOL)isActiveBackgroundTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest forState:(UIControlState)state {
    CCAFImageDownloadReceipt *receipt = [self CCAF_backgroundImageDownloadReceiptForState:state];
    return [receipt.task.originalRequest.URL.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}


@end

#endif
