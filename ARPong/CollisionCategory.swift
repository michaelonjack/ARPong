//
//  CollisionCategory.swift
//  ARPong
//
//  Created by Michael Onjack on 9/16/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let ball = CollisionCategory(rawValue: 2)
    static let cup = CollisionCategory(rawValue: 4)
    static let floor = CollisionCategory(rawValue: 8)
}
