//
//  CacheFeedUseCaseTests.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//

import XCTest
import Combine
import LoveTheUniverse


final class CacheFeedUseCaseTests:XCTestCase {
    
    func test_cache_successFullyStoresData() {
        let defaults = UserDefaults.standard
        let planet1 = Planet(name: Name(common: "planet1", official: "planet1"))
        let savedPlanets = [planet1]
        let sut = makeSUT()
        sut.save(savedPlanets)
        
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
