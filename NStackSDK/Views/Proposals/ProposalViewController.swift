//
//  ProposalViewController.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 02/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import UIKit

class ProposalViewController: UIViewController {

    // MARK: - Properties
    private var presenter: ProposalPresenterInput!

    var tableView: UITableView?

    // MARK: - Init
    public func instantiate(with presenter: ProposalPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addCloseButton()
        presenter.viewCreated()
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
}

extension ProposalViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proposalCell", for: indexPath)
        presenter.configure(item: cell, in: indexPath.section, for: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.titleForHeader(in: section)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if presenter.canDeleteProposal(in: indexPath.section, for: indexPath.row) {
            return true
        }
        return false
    }

    // MARK: Swipe actions for +iOS 11
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = setupAction(forRowAt: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }

    @available(iOS 11.0, *)
    private func setupAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") {(_: UIContextualAction, _: UIView, completionHandler: @escaping (Bool) -> Void) in
            self.presenter.handle(.deleteProposal(section: indexPath.section, index: indexPath.row))
            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        action.backgroundColor = .red
        return action
    }
}

// PRESENTER -> VIEW
extension ProposalViewController: ProposalPresenterOutput {

    func setTitle(_ titleString: String) {
        title = titleString
    }

    func setupEmptyCaseLabel() {
        if let tableView = tableView {
            let emptyLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width - 40, height: tableView.bounds.size.height))
            emptyLabel.text = "No proposals to show"
            emptyLabel.textAlignment = .center
            tableView.backgroundView = emptyLabel
        }
    }
}
