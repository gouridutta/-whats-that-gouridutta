//
//  WikipediaAPIManager.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/19/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import Foundation

protocol WikipediaResultDelegate {
    func wikipediaResultFound(wikipediaResult: WikipediaResult)
    func wikipediaResultNotFound(reason: WikipediaAPIManager.FailureReason)
}

class WikipediaAPIManager {
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No description received"
        case badJSONResponse = "Bad JSON response"
    }
    var delegate: WikipediaResultDelegate?
    
    //this (unused) function parses the JSON manually - use this technique for Wiki API
    func getWikiDescription(title: String) {
        
        var urlComponents = URLComponents(string: "https://en.wikipedia.org/w/api.php")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "prop", value: "extracts"),
            URLQueryItem(name: "exintro", value: ""),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "titles", value: "\(title)")
        ]
        
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.wikipediaResultNotFound(reason: .networkRequestFailed)
                return
            }
            
            guard let data = data, let wikiJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] ?? [String:Any]()   else {
                self.delegate?.wikipediaResultNotFound(reason: .noData)
                return
            }
            
            guard let wikiQueryJsonObject = wikiJsonObject["query"] as? [String:Any], let
                wikiPagesJsonArrayObject = wikiQueryJsonObject["pages"] as? [String: Any] else {
                    self.delegate?.wikipediaResultNotFound(reason: .badJSONResponse)
                    return
            }
            var key =  String()
            for pages in wikiPagesJsonArrayObject {
                key = pages.key
            }
            if let pages = wikiPagesJsonArrayObject[key] as? [String : Any] {
                let pageid = pages["pageid"] as? Int64 ?? 0
                let title = pages["title"] as? String ?? ""
                let extract = pages["extract"] as? String ?? ""
                let wikipediaResult = WikipediaResult(pageid : pageid, title : title, extract :extract)
                self.delegate?.wikipediaResultFound(wikipediaResult : wikipediaResult)
            } else {
                self.delegate?.wikipediaResultNotFound(reason: .badJSONResponse)
                return
            }
        }
        
        task.resume()
    }
}

