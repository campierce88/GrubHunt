//
//  SearchResultTableViewCell.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import UIKit
import SDWebImage
import HCSStarRatingView

class SearchResultCollectionViewCell: UICollectionViewCell {

    static let viewMargin: CGFloat = 16
    static let cellPadding: CGFloat = 10
    static let cellWidthPortrait: CGFloat = (UIScreen.main.bounds.width - (cellPadding * 3) - (viewMargin * 2)) / 3
    static let cellHeightPortrait = cellWidthPortrait + 60
    static let cellWidthLandscape: CGFloat = (UIScreen.main.bounds.width - (cellPadding * 3) - (viewMargin * 2)) / 3
    static let cellHeightLandscape = cellWidthLandscape + 60
    static let identifier = "SearchResultCollectionViewCell"

    override var reuseIdentifier: String? {
        get {
            return SearchResultCollectionViewCell.identifier
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!

    var result: Business!

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
        if containerView != nil {
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 4.0
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = nil
        imageView.image = nil
    }

    func setup(with result: Business) {
        self.result = result

        nameLabel.text = result.name
        if let urlString = result.imageUrl, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        ratingView.value = CGFloat(result.rating)
    }
}
