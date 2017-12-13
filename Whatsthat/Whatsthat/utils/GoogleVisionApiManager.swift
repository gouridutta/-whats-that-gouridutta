//
//  GoogleVisionAPIManager.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/3/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import Foundation
import UIKit

protocol ImageResultDelegate {
    func imageDataFound(googleVisionResults: [GoogleVisionResult])
    func imageDataNotFound(reason: GoogleVisionAPIManager.FailureReason)
}

class GoogleVisionAPIManager {
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No image analysis data received"
        case badJSONResponse = "Bad JSON response"
    }
    
    var delegate:ImageResultDelegate?
    
    func fetchImageAnalysisDataFromGoogle(_ image: UIImage) {
        let imageBase64 = base64EncodeImage(image)
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyBoJFhK3JNFPGzeZmHZz3HZyh1P1HGZrG0")!
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 20
                    ]
                ]
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonRequest, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print ("Bad Request")
                self.delegate?.imageDataNotFound(reason: .networkRequestFailed)
                return
            }
            
            //ensure data is non-nil
            guard let data = data else {
                self.delegate?.imageDataNotFound(reason: .noData)
                return
            }
            
            let decoder = JSONDecoder()
            let decodedRoot = try? decoder.decode(Root.self, from: data)
            
            //ensure json structure matches our expections and contains a label annotation array
            guard let root = decodedRoot else {
                self.delegate?.imageDataNotFound(reason: .badJSONResponse)
                return
            }
            
            var googleVisionResults = [GoogleVisionResult]()
            let responses = root.responses
            for response in responses {
                let labelAnnotations = response.labelAnnotations
                for labelAnnotation in labelAnnotations {
                    let googleVisionResult = GoogleVisionResult(mid: labelAnnotation.mid ,description: labelAnnotation.description, score: labelAnnotation.score)
                    googleVisionResults.append(googleVisionResult)
                }
            }
            self.delegate?.imageDataFound(googleVisionResults: googleVisionResults)
        }
        task.resume()
    }
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}


