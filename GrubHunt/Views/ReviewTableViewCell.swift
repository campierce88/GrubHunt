//
//  ReviewTableViewCell.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import UIKit
import SDWebImage
import HCSStarRatingView

class ReviewTableViewCell: UITableViewCell {

    static let identifier = "ReviewTableViewCell"

    override var reuseIdentifier: String? {
        get {
            return ReviewTableViewCell.identifier
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var reviewTimestampLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!

    var review: Review!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {
        selectionStyle = .none
        backgroundColor = .clear

        if containerView != nil {
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 4.0
            containerView.layer.borderColor = UIColor.lightGray.cgColor
            containerView.layer.borderWidth = 1.0

            userImageView.layer.masksToBounds = true
            userImageView.layer.cornerRadius = 4.0
        }
    }

    override func prepareForReuse() {
        userNameLabel.text = nil
        userImageView.image = nil
        reviewTimestampLabel.text = nil
        commentTextView.text = ""
    }

    func setup(with review: Review) {
        self.review = review

        userNameLabel.text = review.user?.name
        if let urlString = review.user?.imageUrl, let url = URL(string: urlString) {
            userImageView.sd_setImage(with: url, completed: nil)
        }
        commentTextView.text = review.text ?? ""
        ratingView.value = CGFloat(review.rating)

        let nowTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        if let reviewCreationString = review.creationTime, let creationTime = dateFormatter.date(from: reviewCreationString) {
            reviewTimestampLabel.text = nowTime.offset(from: creationTime, useLongString: true)
        } else {
            reviewTimestampLabel.text = nil
        }
    }
}
