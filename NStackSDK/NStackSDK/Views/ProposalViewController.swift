//
//  ProposalViewController.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 02/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import UIKit

class ProposalViewController: UIViewController {

    var proposals: [Proposal] = []
    var proposalsGrouped: [[Proposal]] = [[]]
    var listingAllProposals = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let keyTitle = proposals.first?.key {
            title = "Proposals for \(keyTitle)"
        } else {
            title = "Proposals"
        }
        
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "proposalCell")
        view.addSubview(tableView)
        
        addCloseButton()
        
    }
    
    private func addCloseButton() {
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItem  = closeButton
    }

    @objc
    private func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ProposalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listingAllProposals ? proposalsGrouped.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingAllProposals ? proposalsGrouped[section].count : proposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proposalCell", for: indexPath)
        cell.textLabel?.text = proposals[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

}
