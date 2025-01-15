//
//  LoadFeedFromRemoteUseCaseTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//
import Foundation
import Combine
import LoveTheUniverse
import XCTest

final class LoadFeedFromRemoteUseCaseTests:XCTestCase {
    
    override func tearDown() {
        URLProtoColStub.clearValues()
    }
    
    func test_load_requestsURLInSession() {
        let url = anyURL()
        var cancellables = Set<AnyCancellable>()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtoColStub.self]
        let session = URLSession(configuration: config)
        let sut = RemoteFeedLoader(url: url, session: session)
        
        sut.load().sink { _ in
        } receiveValue: { _ in
            
        }.store(in: &cancellables)

        
        let exp = expectation(description: "wait to return the requested url")
        
        URLProtoColStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    
    }
    
    func test_load_failsOnInvalidCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, error: anyNSError(), response: nil),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: nil, error: nil, response: nil),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: anyData(), error: nil, response: nil),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: anyData(), error: anyNSError(), response: nil),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: nil, error: anyNSError(), response: nonHTTPURLResponse()),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: nil, error: anyNSError(), response: anyHTTPURLResponse()),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: anyData(), error: anyNSError(), response: nonHTTPURLResponse()),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: anyData(), error: anyNSError(), response: anyHTTPURLResponse()),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: anyData(), error:nil, response: nonHTTPURLResponse()),"Expected the remote loader to fail")
        XCTAssertNotNil(resultErrorFor(data: nil, error:nil, response: nonHTTPURLResponse()),"Expected the remote loader to fail")
    }
    
    func test_load_succeedsOnHTTPResponseWithNilData() {
        let emptyPlanets:[Planet] = []
        let data = try! JSONEncoder().encode(emptyPlanets)
        let sut = makeSUT()
        
        let receivedPlanets = executeFinishWith(sut,data: data)
        
        XCTAssertEqual(receivedPlanets, emptyPlanets,"Expected the sut to return the planets")
    }
    
    func test_load_succeedsOnHTTPResponseWithData() {
        let sut = makeSUT()
        let planet1 = Planet(name: Name(common: "planet1", official: "planet1"))
        let planet2 = Planet(name: Name(common: "planet2", official: "planet2"))
        let planets = [planet1,planet2]
        let data = try! JSONEncoder().encode(planets)
        
        let receivedPlanets = executeFinishWith(sut,data: data)
        
        XCTAssertEqual(receivedPlanets, planets,"Expected the sut to return the planets")
    }
    
    

    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> RemoteFeedLoader {
        let url = anyURL()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtoColStub.self]
        let session = URLSession(configuration: config)
        let sut = RemoteFeedLoader(url: url, session: session)
        trackMemoryLeak(sut,file: file,line: line)
        return (sut)
    }
    
    private func anyURL() -> URL {
        return URL(string: "any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyData() -> Data {
        return Data("any-data".utf8)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return  HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func trackMemoryLeak(_ instance:AnyObject,file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance,file: file,line: line)
        }
    }
    
    private func executeFinishWith(_ sut:RemoteFeedLoader,data:Data) -> [Planet]? {
        let url = anyURL()
        var receivedPlanets:[Planet]?
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        var cancellables = Set<AnyCancellable>()

        URLProtoColStub.stub(data: data, error: nil, response: response)
        
        let exp = expectation(description: "wait to return the requested url")
        sut.load().sink { result in
            switch result {
            case .finished:
                break
            default:
                XCTFail("should have finished but got response \(result) instead")
            }
            exp.fulfill()
        } receiveValue: { planets in
            receivedPlanets = planets
        }.store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
        
        return receivedPlanets
    }
    
    private func resultErrorFor(data:Data?,error:Error?,response:URLResponse?,file: StaticString = #file, line: UInt = #line) -> Error? {

        let result = resultFor(data: data, error: error, response: response)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("should have failed but got response \(result) instead")
            return nil
        }
    }
    
    private func resultFor(data:Data?,error:Error?,response:URLResponse?,file: StaticString = #file, line: UInt = #line) -> Subscribers.Completion<Error> {
        let sut = makeSUT(file:file,line: line)
        URLProtoColStub.stub(data: data, error: error, response: response)
        var cancellables = Set<AnyCancellable>()
        var receivedResult:Subscribers.Completion<Error>!
        let exp = expectation(description: "wait to return the requested url")
        sut.load().sink { result in
            receivedResult = result
            exp.fulfill()
        } receiveValue: { _ in
            
        }.store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private class URLProtoColStub:URLProtocol {
        
        private static var requestObserver:((URLRequest)->Void)?
        private static var stub:Stub?
        
        private struct Stub {
            let data:Data?
            let error:Error?
            let response:URLResponse?
        }
        
        static func stub(data:Data?,error:Error?,response:URLResponse?) {
            stub = Stub(data: data, error: error, response: response)
        }
        
        private static var data:Data?
        private static var error:Error?
        private static var response:URLResponse?
        
        static func clearValues() {
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer:@escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtoColStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtoColStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let error = URLProtoColStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let response = URLProtoColStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}


//final class PlanetsViewModelTests:XCTestCase {
//    
//    func test_init_doesNotLoadPlanets() {
//        let remote = RemoteFeedLoader()
//        let sut = PlanetsViewModel()
//        
//        XCTAssertTrue(remote.requestURL.isEmpty, "Expected the remote call requested url to be empty")
//    }
//    
//    private class URlProtoColStub:URLProtocol {
//        
//        private static var requestObserver:((URLRequest)->Void)?
//        
//        static func observeRequests(observer:@escaping (URLRequest) -> Void) {
//            requestObserver = observer
//        }
//        
//        override class func canInit(with request: URLRequest) -> Bool {
//            requestObserver?(request)
//            return true
//        }
//        
//        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//            return request
//        }
//        
//        override func startLoading() {
//            client?.urlProtocolDidFinishLoading(self)
//        }
//        
//        override func stopLoading() {
//            
//        }
//    }
//}
