// CCAFTestCase.m
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

#import "CCAFTestCase.h"

@implementation CCAFTestCase

- (void)setUp {
    [super setUp];
    self.networkTimeout = 20.0;
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark -

- (NSURL *)baseURL {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    return [NSURL URLWithString:environment[@"HTTPBIN_BASE_URL"] ?: @"https://httpbin.org"];
}

- (NSURL *)pngURL {
    return [self.baseURL URLByAppendingPathComponent:@"image/png"];
}

- (NSURL *)jpegURL {
    return [self.baseURL URLByAppendingPathComponent:@"image/jpeg"];
}

- (NSURL *)delayURL {
    return [self.baseURL URLByAppendingPathComponent:@"delay/1"];
}

- (NSURL *)URLWithStatusCode:(NSInteger)statusCode {
    return [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"status/%@", @(statusCode)]];
}

- (void)waitForExpectationsWithCommonTimeout {
    [self waitForExpectationsWithCommonTimeoutUsingHandler:nil];
}

- (void)waitForExpectationsWithCommonTimeoutUsingHandler:(XCWaitCompletionHandler)handler {
    [self waitForExpectationsWithTimeout:self.networkTimeout handler:handler];
}

@end
