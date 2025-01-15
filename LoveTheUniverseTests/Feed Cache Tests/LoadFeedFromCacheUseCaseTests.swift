//
//  LoadFeedFromCacheUseCaseTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//

import XCTest
import LoveTheUniverse
import Combine

final class LoadFeedFromCacheUseCaseTests:XCTestCase {
    func test_load_deliversRetrievalError(){
        removeObjectFromUserDefaults()
        let sut = makeSUT()
        let exp = expectation(description: "Wait for load to finish")
        _ = sut.load().sink { result in
            switch result {
            case let .failure(error):
                XCTAssertNotNil(error,"Expected to get retrieval error")
            default:
                XCTFail("should have failed but got response \(result) instead")

            }
            exp.fulfill()
        } receiveValue: { _ in
            
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_successfullyDeliversEmptyList() {
        let sut = makeSUT()
        let savedPlanets:[Planet] = []
        sut.save(savedPlanets)
        expect(sut, toCompleteWith: savedPlanets)
    }
    
    
    func test_load_successfullyDeliversFeed() {
        let sut = makeSUT()
        let planet1 = Planet(name: Name(common: "planet1", official: "planet1"))
        let savedPlanets = [planet1]
        sut.save(savedPlanets)
        expect(sut, toCompleteWith: savedPlanets)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let sut = LocalFeedLoader()
        trackMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    private func trackMemoryLeak(_ instance:AnyObject,file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance,file: file,line: line)
        }
    }
    
    private func removeObjectFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "planets")
    }
   
    
    private func expect(_ sut:LocalFeedLoader,toCompleteWith expectedResult:[Planet]) {
        
        let exp = expectation(description: "Wait for load to finish")
        _ = sut.load().sink { result in
            switch result {
            case .finished:
                break
            default:
                XCTFail("should have finished but got response \(result) instead")
            }
            exp.fulfill()
        } receiveValue: { receivedResult in
            XCTAssertEqual(receivedResult, expectedResult)
        }
        wait(for: [exp], timeout: 1.0)
        
    }
}
