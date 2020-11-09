//
//  ContentViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 09.11.20.
//

import UIKit
import NStackSDK
import LocalizationManager

struct ContentResponse: Codable {
    let firstName: String
    let lastName: String
    let emailAddress: String
}

struct CollectionResponse: Codable {
    let title: String
    let description: String
    let price: Float
}

class ContentViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var getContentResponseButton: UIButton! {
        didSet {
            getContentResponseButton.setTitle(tr.content.contentResponseButtonTitle, for: .normal)
        }
    }

    @IBOutlet weak var showContentResponseLabel: UILabel! {
        didSet {
            showContentResponseLabel.text = ""
            showContentResponseLabel.numberOfLines = 0
        }
    }

    @IBOutlet weak var fetchCollectionResponseButton: UIButton! {
        didSet {
            fetchCollectionResponseButton.setTitle(tr.content.collectionResponseButtonTitle, for: .normal)
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    

    // MARK: - Properties
    private var availableProducts: [CollectionResponse] = []

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Callbacks -
    @IBAction func getContentResponseButtonTapped(_ sender: Any) {
        getContentResponse()
    }

    @IBAction func fetchCollectionResponseButtonTapped(_ sender: Any) {
        fetchCollectionResponse()
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ContentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tr.content.availableProducts
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableProducts.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let availableProductCell = tableView.dequeueReusableCell(withIdentifier: "AvailableProductCell");
        availableProductCell?.textLabel?.numberOfLines = 0
        availableProductCell?.textLabel?.text =
            """
            Title - \(availableProducts[indexPath.row].title)
            Description - \(availableProducts[indexPath.row].description)
            Price - \(availableProducts[indexPath.row].price)
            """
        availableProductCell?.selectionStyle = .none
        return availableProductCell!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return availableProducts.count > 0 ? 44.0 : 0
    }
}

// MARK: - API call
extension ContentViewController {
    private func getContentResponse() {
        NStack.sharedInstance.contentManager?.getContentResponse("test", completion: { (result: Result<ContentResponse>) in
            _ = result.map({ response -> Void in
                DispatchQueue.main.async {
                    self.showContentResponseLabel.text =
                        """
                        firstName - \(response.firstName)
                        lastName - \(response.lastName)
                        emailAddress - \(response.emailAddress)
                        """
                }
            })

        })
    }

    func fetchCollectionResponse() {
        NStack.sharedInstance.contentManager?.fetchCollectionResponse(for: 67, completion: { (result: Result<[CollectionResponse]>) in

            _ = result.map({ (response) -> Void in
                self.availableProducts.removeAll()
                self.availableProducts.append(contentsOf: response)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        })
    }
}
