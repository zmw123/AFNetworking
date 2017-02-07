// UIWebView+CCAFNetworking.m
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

#import "UIWebView+CCAFNetworking.h"

#import <objc/runtime.h>

#if TARGET_OS_IOS

#import "CCAFHTTPSessionManager.h"
#import "CCAFURLResponseSerialization.h"
#import "CCAFURLRequestSerialization.h"

@interface UIWebView (_CCAFNetworking)
@property (readwrite, nonatomic, strong, setter = CCAF_setURLSessionTask:) NSURLSessionDataTask *CCAF_URLSessionTask;
@end

@implementation UIWebView (_CCAFNetworking)

- (NSURLSessionDataTask *)CCAF_URLSessionTask {
    return (NSURLSessionDataTask *)objc_getAssociatedObject(self, @selector(CCAF_URLSessionTask));
}

- (void)CCAF_setURLSessionTask:(NSURLSessionDataTask *)CCAF_URLSessionTask {
    objc_setAssociatedObject(self, @selector(CCAF_URLSessionTask), CCAF_URLSessionTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIWebView (CCAFNetworking)

- (CCAFHTTPSessionManager  *)sessionManager {
    static CCAFHTTPSessionManager *_CCAF_defaultHTTPSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _CCAF_defaultHTTPSessionManager = [[CCAFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _CCAF_defaultHTTPSessionManager.requestSerializer = [CCAFHTTPRequestSerializer serializer];
        _CCAF_defaultHTTPSessionManager.responseSerializer = [CCAFHTTPResponseSerializer serializer];
    });

    return objc_getAssociatedObject(self, @selector(sessionManager)) ?: _CCAF_defaultHTTPSessionManager;
}

- (void)setSessionManager:(CCAFHTTPSessionManager *)sessionManager {
    objc_setAssociatedObject(self, @selector(sessionManager), sessionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCAFHTTPResponseSerializer <CCAFURLResponseSerialization> *)responseSerializer {
    static CCAFHTTPResponseSerializer <CCAFURLResponseSerialization> *_CCAF_defaultResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _CCAF_defaultResponseSerializer = [CCAFHTTPResponseSerializer serializer];
    });

    return objc_getAssociatedObject(self, @selector(responseSerializer)) ?: _CCAF_defaultResponseSerializer;
}

- (void)setResponseSerializer:(CCAFHTTPResponseSerializer<CCAFURLResponseSerialization> *)responseSerializer {
    objc_setAssociatedObject(self, @selector(responseSerializer), responseSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)loadRequest:(NSURLRequest *)request
           progress:(NSProgress * _Nullable __autoreleasing * _Nullable)progress
            success:(NSString * (^)(NSHTTPURLResponse *response, NSString *HTML))success
            failure:(void (^)(NSError *error))failure
{
    [self loadRequest:request MIMEType:nil textEncodingName:nil progress:progress success:^NSData *(NSHTTPURLResponse *response, NSData *data) {
        NSStringEncoding stringEncoding = NSUTF8StringEncoding;
        if (response.textEncodingName) {
            CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
            if (encoding != kCFStringEncodingInvalidId) {
                stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
            }
        }

        NSString *string = [[NSString alloc] initWithData:data encoding:stringEncoding];
        if (success) {
            string = success(response, string);
        }

        return [string dataUsingEncoding:stringEncoding];
    } failure:failure];
}

- (void)loadRequest:(NSURLRequest *)request
           MIMEType:(NSString *)MIMEType
   textEncodingName:(NSString *)textEncodingName
           progress:(NSProgress * _Nullable __autoreleasing * _Nullable)progress
            success:(NSData * (^)(NSHTTPURLResponse *response, NSData *data))success
            failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(request);

    if (self.CCAF_URLSessionTask.state == NSURLSessionTaskStateRunning || self.CCAF_URLSessionTask.state == NSURLSessionTaskStateSuspended) {
        [self.CCAF_URLSessionTask cancel];
    }
    self.CCAF_URLSessionTask = nil;

    __weak __typeof(self)weakSelf = self;
    __block NSURLSessionDataTask *dataTask;
    dataTask = [self.sessionManager
                dataTaskWithRequest:request
                uploadProgress:nil
                downloadProgress:nil
                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nullable error) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    if (error) {
                        if (failure) {
                            failure(error);
                        }
                    } else {
                        if (success) {
                            success((NSHTTPURLResponse *)response, responseObject);
                        }
                        [strongSelf loadData:responseObject MIMEType:MIMEType textEncodingName:textEncodingName baseURL:[dataTask.currentRequest URL]];

                        if ([strongSelf.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
                            [strongSelf.delegate webViewDidFinishLoad:strongSelf];
                        }
                    }
                }];
    self.CCAF_URLSessionTask = dataTask;
    if (progress != nil) {
        *progress = [self.sessionManager downloadProgressForTask:dataTask];
    }
    [self.CCAF_URLSessionTask resume];

    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

@end

#endif
