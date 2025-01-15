//
//  PlanetViewModel.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//
import Foundation
import Combine

final class PlanetViewModel:ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let remoteFeedLoader:FeedLoader
    private let localFeedLoader:FeedLoader & PlanetsCache
    @Published var planets:[Planet] = []
   
    init(remoteFeedLoader: FeedLoader,localFeedLoader:FeedLoader & PlanetsCache) {
        self.remoteFeedLoader = remoteFeedLoader
        self.localFeedLoader = localFeedLoader
    }
    
    public func fetchPlanets() {
        remoteFeedLoader.load()
            .receive(on: DispatchQueue.main)
            .sink { [weak self]result in
                guard let self = self else {return}
                switch result {
                case .finished:break
                case .failure(_):
                  _ =  localFeedLoader.load().sink { _ in
                        
                    } receiveValue: { planets in
                        self.planets = planets
                    }
                }
            } receiveValue: {[weak self] planets in
                guard let self = self else {return}
                self.localFeedLoader.save(planets)
                self.planets = planets
            }.store(in: &cancellables)

    }
    
    
}


