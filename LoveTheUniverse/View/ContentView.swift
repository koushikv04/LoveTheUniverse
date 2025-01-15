//
//  ContentView.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var viewModel = PlanetViewModel(remoteFeedLoader: RemoteFeedLoader(url: URL(string: "https://restcountries.com/v3.1/region/europe")!,session: URLSession(configuration: .ephemeral)), localFeedLoader: LocalFeedLoader.shared)

    var body: some View {
        NavigationView {
            List(viewModel.planets,id: \.name.common) {planet in
                Text(planet.name.official)
            }
            .onAppear(){
                viewModel.fetchPlanets()
            }
            .navigationTitle("Planets")
        }
    }
}

