//
//  AddPlaceViewController.swift
//  SunRiseSet
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import UIKit
import GooglePlaces
import NotificationBannerSwift

protocol AddPlaceViewControllerDelegate: class {
    func addPlace(coordinate:CLLocationCoordinate2D, name: String?)
}

class AddPlaceViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbSearchResults: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let identifier = "AddPlaceViewController"
    weak var delegate:AddPlaceViewControllerDelegate?
    var googlePlacesManager:GooglePlacesManager!
    var tableData = [GMSAutocompletePrediction]()
    var fetcher: GMSAutocompleteFetcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googlePlacesManager = GooglePlacesManager.shared
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        setupTable()
        setupPlaceFetcher()
    }
    
    func setupTable(){
        tbSearchResults.delegate = self
        tbSearchResults.dataSource = self
        
        // Hide empty cells
        tbSearchResults.tableFooterView = UIView()
        
        tbSearchResults.reloadData()
    }
    
    func setupPlaceFetcher(){
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        fetcher  = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        fetcher?.delegate = self
    }
}

extension AddPlaceViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetcher?.sourceTextHasChanged(searchText)
    }
}

extension AddPlaceViewController: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        tableData.removeAll()
        for prediction in predictions{
            tableData.append(prediction)
        }
        tbSearchResults.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        let banner = StatusBarNotificationBanner(title: "Error receiving place autocomplete", style: .danger)
        banner.show()
    }
}

extension AddPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(tableData[indexPath.row])
        if let placeID = tableData[indexPath.row].placeID {
            self.activityIndicator.startAnimating()
            googlePlacesManager.getPlaceByID(placeID) { (coordinate, formattedAddress, error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        let banner = StatusBarNotificationBanner(title: "Error receiving place address", style: .danger)
                        banner.show()
                        
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.delegate?.addPlace(coordinate: coordinate!, name: formattedAddress ?? "Unknown")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        else {
            let banner = StatusBarNotificationBanner(title: "Error - no Place ID", style: .danger)
            banner.show()
        }
    }
}

extension AddPlaceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row].attributedFullText.string
        return cell
    }
}
