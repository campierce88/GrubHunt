//
//  ReviewTableViewHeader.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/17/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import UIKit
import SDWebImage
import HCSStarRatingView

class ReviewTableViewHeader: UITableViewHeaderFooterView {

    static let identifier: String = "ReviewTableViewHeader"
    static let cellIdentifier: String = "imageCell"
    static let headerHeight: CGFloat = 350.0

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setup(with business: Business) {
        self.business = business

        nameLabel.text = business.name
        ratingView.value = CGFloat(business.rating)
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
