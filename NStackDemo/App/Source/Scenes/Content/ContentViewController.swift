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

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Callbacks -
    @IBAction func getContentResponseButtonTapped(_ sender: Any) {
        getContentResponse()
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
}
