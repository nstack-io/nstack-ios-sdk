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
            proposalsGrouped = Array(Dictionary(grouping: proposals, by: { $0.key }))
        } else {
            if let item = currentItem {
                proposals = proposals.filter({$0.section == item.translationIdentifier?.section && $0.key == item.translationIdentifier?.key})
            }
        }

        if proposals.isEmpty || proposalsGrouped.isEmpty {
            output?.setupEmptyCaseLabel()
        }

    }
}




// MARK: - User Events -

extension ProposalPresenter: ProposalPresenterInput {
    var numberOfSections: Int {
        return listingAllProposals ? proposalsGrouped.count : 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        return listingAllProposals ? proposalsGrouped[section].value.count : proposals.count
    }
    
    func configure(item: ProposalCellProtocol, in section: Int, for index: Int) {
        let text = listingAllProposals ? proposalsGrouped[section].value[index].value : proposals[index].value
        item.setTextLabel(with: text)
    }
    
    func titleForHeader(in section: Int) -> String? {
        return listingAllProposals ? proposalsGrouped[section].key : nil
    }
    
    func viewCreated() {
        setTitle()
    }
    
    func handle(_ action: Proposals.Action) {
        switch action {
        case .deleteProposal(let section, let index):
            let proposalToDelete = listingAllProposals ? proposalsGrouped[section].value[index] : proposals[index]
            interactor.perform(Proposals.Request.DeleteProposal(proposal: proposalToDelete))
        }
    }
    
    func setTitle() {
        if let keyTitle = proposals.first?.key {
            output?.setTitle("Proposals for \(keyTitle)")
        } else {
            output?.setTitle("Proposals")
        }
    }

}

// MARK: - Presentation Logic -

// INTERACTOR -> PRESENTER (indirect)
extension ProposalPresenter: ProposalInteractorOutput {

    func present(_ response: Proposals.Response.ProposalDeleted) {
        
    }
    
}
