//
//  ProposalInteractor.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 06/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

class ProposalInteractor {
    // MARK: - Properties
    weak var output: ProposalInteractorOutput?
    private let nstackSharedInstance: NStack?

    // MARK: - Init
    init(nstackSharedInstance: NStack) {
        self.nstackSharedInstance = nstackSharedInstance
    }
}

// MARK: - Business Logic -

// PRESENTER -> INTERACTOR
extension ProposalInteractor: ProposalInteractorInput {
    func perform(_ request: Proposals.Request.DeleteProposal) {
        nstackSharedInstance?.deleteProposal(request.proposal, completion: { (result) in
            switch result {
            case .success:
                self.output?.present(Proposals.Response.ProposalDeleted(success: true))
            case .failure:
                self.output?.present(Proposals.Response.ProposalDeleted(success: false))
            }
        })
    }

}
