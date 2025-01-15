//
//  RemoteLoaderWithCacheTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//
import Foundation
import Combine
import LoveTheUniverse
import XCTest

//protocol FeedCache {
//    func save(_ planets:[Planet])
//    func load(completion: @escaping(([Planet]) -> Void))
//}
//
protocol RemoteLoader {
    func load() -> AnyPublisher<[Planet],Error>
}

//final class RemoteLoaderWithCache {
//    private let url:URL
//    private let remote:RemoteLoader
//    private let cache:FeedCache
//    
//    init(url: URL = URL(string: "any-url.com")!,remoteLoader:RemoteLoader,cache:FeedCache) {
//        self.url = url
//    }
//    
//    func fetchPlanets() {
//        remote.load().receive(on: DispatchQueue.main).sink { result in
//            switch result {
//            case .finished
//            case .failure(let error)
//            }
//        } receiveValue: { planets in
//            
//        }
//
//    }
//   
//}

final class PlanetsViewModel {
    private let remoteLoader:RemoteLoader
    private var cancellables = Set<AnyCancellable>()
    
    var planets:[Planet] = []
    
    init(remoteLoader: RemoteLoader) {
        self.remoteLoader = remoteLoader
    }
    
    func fetchPlanets(completion: @escaping((Subscribers.Completion<Error>) -> Void)) {
        remoteLoader.load().sink { result in
            completion(result)
        } receiveValue: { planets in
            self.planets = planets
        }.store(in: &cancellables)

    }
}
final class RemoteFeedLoader:RemoteLoader {
    private let session:URLSession
    private let url:URL
    
    init(url:URL,session: URLSession) {
        self.url = url
        self.session = session
    }
    
    func load() -> AnyPublisher<[Planet],Error> {
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Planet].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

final class LoadFeedFromRemoteUseCaseTests:XCTestCase {
    
    override func tearDown() {
        URLProtoColStub.clearValues()
    }
    
    func test_load_requestsURLInSession() {
        let url = anyURL()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtoColStub.self]
        let session = URLSession(configuration: config)
        let sut = RemoteFeedLoader(url: url, session: session)
        let viewModel = PlanetsViewModel(remoteLoader: sut)
        
        viewModel.fetchPlanets(){_ in }
        
        let exp = expectation(description: "wait to return the requested url")
        
        URLProtoColStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    
    }
    
    func test_load_failsOnInvalidCases() {
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
        let (_,viewModel) = makeSUT()
        
        executeFinishWith(viewModel,data: data)
        
        XCTAssertEqual(viewModel.planets, emptyPlanets,"Expected the sut to return the planets")
    }
    
    func test_load_succeedsOnHTTPResponseWithData() {
        let (_,viewModel) = makeSUT()
        let planet1 = Planet(name: Name(common: "planet1", official: "planet1"))
        let planet2 = Planet(name: Name(common: "planet2", official: "planet2"))
        let planets = [planet1,planet2]
        let data = try! JSONEncoder().encode(planets)
        
        executeFinishWith(viewModel,data: data)
        
        XCTAssertEqual(viewModel.planets, planets,"Expected the sut to return the planets")
    }
    
    
//    func test_load_deliversErrorOnSessionError() {
//        let url = URL(string: "any-url.com")!
//        let config = URLSessionConfiguration.ephemeral
//        config.protocolClasses = [URLProtoColStub.self]
//        let session = URLSession(configuration: config)
//        let error = NSError(domain: "any error", code:  0)
//        URLProtoColStub.stub(data: nil, error: error, response: nil)
//        let sut = RemoteFeedLoader(url: url, session: session)
//        let viewModel = PlanetsViewModel(remoteLoader: sut)
//        
//        let exp = expectation(description: "wait to return the requested url")
//
//        viewModel.fetchPlanets(){result in
//            switch result {
//            case .failure:
//                break
//            default:
//                XCTFail("should have failed but got response \(result) instead")
//            }
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1.0)
//    }
    
//    func test_load_deliversFinishedO() {
//        let url = URL(string: "any-url.com")!
//        let config = URLSessionConfiguration.ephemeral
//        config.protocolClasses = [URLProtoColStub.self]
//        let session = URLSession(configuration: config)
//        let error = NSError(domain: "any error", code:  0)
//        URLProtoColStub.stub(data: nil, error: error, response: nil)
//        let sut = RemoteFeedLoader(url: url, session: session)
//        let viewModel = PlanetsViewModel(remoteLoader: sut)
//        
//        let exp = expectation(description: "wait to return the requested url")
//
//        viewModel.fetchPlanets(){result in
//            switch result {
//            case .failure:
//                break
//            default:
//                XCTFail("should have failed but got response \(result) instead")
//            }
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1.0)
//    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:RemoteFeedLoader,viewModel:PlanetsViewModel) {
        let url = anyURL()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtoColStub.self]
        let session = URLSession(configuration: config)
        let sut = RemoteFeedLoader(url: url, session: session)
        let viewModel = PlanetsViewModel(remoteLoader: sut)
        trackMemoryLeak(sut,file: file,line: line)
        trackMemoryLeak(viewModel,file: file,line: line)
        return (sut,viewModel)
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
    
    private func executeFinishWith(_ viewModel:PlanetsViewModel,data:Data) {
        let url = anyURL()
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtoColStub.stub(data: data, error: nil, response: response)
        
        let exp = expectation(description: "wait to return the requested url")
        viewModel.fetchPlanets(){result in
            switch result {
            case .finished:
                break
            default:
                XCTFail("should have finished but got response \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func resultErrorFor(data:Data?,error:Error?,response:URLResponse?,file: StaticString = #file, line: UInt = #line) -> Error? {
        let (_,viewModel) = makeSUT(file:file,line: line)
        URLProtoColStub.stub(data: data, error: error, response: response)
        
        var receivedError:Error?
        let exp = expectation(description: "wait to return the requested url")
        viewModel.fetchPlanets(){result in
            switch result {
            case let .failure(error):
                receivedError = error
                break
            default:
                XCTFail("should have failed but got response \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
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
