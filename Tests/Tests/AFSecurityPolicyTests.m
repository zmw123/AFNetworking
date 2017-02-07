// CCAFSecurityPolicyTests.m
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
#import "CCAFSecurityPolicy.h"

@interface CCAFSecurityPolicyTests : CCAFTestCase

@end

static SecTrustRef CCAFUTTrustChainForCertsInDirectory(NSString *directoryPath) {
    NSArray *certFileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray *certs  = [NSMutableArray arrayWithCapacity:[certFileNames count]];
    for (NSString *path in certFileNames) {
        NSData *certData = [NSData dataWithContentsOfFile:[directoryPath stringByAppendingPathComponent:path]];
        SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
        [certs addObject:(__bridge id)(cert)];
    }

    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust = NULL;
    SecTrustCreateWithCertificates((__bridge CFTypeRef)(certs), policy, &trust);
    CFRelease(policy);

    return trust;
}

static SecTrustRef CCAFUTHTTPBinOrgServerTrust() {
    NSString *bundlePath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] resourcePath];
    NSString *serverCertDirectoryPath = [bundlePath stringByAppendingPathComponent:@"HTTPBinOrgServerTrustChain"];

    return CCAFUTTrustChainForCertsInDirectory(serverCertDirectoryPath);
}

static SecTrustRef CCAFUTADNNetServerTrust() {
    NSString *bundlePath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] resourcePath];
    NSString *serverCertDirectoryPath = [bundlePath stringByAppendingPathComponent:@"ADNNetServerTrustChain"];

    return CCAFUTTrustChainForCertsInDirectory(serverCertDirectoryPath);
}

//static SecTrustRef CCAFUTGoogleComServerTrustPath1() {
//    NSString *bundlePath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] resourcePath];
//    NSString *serverCertDirectoryPath = [bundlePath stringByAppendingPathComponent:@"GoogleComServerTrustChainPath1"];
//    
//    return CCAFUTTrustChainForCertsInDirectory(serverCertDirectoryPath);
//}
//
//static SecTrustRef CCAFUTGoogleComServerTrustPath2() {
//    NSString *bundlePath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] resourcePath];
//    NSString *serverCertDirectoryPath = [bundlePath stringByAppendingPathComponent:@"GoogleComServerTrustChainPath2"];
//
//    return CCAFUTTrustChainForCertsInDirectory(serverCertDirectoryPath);
//}

static SecCertificateRef CCAFUTHTTPBinOrgCertificate() {
    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"httpbinorg_01192017" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef CCAFUTCOMODORSADomainValidationSecureServerCertificate() {
    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"COMODO_RSA_Domain_Validation_Secure_Server_CA" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef CCAFUTCOMODORSACertificate() {
    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"COMODO_RSA_Certification_Authority" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef CCAFUTAddTrustExternalRootCertificate() {
    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"AddTrust_External_CA_Root" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

//static SecCertificateRef CCAFUTGoogleComEquifaxSecureCARootCertificate() {
//    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"Equifax_Secure_Certificate_Authority_Root" ofType:@"cer"];
//    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
//    NSData *certData = [NSData dataWithContentsOfFile:certPath];
//    
//    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
//}
//
//static SecCertificateRef CCAFUTGoogleComGeoTrustGlobalCARootCertificate() {
//    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"GeoTrust_Global_CA_Root" ofType:@"cer"];
//    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
//    NSData *certData = [NSData dataWithContentsOfFile:certPath];
//    
//    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
//}

static SecCertificateRef CCAFUTSelfSignedCertificateWithoutDomain() {
    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"NoDomains" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef CCAFUTSelfSignedCertificateWithCommonNameDomain() {
    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"foobar.com" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef CCAFUTSelfSignedCertificateWithDNSNameDomain() {
    NSString *certPath = [[NSBundle bundleForClass:[CCAFSecurityPolicyTests class]] pathForResource:@"AltName" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecTrustRef CCAFUTTrustWithCertificate(SecCertificateRef certificate) {
    NSArray *certs  = @[(__bridge id)(certificate)];

    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust = NULL;
    SecTrustCreateWithCertificates((__bridge CFTypeRef)(certs), policy, &trust);
    CFRelease(policy);

    return trust;
}

@implementation CCAFSecurityPolicyTests

#pragma mark - Default Policy Tests
#pragma mark Default Values Test

- (void)testDefaultPolicyPinningModeIsSetToNone {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    XCTAssertTrue(policy.SSLPinningMode == CCAFSSLPinningModeNone, @"Pinning Mode should be set to by default");
}

- (void)testDefaultPolicyHasInvalidCertificatesAreDisabledByDefault {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    XCTAssertFalse(policy.allowInvalidCertificates, @"Invalid Certificates Should Be Disabled by Default");
}

- (void)testDefaultPolicyHasDomainNamesAreValidatedByDefault {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    XCTAssertTrue(policy.validatesDomainName, @"Domain names should be validated by default");
}

- (void)testDefaultPolicyHasNoPinnedCertificates {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    XCTAssertTrue(policy.pinnedCertificates.count == 0, @"The default policy should not have any pinned certificates");
}

#pragma mark Positive Server Trust Evaluation Tests

- (void)testDefaultPolicyDoesAllowHTTPBinOrgCertificate {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    SecTrustRef trust = CCAFUTHTTPBinOrgServerTrust();
    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:nil], @"Valid Certificate should be allowed by default.");
}

- (void)testDefaultPolicyDoesAllowHTTPBinOrgCertificateForValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    SecTrustRef trust = CCAFUTHTTPBinOrgServerTrust();
    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"httpbin.org"], @"Valid Certificate should be allowed by default.");
}

#pragma mark Negative Server Trust Evaluation Tests

- (void)testDefaultPolicyDoesNotAllowInvalidCertificate {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithoutDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);
    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:nil], @"Invalid Certificates should not be allowed");
}

- (void)testDefaultPolicyDoesNotAllowCertificateWithInvalidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    SecTrustRef trust = CCAFUTHTTPBinOrgServerTrust();
    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"apple.com"], @"Certificate should not be allowed because the domain names do not match.");
}

#pragma mark - Public Key Pinning Tests
#pragma mark Default Values Tests

- (void)testPolicyWithPublicKeyPinningModeHasPinnedCertificates {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];
    XCTAssertTrue(policy.pinnedCertificates > 0, @"Policy should contain default pinned certificates");
}

- (void)testPolicyWithPublicKeyPinningModeHasHTTPBinOrgPinnedCertificate {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey withPinnedCertificates:[CCAFSecurityPolicy certificatesInBundle:bundle]];

    SecCertificateRef cert = CCAFUTHTTPBinOrgCertificate();
    NSData *certData = (__bridge NSData *)(SecCertificateCopyData(cert));
    CFRelease(cert);
    NSSet *set = [policy.pinnedCertificates objectsPassingTest:^BOOL(NSData *data, BOOL *stop) {
        return [data isEqualToData:certData];
    }];

    XCTAssertEqual(set.count, 1U, @"HTTPBin.org certificate not found in the default certificates");
}

#pragma mark Positive Server Trust Evaluation Tests
- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeCCAFCertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgIntermediate1CertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTCOMODORSADomainValidationSecureServerCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgIntermediate2CertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTCOMODORSACertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgRootCertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTAddTrustExternalRootCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithEntireCertificateChainPinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef httpBinCertificate = CCAFUTHTTPBinOrgCertificate();
    SecCertificateRef intermedaite1Certificate = CCAFUTCOMODORSADomainValidationSecureServerCertificate();
    SecCertificateRef intermedaite2Certificate = CCAFUTCOMODORSACertificate();
    SecCertificateRef rootCertificate = CCAFUTAddTrustExternalRootCertificate();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(intermedaite1Certificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(intermedaite2Certificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(rootCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");

}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBirnOrgServerTrustWithHTTPbinOrgPinnedCertificateAndAdditionalPinnedCertificates {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef httpBinCertificate = CCAFUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = CCAFUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeCCAFCertificatePinnedAndValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:@"httpbin.org"], @"Policy should allow server trust");
}

#pragma mark Negative Server Trust Evaluation Tests

- (void)testPolicyWithPublicKeyPinningAndNoPinnedCertificatesDoesNotAllowHTTPBinOrgServerTrust {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];
    policy.pinnedCertificates = [NSSet set];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should not allow server trust because the policy is set to public key pinning and it does not contain any pinned certificates.");
}

- (void)testPolicyWithPublicKeyPinningDoesNotAllowADNServerTrustWithHTTPBinOrgPinnedCertificate {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust for pinned HTTPBin.org certificate");
}

- (void)testPolicyWithPublicKeyPinningDoesNotAllowHTTPBinOrgServerTrustWithHTTPBinOrgLeCCAFCertificatePinnedAndInvalidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:@"invaliddomainname.com"], @"Policy should not allow server trust");
}

- (void)testPolicyWithPublicKeyPinningDoesNotAllowADNServerTrustWithMultipleInvalidPinnedCertificates {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef httpBinCertificate = CCAFUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = CCAFUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust because there are no matching pinned certificates");
}

#pragma mark - Certificate Pinning Tests
#pragma mark Default Values Tests

- (void)testPolicyWithCertificatePinningModeHasPinnedCertificates {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];
    XCTAssertTrue(policy.pinnedCertificates > 0, @"Policy should contain default pinned certificates");
}

- (void)testPolicyWithCertificatePinningModeHasHTTPBinOrgPinnedCertificate {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate withPinnedCertificates:[CCAFSecurityPolicy certificatesInBundle:bundle]];

    SecCertificateRef cert = CCAFUTHTTPBinOrgCertificate();
    NSData *certData = (__bridge NSData *)(SecCertificateCopyData(cert));
    CFRelease(cert);
    NSSet *set = [policy.pinnedCertificates objectsPassingTest:^BOOL(NSData *data, BOOL *stop) {
        return [data isEqualToData:certData];
    }];

    XCTAssertEqual(set.count, 1U, @"HTTPBin.org certificate not found in the default certificates");
}

#pragma mark Positive Server Trust Evaluation Tests
- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeCCAFCertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgIntermediate1CertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTCOMODORSADomainValidationSecureServerCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgIntermediate2CertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTCOMODORSACertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgRootCertificatePinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTAddTrustExternalRootCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithEntireCertificateChainPinned {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef httpBinCertificate = CCAFUTHTTPBinOrgCertificate();
    SecCertificateRef intermedaite1Certificate = CCAFUTCOMODORSADomainValidationSecureServerCertificate();
    SecCertificateRef intermedaite2Certificate = CCAFUTCOMODORSACertificate();
    SecCertificateRef rootCertificate = CCAFUTAddTrustExternalRootCertificate();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(intermedaite1Certificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(intermedaite2Certificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(rootCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");

}

- (void)testPolicyWithCertificatePinningAllowsHTTPBirnOrgServerTrustWithHTTPbinOrgPinnedCertificateAndAdditionalPinnedCertificates {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef httpBinCertificate = CCAFUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = CCAFUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeCCAFCertificatePinnedAndValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:@"httpbin.org"], @"Policy should allow server trust");
}

//- (void)testPolicyWithCertificatePinningAllowsGoogleComServerTrustIncompleteChainWithRootCertificatePinnedAndValidDomainName {
//    //TODO THIS TEST HAS BEEN DISABLED UNTIL CERTS HAVE BEEN UPDATED.
//    //Please see conversation here: https://github.com/CCAFNetworking/CCAFNetworking/pull/3159#issuecomment-178647437
//    //
//    // Fix certificate validation for servers providing incomplete chains (#3159) - test case
//    //
//    // google.com has two certification paths and both send incomplete certificate chains, i.e. don't include the Root CA
//    // (this can be validated in https://www.ssllabs.com/ssltest/analyze.html?d=google.com)
//    //
//    // The two certification paths are:
//    // - Path 1: *.google.com, Google Internet Authority G2 (with GeoTrust Global CA Root)
//    // - Path 2: *.google.com, Google Internet Authority G2, GeoTrust Global CA (cross signed) (with Equifax Secure CA Root)
//    //
//    // The common goal of using certificate pinning is to prevent MiTM (man-in-the-middle) attacks, so the Root CA's should be pinned to protect the entire chains.
//    // Since there's no Root CA being sent, when `-evaluateServerTrust:` invokes `CCAFCertificateTrustChainForServerTrust(serverTrust)`, the Root CA isn't present
//    // Therefore, even though `CCAFServerTrustIsValid(serverTrust)` succeeds, the next validation fails since no pinned certificate matches the `pinnedCertificates`.
//    // By fetching the `CCAFCertificateTrustChainForServerTrust(serverTrust)` *CCAFter* the `CCAFServerTrustIsValid(serverTrust)` validation, the complete chain is obtained and the Root CA's match.
//    
//    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];
//
//    // certification path 1
//    SecCertificateRef certificate = CCAFUTGoogleComGeoTrustGlobalCARootCertificate();
//    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
//    
//    XCTAssertTrue([policy evaluateServerTrust:CCAFUTGoogleComServerTrustPath1() forDomain:@"google.com"], @"Policy should allow server trust");
//
//    // certification path 2
//    certificate = CCAFUTGoogleComEquifaxSecureCARootCertificate();
//    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
//
//    XCTAssertTrue([policy evaluateServerTrust:CCAFUTGoogleComServerTrustPath2() forDomain:@"google.com"], @"Policy should allow server trust");
//}

#pragma mark Negative Server Trust Evaluation Tests

- (void)testPolicyWithCertificatePinningAndNoPinnedCertificatesDoesNotAllowHTTPBinOrgServerTrust {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];
    policy.pinnedCertificates = [NSSet set];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should not allow server trust because the policy does not contain any pinned certificates.");
}

- (void)testPolicyWithCertificatePinningDoesNotAllowADNServerTrustWithHTTPBinOrgPinnedCertificate {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust for pinned HTTPBin.org certificate");
}

- (void)testPolicyWithCertificatePinningDoesNotAllowHTTPBinOrgServerTrustWithHTTPBinOrgLeCCAFCertificatePinnedAndInvalidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:@"invaliddomainname.com"], @"Policy should not allow server trust");
}

- (void)testPolicyWithCertificatePinningDoesNotAllowADNServerTrustWithMultipleInvalidPinnedCertificates {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef httpBinCertificate = CCAFUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = CCAFUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust because there are no matching pinned certificates");
}

#pragma mark - Domain Name Validation Tests
#pragma mark Positive Evaluation Tests

- (void)testThatPolicyWithoutDomainNameValidationAllowsServerTrustWithInvalidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    [policy setValidatesDomainName:NO];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:@"invalid.org"], @"Policy should allow server trust because domain name validation is disabled");
}

- (void)testThatPolicyWithDomainNameValidationAllowsServerTrustWithValidWildcardDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    XCTAssertTrue([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:@"test.httpbin.org"], @"Policy should allow server trust");
}

- (void)testThatPolicyWithDomainNameValidationAndSelfSignedCommonNameCertificateAllowsServerTrust {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithCommonNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];
    [policy setAllowInvalidCertificates:YES];

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust");
}

- (void)testThatPolicyWithDomainNameValidationAndSelfSignedDNSCertificateAllowsServerTrust {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];

    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];
    [policy setAllowInvalidCertificates:YES];

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust");
}

#pragma mark Negative Evaluation Tests

- (void)testThatPolicyWithDomainNameValidationDoesNotAllowServerTrustWithInvalidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    XCTAssertFalse([policy evaluateServerTrust:CCAFUTHTTPBinOrgServerTrust() forDomain:@"invalid.org"], @"Policy should not allow allow server trust");
}

- (void)testThatPolicyWithDomainNameValidationAndSelfSignedNoDomainCertificateDoesNotAllowServerTrust {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];

    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithoutDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];
    [policy setAllowInvalidCertificates:YES];

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust");
}

#pragma mark - Self Signed Certificate Tests
#pragma mark Positive Test Cases

- (void)testThatPolicyWithInvalidCertificatesAllowedAllowsSelfSignedServerTrust {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];
    [policy setAllowInvalidCertificates:YES];

    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:nil], @"Policy should allow server trust because invalid certificates are allowed");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndValidPinnedCertificatesDoesAllowSelfSignedServerTrustForValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];
    [policy setAllowInvalidCertificates:YES];
    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust because invalid certificates are allowed");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndNoSSLPinningAndDomainNameValidationDisabledDoesAllowSelfSignedServerTrustForValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeNone];
    [policy setAllowInvalidCertificates:YES];
    [policy setValidatesDomainName:NO];

    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust because invalid certificates are allowed");
}

#pragma mark Negative Test Cases

- (void)testThatPolicyWithInvalidCertificatesDisabledDoesNotAllowSelfSignedServerTrust {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy defaultPolicy];

    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:nil], @"Policy should not allow server trust because invalid certificates are not allowed");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndNoPinnedCertificatesAndPublicKeyPinningModeDoesNotAllowSelfSignedServerTrustForValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModePublicKey];
    [policy setAllowInvalidCertificates:YES];
    [policy setPinnedCertificates:[NSSet set]];
    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust because invalid certificates are allowed but there are no pinned certificates");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndValidPinnedCertificatesAndNoPinningModeDoesNotAllowSelfSignedServerTrustForValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeNone];
    [policy setAllowInvalidCertificates:YES];
    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust because invalid certificates are allowed but there are no pinned certificates");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndNoValidPinnedCertificatesAndNoPinningModeAndDomainValidationDoesNotAllowSelfSignedServerTrustForValidDomainName {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeNone];
    [policy setAllowInvalidCertificates:YES];
    [policy setPinnedCertificates:[NSSet set]];

    SecCertificateRef certificate = CCAFUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = CCAFUTTrustWithCertificate(certificate);

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust because invalid certificates are allowed but there are no pinned certificates");
}

#pragma mark - NSCopying
- (void)testThatPolicyCanBeCopied {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = NO;
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(CCAFUTHTTPBinOrgCertificate())];

    CCAFSecurityPolicy *copiedPolicy = [policy copy];
    XCTAssertNotEqual(copiedPolicy, policy);
    XCTAssertEqual(copiedPolicy.allowInvalidCertificates, policy.allowInvalidCertificates);
    XCTAssertEqual(copiedPolicy.validatesDomainName, policy.validatesDomainName);
    XCTAssertEqual(copiedPolicy.SSLPinningMode, policy.SSLPinningMode);
    XCTAssertTrue([copiedPolicy.pinnedCertificates isEqualToSet:policy.pinnedCertificates]);
}

- (void)testThatPolicyCanBeEncodedAndDecoded {
    CCAFSecurityPolicy *policy = [CCAFSecurityPolicy policyWithPinningMode:CCAFSSLPinningModeCertificate];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = NO;
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(CCAFUTHTTPBinOrgCertificate())];

    NSMutableData *archiveData = [NSMutableData new];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
    [archiver encodeObject:policy forKey:@"policy"];
    [archiver finishEncoding];

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archiveData];
    CCAFSecurityPolicy *unarchivedPolicy = [unarchiver decodeObjectOfClass:[CCAFSecurityPolicy class] forKey:@"policy"];

    XCTAssertNotEqual(unarchivedPolicy, policy);
    XCTAssertEqual(unarchivedPolicy.allowInvalidCertificates, policy.allowInvalidCertificates);
    XCTAssertEqual(unarchivedPolicy.validatesDomainName, policy.validatesDomainName);
    XCTAssertEqual(unarchivedPolicy.SSLPinningMode, policy.SSLPinningMode);
    XCTAssertTrue([unarchivedPolicy.pinnedCertificates isEqualToSet:policy.pinnedCertificates]);
}

@end
