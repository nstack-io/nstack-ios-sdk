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

    let features = ["In-app Language picker"];
    
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
        return featureListViewCell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: "LanguageSelectionViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LanguageSelectionViewController") as? LanguageSelectionViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            break
        }
    }
}
