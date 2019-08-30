//
//  ProposalPresenter.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 06/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

class ProposalPresenter {
    // MARK: - Properties
    let interactor: ProposalInteractorInput
    weak var output: ProposalPresenterOutput?
    var proposals: [Proposal] = []
    var proposalsGrouped: [(key: String, value: [Proposal])] = []
    var listingAllProposals = false
    var currentItem: NStackLocalizable?

    // MARK: - Init
    init(interactor: ProposalInteractorInput,
         proposals: [Proposal],
         listingAllProposals: Bool, currentItem: NStackLocalizable? = nil) {

        self.interactor = interactor
        self.proposals = proposals
        self.listingAllProposals = listingAllProposals
        self.currentItem = currentItem

        setupList()
    }

    private func setupList() {
        if listingAllProposals {
            proposalsGrouped = Array(Dictionary(grouping: proposals, by: { $0.key })).sorted { (item1, item2) -> Bool in
                item1.key < item2.key
            }
        } else {
            if let item = currentItem {
                proposals = proposals.filter({$0.section == item.localizationItemIdentifier?.section && $0.key == item.localizationItemIdentifier?.key})
            }
        }
    }
}

// MARK: - User Events -

extension ProposalPresenter: ProposalPresenterInput {

    func canDeleteProposal(in section: Int, for index: Int) -> Bool {
        return listingAllProposals ? proposalsGrouped[section].value[index].canDelete : proposals[index].canDelete
    }

    var numberOfSections: Int {
        return listingAllProposals ? proposalsGrouped.count : 1
    }

    func numberOfRows(in section: Int) -> Int {
        return listingAllProposals ? proposalsGrouped[section].value.count : proposals.count
    }

    func configure(item: ProposalCellProtocol, in section: Int, for index: Int) {
        let proposal = listingAllProposals ? proposalsGrouped[section].value[index] : proposals[index]
        if proposal.canDelete {
            item.setTextColor(.blue)
        }
        item.setTextLabel(with: proposal.value)
    }

    func titleForHeader(in section: Int) -> String? {
        return listingAllProposals ? proposalsGrouped[section].key : nil
    }

    func viewCreated() {
        setTitle()
        checkIfEmpty()
    }

    func handle(_ action: Proposals.Action) {
        switch action {
        case .deleteProposal(let section, let index):
            let proposalToDelete = listingAllProposals ? proposalsGrouped[section].value[index] : proposals[index]
            interactor.perform(Proposals.Request.DeleteProposal(proposal: proposalToDelete))
        }
    }

    func setTitle() {
        if listingAllProposals {
            output?.setTitle("All proposals")
        } else {
            if let keyName = proposals.first?.key {
                output?.setTitle("Proposals for \(keyName)")
            } else {
                output?.setTitle("Proposals")
            }
        }
    }

    func checkIfEmpty() {
        if (proposals.isEmpty && !listingAllProposals) || (proposalsGrouped.isEmpty && listingAllProposals) {
            output?.setupEmptyCaseLabel()
        }
    }

}

// MARK: - Presentation Logic -

// INTERACTOR -> PRESENTER (indirect)
extension ProposalPresenter: ProposalInteractorOutput {

    func present(_ response: Proposals.Response.ProposalDeleted) {

    }

}
