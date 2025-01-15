//
//  RemoteFeedLoaderWithFallbackCompositeTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 15/01/2025.
//
import XCTest
import Combine
import LoveTheUniverse



final class FeedLoaderStub:FeedLoader {
    private let result:Subscribers.Completion<Error>
    private let planets:[Planet]?
    
    init(result:Subscribers.Completion<Error>,planets:[Planet]? = nil) {
        self.result = result
        self.planets = planets
    }
    
    func load() -> AnyPublisher<[Planet], Error> {
        switch result {
        case .finished:
            return Just(planets!).setFailureType(to: Error.self).eraseToAnyPublisher()
        case let.failure(error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

final class RemoteFeedLoaderWithFallbackCompositeTests:XCTestCase {
    
    func test_load_deliversSuccessfullyPrimaryFeed() {
        let primaryPlanets = makePlanets("planet1")
        let fallbackPlanets = makePlanets("planet2")
        let primaryLoader = FeedLoaderStub(result:.finished, planets: primaryPlanets)
        let fallbackLoader = FeedLoaderStub(result:.finished, planets: fallbackPlanets)
        let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        expect(sut, toCompleteWith: .finished, items: primaryPlanets)
    }
    
    func test_load_deliversFallbackSuccessfullyOnPrimaryFailure() {
        let primaryError = anyNSError()
        let fallbackPlanets = makePlanets("planet2")
        let primaryLoader = FeedLoaderStub(result:.failure(primaryError))
        let fallbackLoader = FeedLoaderStub(result:.finished, planets: fallbackPlanets)
        let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        expect(sut, toCompleteWith: .finished, items: fallbackPlanets)

    }
    
    func test_load_deliversFailureOnPrimaryAndFallbackLoaderFailure() {
        let primaryError = anyNSError()
        let fallbackError = anyNSError()

        let primaryLoader = FeedLoaderStub(result:.failure(primaryError))
        let fallbackLoader = FeedLoaderStub(result:.failure(fallbackError))
        let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        expect(sut, toCompleteWith: .failure(fallbackError), items: nil)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(primaryLoader:FeedLoader,fallbackLoader:FeedLoader,file: StaticString = #file, line: UInt = #line) -> RemoteFeedLoaderWithFallbackComposite {
        let sut = RemoteFeedLoaderWithFallbackComposite(primary:primaryLoader,fallback:fallbackLoader)
        trackMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    private func trackMemoryLeak(_ instance:AnyObject,file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance,file: file,line: line)
        }
    }
    
    private func expect(_ sut:RemoteFeedLoaderWithFallbackComposite,toCompleteWith expectedResult:Subscribers.Completion<Error>,items:[Planet]?) {
        var receivedPlanets = [Planet]()
        let exp = expectation(description: "wait for load to finish")
        _ = sut.load().sink { receivedResult in
            switch (receivedResult,expectedResult) {
            case (.finished,.finished):
                break
            case let (.failure(receivedError as NSError),.failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("should have received \(expectedResult) but got \(receivedResult) instead")
            }
            exp.fulfill()
        } receiveValue: { planets in
            receivedPlanets = planets
        }

        wait(for: [exp], timeout: 1.0)
        
        if let items = items {
            XCTAssertEqual(receivedPlanets, items,"Expected composite to return planet items")
        }
    }
    
    private func makePlanets(_ name:String) -> [Planet] {
        return [Planet(name: Name(common: name, official: name))]
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
