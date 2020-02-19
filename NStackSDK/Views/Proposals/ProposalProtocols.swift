//
//  ProposalProtocols.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 06/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

// ======== Interactor ======== //

// PRESENTER -> INTERACTOR
protocol ProposalInteractorInput {
    func perform(_ request: Proposals.Request.DeleteProposal)
}

// INTERACTOR -> PRESENTER (indirect)
protocol ProposalInteractorOutput: class {
    func present(_ response: Proposals.Response.ProposalDeleted)
}

// ======== Presenter ======== //

// VIEW -> PRESENTER
protocol ProposalPresenterInput {
    func viewCreated()
    func handle(_ action: Proposals.Action)
    var numberOfSections: Int { get }
    func numberOfRows(in section: Int) -> Int
    func configure(item: ProposalCellProtocol, in section: Int, for index: Int)
    func titleForHeader(in section: Int) -> String?
    func canDeleteProposal(in section: Int, for index: Int) -> Bool
}

// PRESENTER -> VIEW
protocol ProposalPresenterOutput: class {
    func setupEmptyCaseLabel()
    func setTitle(_ titleString: String)
}
