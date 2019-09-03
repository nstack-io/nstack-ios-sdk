//
//  ProposalModel.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 06/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

enum Proposals {
    enum Request { }
    enum Response { }
    enum DisplayData { }

    enum Action {
        case deleteProposal(section: Int, index: Int)
    }

    enum Route {
    }
}

extension Proposals.Request {
    struct DeleteProposal {
        let proposal: Proposal
    }
}

extension Proposals.Response {
    struct ProposalDeleted {
        let success: Bool
    }
}

extension Proposals.DisplayData {
}
