//
//  Response.swift
//  News
//
//  Created by Dmitry Reshetnik on 28.11.2020.
//

import Foundation

struct Response: Codable {
    struct Article: Codable {
        struct Source: Codable {
            var id: String?
            var name: String?
        }
        
        var source: Source?
        var author: String?
        var title: String?
        var description: String?
        var url: String?
        var urlToImage: String?
        var publishedAt: String?
        var content: String?
    }
    
    var status: String?
    var totalResults: Int?
    var articles: [Article]?
}
