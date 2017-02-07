// CCAFNetworking.h
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

#import <Foundation/Foundation.h>

//! Project version number for CCAFNetworking.
FOUNDATION_EXPORT double CCAFNetworkingVersionNumber;

//! Project version string for CCAFNetworking.
FOUNDATION_EXPORT const unsigned char CCAFNetworkingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CCAFNetworking/PublicHeader.h>

#import <Availability.h>
#import <TargetConditionals.h>

#ifndef _CCAFNETWORKING_
#define _CCAFNETWORKING_

#import <CCAFNetworking/CCAFURLRequestSerialization.h>
#import <CCAFNetworking/CCAFURLResponseSerialization.h>
#import <CCAFNetworking/CCAFSecurityPolicy.h>

#if !TARGET_OS_WATCH
#import <CCAFNetworking/CCAFNetworkReachabilityManager.h>
#endif

#import <CCAFNetworking/CCAFURLSessionManager.h>
#import <CCAFNetworking/CCAFHTTPSessionManager.h>

#if TARGET_OS_IOS || TARGET_OS_TV
#import <CCAFNetworking/CCAFAutoPurgingImageCache.h>
#import <CCAFNetworking/CCAFImageDownloader.h>
#import <CCAFNetworking/UIActivityIndicatorView+CCAFNetworking.h>
#import <CCAFNetworking/UIButton+CCAFNetworking.h>
#import <CCAFNetworking/UIImage+CCAFNetworking.h>
#import <CCAFNetworking/UIImageView+CCAFNetworking.h>
#import <CCAFNetworking/UIProgressView+CCAFNetworking.h>
#endif

#if TARGET_OS_IOS
#import <CCAFNetworking/CCAFNetworkActivityIndicatorManager.h>
#import <CCAFNetworking/UIRefreshControl+CCAFNetworking.h>
#import <CCAFNetworking/UIWebView+CCAFNetworking.h>
#endif


#endif /* _CCAFNETWORKING_ */
