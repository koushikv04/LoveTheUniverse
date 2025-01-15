//
//  CacheFeedUseCaseTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//

import XCTest
import Combine
import LoveTheUniverse

final class LocalFeedLoader {
    typealias SaveResult = Swift.Result<Void,Swift.Error>
    
    enum Error:Swift.Error {
        case invalidData
        case retrievalError
    }
    
    func save(_ planets:[Planet],completion:@escaping(SaveResult)->Void) {
        if let planetsData = try? JSONEncoder().encode(planets) {
            UserDefaults.standard.set(planetsData, forKey: "planets")
            completion(.success(()))
        } else {
            completion(.failure(Error.invalidData))
        }
    }
    
    func load() -> AnyPublisher<[Planet],Error> {
        if let planetsData = UserDefaults.standard.value(forKey: "planets") as? Data,let planets = try? JSONDecoder().decode([Planet].self, from: planetsData) {
            return Just(planets).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: Error.retrievalError).eraseToAnyPublisher()
        }
    }
}

final class CacheFeedUseCaseTests:XCTestCase {
    
    func test_cache_successFullyStoresData() {
        let defaults = UserDefaults.standard
        let planet1 = Planet(name: Name(common: "planet1", official: "planet1"))
        let savedPlanets = [planet1]
        let sut = makeSUT()
        let exp = expectation(description: "wait for save cache")
        sut.save(savedPlanets) { result in
            switch result {
            case .success:
                break
            default:
                XCTFail("should have succeeded but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        let planetsData = defaults.value(forKey: "planets") as? Data
        XCTAssertNotNil(planetsData)
        let retrievedPlanets = try? JSONDecoder().decode([Planet].self, from: planetsData!)
        XCTAssertEqual(retrievedPlanets, savedPlanets,"Expected to save and retireve the same planets")
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
    
}
