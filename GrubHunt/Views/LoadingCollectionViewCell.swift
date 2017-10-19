//
//  NoResultsTableViewCell.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import UIKit

class LoadingCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "LoadingCollectionViewCell"

    override var reuseIdentifier: String? {
        get {
            return LoadingCollectionViewCell.identifier
        }
    }

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {
        activityIndicator.tintColor = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.removeFromSuperview()
        addSubview(activityIndicator)
        addConstraints([
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)
            ])
        activityIndicator.hidesWhenStopped = true
    }
}
