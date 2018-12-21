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
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
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
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        
        // Hide empty cells
        searchResultsTableView.tableFooterView = UIView()
        
        searchResultsTableView.reloadData()
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
        searchResultsTableView.reloadData()
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
            self.activityIndicatorView.startAnimating()
            googlePlacesManager.getPlaceByID(placeID) { (coordinate, formattedAddress, error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        let banner = StatusBarNotificationBanner(title: "Error receiving place address", style: .danger)
                        banner.show()
                        
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
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
