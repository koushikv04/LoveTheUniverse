//
//  Planet.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//
import Foundation

public struct Planet:Equatable,Codable {
    var name:Name
    public init(name: Name) {
        self.name = name
    }
}

public struct Name:Equatable,Codable {
    var common:String
    var official:String
    
    public init(common: String, official: String) {
        self.common = common
        self.official = official
    }
}
