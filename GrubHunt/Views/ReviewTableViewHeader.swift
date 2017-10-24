//
//  ReviewTableViewHeader.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/17/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
import HCSStarRatingView

protocol ReviewTableViewHeaderDelegate: class {
    var navController: UINavigationController? { get }
}

class ReviewTableViewHeader: UITableViewHeaderFooterView {

    static let identifier: String = "ReviewTableViewHeader"
    static let cellIdentifier: String = "imageCell"
    static let headerHeight: CGFloat = 350.0

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var addressCell: UIView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    weak var delegate: ReviewTableViewHeaderDelegate?
    var business: Business!
    var lastOrientation: UIDeviceOrientation? = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {
        guard containerView != nil else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewTableViewHeader.orientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ReviewTableViewHeader.cellIdentifier)

        updateButtons(for: 0)
    }
    
    override func prepareForReuse() {
        nameLabel.text = nil
        ratingView.value = 0
        numReviewsLabel.text = nil
        priceLabel.attributedText = nil
        categoryLabel.text = nil
        addressLabel.attributedText = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setup(with business: Business, andDelegate delegate: ReviewTableViewHeaderDelegate? = nil) {
        self.business = business
        self.delegate = delegate

        nameLabel.text = business.name
        ratingView.value = CGFloat(business.rating)
        numReviewsLabel.text = (business.reviewCount == 0) ? nil : "(\(business.reviewCount) reviews)"

        if let price = business.price, price.count > 0 && price.count < 5 {
            let attributedString = NSMutableAttributedString(string: price, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
            priceLabel.text = price
            let charactersLeft = 4 - price.count
            for _ in 0 ..< charactersLeft {
                attributedString.append(NSAttributedString(string: "$", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            }
            priceLabel.attributedText = attributedString
        } else {
            priceLabel.attributedText = nil
        }

        categoryLabel.text = ""
        for element in business.categories.allObjects {
            guard let category = element as? Category, let title = category.title, !title.isEmpty else { continue }
            if categoryLabel.text!.isEmpty {
                categoryLabel.text = categoryLabel.text! + "\(title)"
            } else {
                categoryLabel.text = categoryLabel.text! + ", \(title)"
            }
        }

        if let _ = business.coordinates {
            var addressString = ""
            let address = business.address
            if let line1 = address?.addressLine1 {
                addressString = line1
                if let city = address?.city {
                    addressString.append(", \(city)")
                }
                if let state = address?.state {
                    addressString.append(", \(state)")
                }
                if let zipcode = address?.zipCode {
                    addressString.append(" \(zipcode)")
                }
            } else {
                let businessName = (business.name != nil) ? "to \(business.name!)" : ""
                addressString = "Get Directions \(businessName)"
            }
            addressLabel.attributedText = NSMutableAttributedString(string: addressString, attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            addressCell.isHidden = false
        } else {
            addressLabel.attributedText = nil
            addressCell.isHidden = true
        }

        updateButtons(for: 0)
        imagesCollectionView.reloadData()
    }

    func updateButtons(for page: Int) {
        guard business != nil, let photos = business.photos else { return }
        backButton.isEnabled = (page > 0)
        backButton.tintColor = (backButton.isEnabled) ? .black : .lightGray
        nextButton.isEnabled = (page < photos.count - 1)
        nextButton.tintColor = (nextButton.isEnabled) ? .black : .lightGray
    }
    
    @IBAction func addressButtonPressed(_ sender: Any) {
        guard let coordinates = business.coordinates, let delegate = delegate, let navController = delegate.navController else { return }
        let addressName = business.name ?? ""
        let alert = UIAlertController(title: "Directions to \(addressName)", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        let google = UIAlertAction(title: "Google Maps", style: .default) { _ in
            // Access to Google Maps
            if let url = URL(string: "comgooglemaps-x-callback://"), UIApplication.shared.canOpenURL(url) {
                // Google Maps is installed. Launch Google Maps and start navigation
                let directionsRequest = "comgooglemaps://?daddr=\(coordinates.latitude),\(coordinates.longitude)" + "&x-success=sourceapp://?resume=true&x-source=AirApp"
                if let directionsURL = URL(string: directionsRequest) {
                    UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
                }
            } else {
                // Google Maps is not installed. Launch AppStore to install Waze app
                if let appstoreUrl = URL(string: "http://itunes.apple.com/us/app/id585027354") {
                    UIApplication.shared.open(appstoreUrl, options: [:], completionHandler: nil)
                }
            }
        }
        alert.addAction(google)
        
        let apple = UIAlertAction(title: "Apple Maps", style: .default) { _ in
            let regionDistance:CLLocationDistance = 10000
            let coords = CLLocationCoordinate2DMake(CLLocationDegrees(coordinates.latitude), CLLocationDegrees(coordinates.longitude))
            let regionSpan = MKCoordinateRegionMakeWithDistance(coords, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coords, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = addressName
            mapItem.openInMaps(launchOptions: options)
        }
        alert.addAction(apple)
        
        let waze = UIAlertAction(title: "Waze", style: .default) { _ in
            // Access to Waze
            if let url = URL(string: "waze://"), UIApplication.shared.canOpenURL(url) {
                // Waze is installed. Launch Waze and start navigation
                let directionsRequest = "waze://?ll=\(coordinates.latitude),\(coordinates.longitude)&navigate=yes"
                if let directionsURL = URL(string: directionsRequest) {
                    UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
                }
            } else {
                // Waze is not installed. Launch AppStore to install Waze app
                if let appstoreUrl = URL(string: "http://itunes.apple.com/us/app/id323229106") {
                    UIApplication.shared.open(appstoreUrl, options: [:], completionHandler: nil)
                }
            }
        }
        alert.addAction(waze)
        
        navController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        guard business != nil, let _ = business.photos else { return }
        let currentPage = Int(imagesCollectionView.contentOffset.x / imagesCollectionView.frame.width)
        guard currentPage > 0 else { return }
        imagesCollectionView.scrollToItem(at: IndexPath(item: currentPage - 1, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
        updateButtons(for: currentPage - 1)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        guard business != nil, let photos = business.photos else { return }
        let currentPage = Int(imagesCollectionView.contentOffset.x / imagesCollectionView.frame.width)
        guard currentPage < photos.count - 1 else { return }
        imagesCollectionView.scrollToItem(at: IndexPath(item: currentPage + 1, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
        updateButtons(for: currentPage + 1)
    }

    @objc func orientationDidChange(_ notification: Notification) {
        guard containerView != nil else { return }
        guard let flowLayout = imagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let orientation = UIDevice.current.orientation
        flowLayout.invalidateLayout()
        if let lastOrientation = lastOrientation, orientation != lastOrientation, !orientation.isFlat, !lastOrientation.isFlat {
            imagesCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        lastOrientation = orientation
        updateButtons(for: 0)
    }
}

extension ReviewTableViewHeader: UIScrollViewDelegate {

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        updateButtons(for: currentPage)
    }
}

extension ReviewTableViewHeader: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension ReviewTableViewHeader: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return business.photos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewTableViewHeader.cellIdentifier, for: indexPath)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        if let urlString = business.photos?[indexPath.item], let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        cell.addSubview(imageView)
        cell.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            ])
        return cell
    }
}
