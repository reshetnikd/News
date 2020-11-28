//
//  DataManager.swift
//  News
//
//  Created by Dmitry Reshetnik on 28.11.2020.
//

import Foundation

enum NewsAPI {
    static let APIKey = "4cffbd8c3c9143a38b58ed3d477fa716"
    static let BaseURL = URL(string: "https://newsapi.org")!
}

enum DataManagerError: Error {
    case Unknown
    case FailedRequest
    case InvalidResponse
}

final class DataManager {
    typealias NewsDataCompletion = (Response?, DataManagerError?) -> ()
    private let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func getNewsFor(category: String = "general", country: String = "us", sources: String? = nil, completion: @escaping NewsDataCompletion) {
        let url = baseURL.appendingPathComponent("/v2/top-headlines")
        var componetns = URLComponents(string: url.absoluteString)!
        
        let countryItem = URLQueryItem(name: "country", value: country)
        let categoryItem = URLQueryItem(name: "category", value: category)
        let apiItem = URLQueryItem(name: "apiKey", value: NewsAPI.APIKey)
        if sources != nil {
            let sourcesItem = URLQueryItem(name: "sources", value: sources)
            componetns.queryItems = [countryItem, categoryItem, sourcesItem, apiItem]
        } else {
            componetns.queryItems = [countryItem, categoryItem, apiItem]
        }
        
        URLSession.shared.dataTask(with: componetns.url!, completionHandler: { (data, response, error) in
            self.didFetchNewsData(data: data, response: response, error: error, completion: completion)
        }).resume()
    }
    
    private func didFetchNewsData(data: Data?, response: URLResponse?, error: Error?, completion: NewsDataCompletion) {
        if let _ = error {
            completion(nil, DataManagerError.FailedRequest)
        } else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                processNewsData(data: data, completion: completion)
            } else {
                completion(nil, DataManagerError.FailedRequest)
            }
        } else {
            completion(nil, DataManagerError.Unknown)
        }
    }
    
    private func processNewsData(data: Data, completion: NewsDataCompletion) {
        do {
            let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
            completion(Response.init(status: decodedResponse.status, totalResults: decodedResponse.totalResults, articles: decodedResponse.articles), nil)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("could not find key \(key) in JSON: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("could not find type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(let context) {
            print("data found to be corrupted in JSON: \(context.debugDescription)")
        } catch let error as NSError {
            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
        }
    }
}
