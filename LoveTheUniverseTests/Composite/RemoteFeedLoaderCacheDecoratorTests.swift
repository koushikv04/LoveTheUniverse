//
//  RemoteFeedLoaderCacheDecoratorTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 15/01/2025.
//
import XCTest
import Combine
import LoveTheUniverse



final class RemoteFeedLoaderCacheDecoratorTests:XCTestCase {
    func test_load_deliverPlanetsSuccessfullyOnPrimaryLoaderSuccess() {
        let primaryPlanets = makePlanets("planet1")
        let loader = FeedLoaderStub(result:.finished,planets:primaryPlanets)
        let (sut,_) = makeSUT(loader: loader)
        
        let exp = expectation(description: "wait for load to finish")
        _ = sut.load().sink { result in
            switch result {
            case .finished:
                break
            default:
                XCTFail("should have finished but got result \(result)instead")
            }
            exp.fulfill()
        } receiveValue: { planets in
            XCTAssertEqual(planets, primaryPlanets)
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliverFailureOnPrimaryLoaderFailure() {
        let error = anyNSError()
        let loader = FeedLoaderStub(result:.failure(error))
        let (sut,_) = makeSUT(loader: loader)
        
        let exp = expectation(description: "wait for load to finish")
        _ = sut.load().sink { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("should have failed but got result \(result)instead")
            }
            exp.fulfill()
        } receiveValue: { _ in
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_callsCacheOnPrimaryLoaderSuccess() {
        let primaryPlanets = makePlanets("planet1")
        let loader = FeedLoaderStub(result:.finished,planets:primaryPlanets)
        let (sut,cache) = makeSUT(loader: loader)
        
        _ = sut.load()
        
        XCTAssertEqual(cache.receivedMessages, [.save(primaryPlanets)],"Expected cache to receive save call on successfully loading of primary loader")
    }
    
    func test_load_doesNotCallCacheOnPrimaryLoaderFailure() {
        let error = anyNSError()
        let loader = FeedLoaderStub(result:.failure(error))
        let (sut,cache) = makeSUT(loader: loader)
        
        _ = sut.load()
        
        XCTAssertTrue(cache.receivedMessages.isEmpty,"Expected cache not to be called on primary loader failure")
    }
    
    
    
    
    
    //MARK: - Helpers
    private func makePlanets(_ name:String) -> [Planet] {
        return [Planet(name: Name(common: name, official: name))]
    }
    
    private func makeSUT(loader:FeedLoaderStub,file: StaticString = #file, line: UInt = #line) -> (sut:RemoteFeedLoaderCacheDecorator,cache:CacheSpy) {
        let cache = CacheSpy()
        let sut = RemoteFeedLoaderCacheDecorator(decoratee:loader,cache: cache)
        
        trackMemoryLeak(sut,file:file,line:line)
        trackMemoryLeak(cache,file:file,line:line)
        
        return (sut,cache)

    }
    
    private func trackMemoryLeak(_ instance:AnyObject,file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance,file: file,line: line)
        }
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private class CacheSpy:PlanetsCache {
        var receivedMessages = [Message]()
        
        enum Message:Equatable {
            case save([Planet])
        }
        
        func save(_ planets: [Planet]) {
            receivedMessages.append(.save(planets))
        }
    }
}
