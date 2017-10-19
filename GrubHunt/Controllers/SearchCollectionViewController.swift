//
//  ViewController.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class SearchCollectionViewController: UIViewController {

    static let identifier = "SearchCollectionViewController"

    static func instantiate() -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as! SearchCollectionViewController
        return viewController
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noResultsLabel: UILabel!

    var searchBar: UISearchBar!
    var refreshControl: UIRefreshControl!
    var searchResults = [Business]()
    var searchPosibileResults = 0
    var currentSearchText: SearchTerm?
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = " "

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Whatcha looking for?"

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        collectionView.addSubview(refreshControl)

        let locationBarButton = UIBarButtonItem(title: "Find Near Me", style: .done, target: self, action: #selector(locationSearchButtonPressed(_:)))
        locationBarButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 100), for: UIBarMetrics.defaultPrompt)
        navigationItem.rightBarButtonItem = locationBarButton

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .otherNavigation
        checkLocationPermissions()
        locationManager.startUpdatingLocation()

        collectionView.register(UINib(nibName: SearchResultCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchResultCollectionViewCell.identifier)
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: LoadingCollectionViewCell.identifier)

        // Fetch last results from CoreData
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            searchResults = appDelegate.fetchBusinessesSearchResults()
            noResultsLabel.isHidden = !searchResults.isEmpty
            if let lastSearchTerm = appDelegate.fetchSearchHistory().last {
                currentSearchText = lastSearchTerm
                searchPosibileResults = Int(lastSearchTerm.totalResults)
                searchBar.text = currentSearchText?.term ?? ""
                if (searchBar.text ?? "").isEmpty {
                    searchBar.becomeFirstResponder()
                }
            }
            collectionView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    func loadSearchResults(offset: Int? = nil) {
        guard let location = currentLocation, let term = searchBar.text else {
            searchPosibileResults = 0
            updated(searchResults: [])
            return
        }

        noResultsLabel.isHidden = true
        SearchAPI().searchBusinesses(with: term, and: location, offset: offset, completion: { (businesses, totalResults) in
            self.saveNewSearch(with: term, totalResults: totalResults)
            self.searchPosibileResults = totalResults
            self.updated(searchResults: businesses)
        }, failure: { (response, error) in
            self.saveNewSearch()
            self.searchPosibileResults = 0
            self.updated(searchResults: [])
        })
    }

    func clearSearchResults() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.clearBusinessesSearchResults()
        searchPosibileResults = 0
        searchResults = []
        noResultsLabel.isHidden = !searchResults.isEmpty
        saveNewSearch()
    }

    @objc func refreshCollectionView(_ sender: Any) {
        locationSearchButtonPressed(sender)
    }

    @objc func locationSearchButtonPressed(_ sender: Any) {
        clearSearchResults()
        searchBar.resignFirstResponder()
        checkLocationPermissions()
        if let _ = currentLocation {
            loadSearchResults()
        } else {
            let alert = UIAlertController(title: "Couldn't Determine Location", message: "We could not determine your current location. Please check your location settings for this app and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    func saveNewSearch(with term: String = "", totalResults total: Int = 0) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: SearchTerm.identifier, in: managedContext) {
            let searchTerm = SearchTerm(entity: entity, insertInto: managedContext)
            searchTerm.term = term
            searchTerm.totalResults = Int64(total)
            appDelegate.saveContext()
            currentSearchText = searchTerm
        }
    }
}

// MARK: Colleciton View Updating
extension SearchCollectionViewController {

    func updated(searchResults results: [Business]) {
        for result in results {
            if !searchResults.contains(where: { $0.id == result.id }) {
                searchResults.append(result)
            }
        }
        refreshControl.endRefreshing()
        noResultsLabel.isHidden = !searchResults.isEmpty
        collectionView.reloadData()
    }
}

extension SearchCollectionViewController: CLLocationManagerDelegate {
    
    // This is a helper method, not a delegate method
    func checkLocationPermissions() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            return
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            let alert = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to find local businesses near you, please open this app's settings and set the location access to 'When In Use'.",
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let openAction = UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            alert.addAction(cancelAction)
            alert.addAction(openAction)
            present(alert, animated: true, completion: nil)
        }
    }

    // Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location
    }
}

extension SearchCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewMargin = SearchResultCollectionViewCell.viewMargin
        return UIEdgeInsets(top: viewMargin, left: viewMargin, bottom: viewMargin, right: viewMargin)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SearchResultCollectionViewCell.cellPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SearchResultCollectionViewCell.cellPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            return CGSize(width: SearchResultCollectionViewCell.cellWidthLandscape, height: SearchResultCollectionViewCell.cellHeightLandscape)
        } else {
            return CGSize(width: SearchResultCollectionViewCell.cellWidthPortrait, height: SearchResultCollectionViewCell.cellHeightPortrait)
        }
    }
}

extension SearchCollectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let loadingCell = (searchPosibileResults > searchResults.count) ? 1 : 0
        return searchResults.count + loadingCell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Loading Cell
        if indexPath.item >= searchResults.count, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionViewCell.identifier, for: indexPath) as? LoadingCollectionViewCell {
            loadSearchResults(offset: searchResults.count)
            cell.activityIndicator.startAnimating()
            return cell
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.identifier, for: indexPath) as? SearchResultCollectionViewCell {
            cell.setup(with: searchResults[indexPath.item])
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension SearchCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SearchResultCollectionViewCell, let business = cell.result else { return }

        searchBar.resignFirstResponder()
        navigationController?.pushViewController(BusinessDetailsViewController.instantiate(with: business), animated: true)
        navigationItem.titleView = nil
    }
}

extension SearchCollectionViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        locationSearchButtonPressed(searchBar)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            clearSearchResults()
            collectionView.reloadData()
        }
    }
}
