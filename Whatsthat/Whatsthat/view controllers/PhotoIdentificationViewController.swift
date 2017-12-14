//
//  PhotoIdentificationViewController.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 11/26/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import UIKit

class PhotoIdentificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var catchImage : UIImage?
    var selectedRow = Int()
    
    @IBOutlet weak var resultTableView: UITableView!
    var googleResults = [GoogleVisionResult]()
    let googleVisionApiManager = GoogleVisionAPIManager()
    
    
    func getGoogleApiResults(image : UIImage?) {
        if let selectedImage = image {
            googleVisionApiManager.fetchImageAnalysisDataFromGoogle(selectedImage)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googleResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleResult", for: indexPath)
        let googleIndexPath = indexPath.row
        cell.textLabel?.text = googleResults[googleIndexPath].description
        let score = Double(round(googleResults[googleIndexPath].score * 10000)/100)
        cell.detailTextLabel?.text = "Score: \(score.description) %"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        performSegue(withIdentifier: "WikipediaSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = catchImage
        googleVisionApiManager.delegate = self
        getGoogleApiResults(image: catchImage)
        resultTableView.delegate = self
        resultTableView.dataSource = self
    }
    
}

extension PhotoIdentificationViewController : ImageResultDelegate {
    func imageDataFound(googleVisionResults: [GoogleVisionResult]) {
        self.googleResults = googleVisionResults
        
        //update tableview data on the main (UI) thread
        DispatchQueue.main.async {
            self.resultTableView.reloadData()
        }
    }
    
    func imageDataNotFound(reason: GoogleVisionAPIManager.FailureReason) {
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: "Problem fetching google results", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.getGoogleApiResults(image: self.catchImage)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .badJSONResponse, .noData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WikipediaSegue" {
            if let photoDetailsViewController = segue.destination as? PhotoDetailsViewController {
                photoDetailsViewController.titleFromTableView = googleResults[self.selectedRow].description
                photoDetailsViewController.image = self.catchImage
            }
        }
    }
}



