//
//  RemoteFeedLoader.swift
//  LoveTheUniverse
//
//  Created by Kouv on 15/01/2025.
//
import Foundation
import Combine

public final class RemoteFeedLoader:FeedLoader {
    private let session:URLSession
    private let url:URL
    
    public init(url:URL,session: URLSession) {
        self.url = url
        self.session = session
    }
    
    public func load() -> AnyPublisher<[Planet],Error> {
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Planet].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
