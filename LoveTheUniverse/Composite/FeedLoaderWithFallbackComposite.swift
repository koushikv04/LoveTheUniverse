//
//  FeedLoaderWithFallbackComposite.swift
//  LoveTheUniverse
//
//  Created by Kouv on 15/01/2025.
//
import Foundation
import Combine

public final class RemoteFeedLoaderWithFallbackComposite:FeedLoader {
    private let primary:FeedLoader
    private let fallback:FeedLoader

    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load() -> AnyPublisher<[Planet], Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {return}
                _ = self.primary.load().sink { result in
                    switch result {
                    case .finished:
                        break
                    case .failure:
                        _ = self.fallback.load().sink { result in
                            switch result {
                            case .finished:
                                break
                            case let .failure(error):
                                promise(.failure(error))
                            }
                        } receiveValue: { planets in
                            promise(.success(planets))
                        }
                        
                        
                    }
                } receiveValue: { planets in
                    promise(.success(planets))
                }
            }
        }.eraseToAnyPublisher()
        

    }
    
}
