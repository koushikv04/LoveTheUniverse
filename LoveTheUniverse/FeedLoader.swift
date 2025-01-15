//
//  FeedLoader.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//
import Combine

public protocol FeedLoader {
    func load() -> AnyPublisher<[Planet], Error>
}
