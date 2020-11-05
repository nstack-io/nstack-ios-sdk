//
//  FeatureListViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 03.11.20.
//

import UIKit

class FeatureListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    // MARK: - Properties
    let features = [tr.featureList.languagePicker, tr.featureList.feedback, tr.featureList.alertTypes];

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FeatureListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tr.featureList.title;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let featureListViewCell = tableView.dequeueReusableCell(withIdentifier: "FeatureListViewCell");
        featureListViewCell?.textLabel?.text = features[indexPath.row]
        featureListViewCell?.selectionStyle = .none
        return featureListViewCell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var storyboard: UIStoryboard?
        var vc: UIViewController?
        switch indexPath.row {
        case 0:
            storyboard = UIStoryboard(name: "LanguageSelectionViewController", bundle: nil)
            vc = storyboard?.instantiateViewController(identifier: "LanguageSelectionViewController") as! LanguageSelectionViewController
        case 1:
            storyboard = UIStoryboard(name: "FeedbackViewController", bundle: nil)
            vc = storyboard?.instantiateViewController(identifier: "FeedbackViewController") as! FeedbackViewController
        case 2:
            storyboard = UIStoryboard(name: "AlertViewController", bundle: nil)
            vc = storyboard?.instantiateViewController(identifier: "AlertViewController") as! AlertViewController
        default:
            break
        }
        guard let viewController = vc else {
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
