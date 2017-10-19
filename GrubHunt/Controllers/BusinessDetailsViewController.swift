//
//  BusinessDetailsViewController.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class BusinessDetailsViewController: UIViewController {

    static let identifier = "BusinessDetailsViewController"

    static func instantiate(with business: Business) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as! BusinessDetailsViewController
        viewController.business = business
        return viewController
    }

    var business: Business!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: ReviewTableViewHeader.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: ReviewTableViewHeader.identifier)
        tableView.register(UINib(nibName: ReviewTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ReviewTableViewCell.identifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        loadBusinessDetails(for: business)
        loadReviews(for: business)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadBusinessDetails(for business: Business) {
        guard let businessId = business.id else { return }
        BusinessAPI().getBusinessDetails(for: businessId, completion: { (business) in
            self.tableView.reloadData()
        }, failure: { (response, error) in
            print("failed")
        })
    }

    func loadReviews(for business: Business) {
        ReviewsAPI().getReviews(for: business, completion: { (reviews) in
            self.tableView.reloadData()
        }, failure: { (response, error) in
            print("failed")
        })
    }
}

extension BusinessDetailsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return business.reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviews = business.reviews.allObjects
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.identifier, for: indexPath) as? ReviewTableViewCell, indexPath.item < reviews.count, let review = reviews[indexPath.item] as? Review {
            cell.setup(with: review)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension BusinessDetailsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return .leastNormalMagnitude }
        return ReviewTableViewHeader.headerHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReviewTableViewHeader.identifier) as? ReviewTableViewHeader, section == 0 else {
            return UITableViewHeaderFooterView()
        }
        headerView.setup(with: business)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do nothing for now. Ideally given more time this would take you to a detailed view of the raiting
    }
}
