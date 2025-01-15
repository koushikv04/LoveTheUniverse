//
//  RemoteFeedLoaderCacheDecorator.swift
//  LoveTheUniverse
//
//  Created by Kouv on 15/01/2025.
//
import Foundation
import Combine

public final class RemoteFeedLoaderCacheDecorator:FeedLoader {
    private let decoratee:FeedLoader
    private let cache:PlanetsCache
    
    public init(decoratee: FeedLoader,cache:PlanetsCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load() -> AnyPublisher<[Planet], Error> {
        Future {promise in
            _ = self.decoratee.load().sink { result in
                    switch result {
                    case .finished:
                        break
                    case let .failure(error):
                        promise(.failure(error))
                    }
                } receiveValue: { planets in
                    self.cache.save(planets)
                    promise(.success(planets))
                }
        }.eraseToAnyPublisher()
        
    }
}
