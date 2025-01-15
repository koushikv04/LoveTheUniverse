//
//  Planet.swift
//  LoveTheUniverse
//
//  Created by Kouv on 14/01/2025.
//
import Foundation

struct Planet:Decodable {
    var name:Name
}

struct Name:Decodable {
    var common:String
    var official:String
}
