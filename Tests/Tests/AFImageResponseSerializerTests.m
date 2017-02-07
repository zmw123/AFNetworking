// CCAFImageResponseSerializerTests.m
// Copyright (c) 2011–2016 Alamofire Software Foundation (http://alamofire.org/)
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

#import <XCTest/XCTest.h>
#import "CCAFTestCase.h"
#import "CCAFURLResponseSerialization.h"

@interface CCAFImageResponseSerializerTests : CCAFTestCase

@end

@implementation CCAFImageResponseSerializerTests

#pragma mark NSCopying

- (void)testImageSerializerCanBeCopied {
    CCAFImageResponseSerializer *responseSerializer = [CCAFImageResponseSerializer serializer];
    [responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"test/type"]];
    [responseSerializer setAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:100]];

    CCAFImageResponseSerializer *copiedSerializer = [responseSerializer copy];
    XCTAssertNotNil(copiedSerializer);
    XCTAssertNotEqual(copiedSerializer, responseSerializer);
    XCTAssertEqual(copiedSerializer.acceptableContentTypes, responseSerializer.acceptableContentTypes);
    XCTAssertEqual(copiedSerializer.acceptableStatusCodes, responseSerializer.acceptableStatusCodes);
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    XCTAssertTrue(copiedSerializer.automaticallyInflatesResponseImage == responseSerializer.automaticallyInflatesResponseImage);
    XCTAssertTrue(fabs(copiedSerializer.imageScale - responseSerializer.imageScale) <= 0.001);
#endif

}

#pragma mark NSSecureCoding

- (void)testImageSerializerSupportsSecureCoding {
    XCTAssertTrue([CCAFImageResponseSerializer supportsSecureCoding]);
}

- (void)testImageSerializerCanBeArchivedAndUnarchived {
    CCAFImageResponseSerializer   *responseSerializer = [CCAFImageResponseSerializer serializer];
    NSData  *archive    = nil;
    
    archive = [NSKeyedArchiver archivedDataWithRootObject:responseSerializer];
    XCTAssertNotNil(archive);
    CCAFImageResponseSerializer *unarchivedSerializer = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    XCTAssertNotNil(unarchivedSerializer);
    XCTAssertNotEqual(unarchivedSerializer, responseSerializer);
    XCTAssertTrue([unarchivedSerializer.acceptableContentTypes isEqualToSet:responseSerializer.acceptableContentTypes]);
    XCTAssertTrue([unarchivedSerializer.acceptableStatusCodes isEqualToIndexSet:responseSerializer.acceptableStatusCodes]);

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    XCTAssertTrue(unarchivedSerializer.automaticallyInflatesResponseImage == responseSerializer.automaticallyInflatesResponseImage);
    XCTAssertTrue(fabs(unarchivedSerializer.imageScale - responseSerializer.imageScale) <= 0.001);
#endif
    
}

- (void)testImageSerializerCanBeArchivedAndUnarchivedWithNonDefaultPropertyValues {
    CCAFImageResponseSerializer   *responseSerializer = [CCAFImageResponseSerializer serializer];
    NSData  *archive    = nil;
    
    // Customize the default property values
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    responseSerializer.automaticallyInflatesResponseImage = !responseSerializer.automaticallyInflatesResponseImage;
    responseSerializer.imageScale = responseSerializer.imageScale * 2.0f;
#endif
    
    archive = [NSKeyedArchiver archivedDataWithRootObject:responseSerializer];
    XCTAssertNotNil(archive);
    CCAFImageResponseSerializer *unarchivedSerializer = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    XCTAssertNotNil(unarchivedSerializer);
    XCTAssertNotEqual(unarchivedSerializer, responseSerializer);

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    XCTAssertTrue(unarchivedSerializer.automaticallyInflatesResponseImage == responseSerializer.automaticallyInflatesResponseImage);
    XCTAssertTrue(fabs(unarchivedSerializer.imageScale - responseSerializer.imageScale) <= 0.001);
#endif
}

@end
