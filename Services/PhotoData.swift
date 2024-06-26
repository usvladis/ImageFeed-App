//
//  PhotoData.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 25.06.2024.
//

import Foundation

struct PhotoData: Codable{
    var items: [PhotoItems]
}

struct PhotoItems: Codable{
    let id: String
    let createdByName: String
    let rawLink: String
    let created: String
    var liked: Bool
    var likesCount: Int
}
