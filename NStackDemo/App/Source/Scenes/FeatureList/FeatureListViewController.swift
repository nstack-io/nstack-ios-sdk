//
//  FeatureListViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 03.11.20.
//

import UIKit

class FeatureListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    let features = [tr.featureList.languagePicker, tr.featureList.feedback, tr.featureList.geography, tr.featureList.content];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension FeatureListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "NStack Features";
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
            storyboard = UIStoryboard(name: "GeographyViewController", bundle: nil)
            vc = storyboard?.instantiateViewController(identifier: "GeographyViewController") as! GeographyViewController
        case 3:
            storyboard = UIStoryboard(name: "ContentViewController", bundle: nil)
            vc = storyboard?.instantiateViewController(identifier: "ContentViewController") as! ContentViewController
        default:
            break
        }
        guard let viewController = vc else {
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
