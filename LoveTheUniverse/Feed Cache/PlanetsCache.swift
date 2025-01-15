//
//  PlanetsCache.swift
//  LoveTheUniverse
//
//  Created by Kouv on 15/01/2025.
//
import Foundation

public protocol PlanetsCache {
    typealias SaveResult = Swift.Result<Void,Swift.Error>
    
    func save(_ planets:[Planet])
}
