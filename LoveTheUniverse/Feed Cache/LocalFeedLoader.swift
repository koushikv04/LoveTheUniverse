//
//  LocalFeedLoader.swift
//  LoveTheUniverse
//
//  Created by Kouv on 15/01/2025.
//
import Foundation
import Combine



public final class LocalFeedLoader {
    
    public static let shared = LocalFeedLoader()
    public init() {
        
    }
}

extension LocalFeedLoader:PlanetsCache{
    public typealias SaveResult = Swift.Result<Void,Swift.Error>

    public func save(_ planets:[Planet]) {
        if let planetsData = try? JSONEncoder().encode(planets) {
            UserDefaults.standard.set(planetsData, forKey: "planets")
        }
        
    }
}

extension LocalFeedLoader:FeedLoader {
    public func load() -> AnyPublisher<[Planet],Error> {
        if let planetsData = UserDefaults.standard.value(forKey: "planets") as? Data,let planets = try? JSONDecoder().decode([Planet].self, from: planetsData) {
            return Just(planets).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "retrieval error", code: 0))
                .eraseToAnyPublisher()
        }
    }
}
