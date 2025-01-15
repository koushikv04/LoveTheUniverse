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
        UserDefaults.standard.removeObject(forKey: "planets")
        let sut = LocalFeedLoader()
        let exp = expectation(description: "Wait for load to finish")
        _ = sut.load().sink { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error, .retrievalError,"Expected to get retrieval error")
            default:
                XCTFail("should have failed but got response \(result) instead")

            }
            exp.fulfill()
        } receiveValue: { _ in
            
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_successfullyDeliversEmptyList() {
        let sut = LocalFeedLoader()
        let savedPlanets:[Planet] = []
        sut.save(savedPlanets) { _ in
        
        }
        
        let exp = expectation(description: "Wait for load to finish")
        _ = sut.load().sink { result in
            switch result {
            case .finished:
                break
            default:
                XCTFail("should have finished but got response \(result) instead")
            }
            exp.fulfill()
        } receiveValue: { receivedPlanets in
            XCTAssertEqual(receivedPlanets, savedPlanets)
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_load_successfullyDeliversFeed() {
        let sut = LocalFeedLoader()
        let planet1 = Planet(name: Name(common: "planet1", official: "planet1"))
        let savedPlanets = [planet1]
        sut.save(savedPlanets) { _ in
        
        }
        
        let exp = expectation(description: "Wait for load to finish")
        _ = sut.load().sink { result in
            switch result {
            case .finished:
                break
            default:
                XCTFail("should have finished but got response \(result) instead")
            }
            exp.fulfill()
        } receiveValue: { receivedPlanets in
            XCTAssertEqual(receivedPlanets, savedPlanets)
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
}
