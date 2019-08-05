//
//  ProposalViewController.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 02/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import UIKit

class ProposalViewController: UIViewController {

    var tableView: UITableView?
    var proposals: [Proposal] = []
    var proposalsGrouped: [(key: String, value: [Proposal])] = []
    var listingAllProposals = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setupTableView()
        addCloseButton()
        
    }
    
    private func setTitle() {
        if let keyTitle = proposals.first?.key {
            title = "Proposals for \(keyTitle)"
        } else {
            title = "Proposals"
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        if let tableView = tableView {
            tableView.backgroundColor = .white
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "proposalCell")
            view.addSubview(tableView)
            
            if proposals.isEmpty || proposalsGrouped.isEmpty {
                setupTableViewBackgroundLabel()
            }
        }
    }
    
    private func addCloseButton() {
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItem  = closeButton
    }

    @objc
    private func close() {
        self.dismiss(animated: true, completion: nil)
    }

    func setupTableViewBackgroundLabel() {
        if let tableView = tableView {
            let emptyLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width - 40, height: tableView.bounds.size.height))
            emptyLabel.text = "No proposals to show"
            emptyLabel.textAlignment = .center
            tableView.backgroundView = emptyLabel
        }
    }
}

extension ProposalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listingAllProposals ? proposalsGrouped.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingAllProposals ? proposalsGrouped[section].value.count : proposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proposalCell", for: indexPath)
        cell.textLabel?.text = listingAllProposals ? proposalsGrouped[indexPath.section].value[indexPath.row].value : proposals[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listingAllProposals ? proposalsGrouped[section].key : nil
    }

}
