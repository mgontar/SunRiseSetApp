//
//  PlacesViewController.swift
//  SunRiseSet
//
//  Created by Admin on 12/15/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import UIKit
import CoreLocation
import NotificationBannerSwift

class PlacesViewController: UIViewController {
    @IBOutlet weak var tbPlaces: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    var googlePlacesManager:GooglePlacesManager!
    let locationManager = CLLocationManager()
    var currentPlace:Place?
    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupLocation()
    }
    
    func setupLocation(){
        googlePlacesManager = GooglePlacesManager.shared
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            break
        case .authorizedWhenInUse:
            break
        case .authorizedAlways:
            break
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            locationManager.requestWhenInUseAuthorization()
            break
        }
    }
    
    func setupTableView() {
        self.refreshControl.tintColor = .black
        if #available(iOS 10.0, *) {
            self.tbPlaces.refreshControl = refreshControl
        } else {
            self.tbPlaces.addSubview(refreshControl)
        }
        self.tbPlaces.rowHeight = UITableView.automaticDimension
        self.tbPlaces.estimatedRowHeight = 120
        self.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        let nib = UINib(nibName: PlaceCell.nibName, bundle: nil)
        self.tbPlaces.register(nib, forCellReuseIdentifier: PlaceCell.identifier)
        self.tbPlaces.dataSource = self
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData(isPull: true)
    }
    
    private func fetchData(isPull:Bool = false) {
        
        if !isPull {
            activityIndicator.startAnimating()
        }
        
        googlePlacesManager.getCurrentPlace() { (coordinate, formattedAddress, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    let banner = StatusBarNotificationBanner(title: "Error receiving current place address", style: .danger)
                    banner.show()
                    self.refreshControl.endRefreshing()
                    if !isPull {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
            else {
                if let current = self.currentPlace {
                    current.coordinate = coordinate!
                    current.name = formattedAddress ?? "Unknown"
                }
                else {
                    self.currentPlace = Place(coordinate: coordinate!, name: formattedAddress ?? "Unknown")
                    
                    if !self.places.contains{$0 === self.currentPlace!} {
                        self.places.insert(self.currentPlace!, at:0)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tbPlaces.reloadData()
                }
                
                WebAPI.getSunInfoForCoordinate(self.currentPlace!.coordinate, completionHandler: { (sunInfoResults, error) in
                    self.currentPlace?.sunInfoResults = sunInfoResults
                    DispatchQueue.main.async {
                        self.tbPlaces.reloadData()
                        self.refreshControl.endRefreshing()
                        if !isPull {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddPlaceViewController" {
            if let vc = segue.destination as? AddPlaceViewController
            {
                vc.delegate = self
            }
        }
    }
}

extension PlacesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status {
        case .notDetermined:
            fetchData()
            break
        case .authorizedWhenInUse:
            fetchData()
            break
        case .authorizedAlways:
            fetchData()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
}

extension PlacesViewController: AddPlaceViewControllerDelegate {
    func addPlace(coordinate: CLLocationCoordinate2D, name: String?) {
        let place = Place(coordinate: coordinate, name: name)
        
        self.places.append(place)
        
        DispatchQueue.main.async {
            self.tbPlaces.reloadData()
            self.activityIndicator.startAnimating()
        }
        
        WebAPI.getSunInfoForCoordinate(place.coordinate, completionHandler: { (sunInfoResults, error) in
            place.sunInfoResults = sunInfoResults
            DispatchQueue.main.async {
                self.tbPlaces.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            }
        })
    }
}

extension PlacesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow to remove except current location
        return indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.identifier, for: indexPath)
        if let placeCell = cell as? PlaceCell
        {
            placeCell.place = self.places[indexPath.row]
        }
        return cell
    }
}
