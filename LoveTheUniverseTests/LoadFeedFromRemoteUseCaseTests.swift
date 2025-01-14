//
//  LoadFeedFromRemoteUseCaseTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//
import XCTest
import LoveTheUniverse

final class RemoteFeedLoader {
    
}

final class LoadFeedFromRemoteUseCaseTests:XCTestCase {
    func test_init_doesNotLoadFeed() {
        URLProtocol.registerClass(URLProtocolStub.self)
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(URLProtocolStub.requestedURL,"Expected remote feed loader not to call url session on init")
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    final class URLProtocolStub:URLProtocol {
        static var requestedURL:URL?
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestedURL = request.url
            return false
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
        }
        
        override func stopLoading() {
            
        }
    }
}

