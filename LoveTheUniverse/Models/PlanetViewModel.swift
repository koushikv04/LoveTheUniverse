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
    @Published var planets:[Planet] = []
   
    
    public func fetchPlanets(from url:URL) {
        get(url: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.loadCache { planets in
                        if let planets = planets {
                            self.planets = planets
                        }
                    }
                }
            } receiveValue: { [weak self] planets in
                guard let self = self else {return}
                saveCache(planets: planets)
                self.planets = planets
            }
            .store(in: &cancellables)
        

    }
    
    
    private func saveCache(planets:[Planet]) {
        UserDefaults.setValue(planets, forKey: "planets")
    }
    
    private func loadCache(completion: @escaping ([Planet]?) -> Void) {
        if let planets = UserDefaults.standard.value(forKey: "planets") as? [Planet] {
            completion(planets)
        } else {
            completion(nil)
        }
    }
    
    private func get(url:URL) -> AnyPublisher<[Planet],Error> {
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type : [Planet].self,decoder:JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    
}


