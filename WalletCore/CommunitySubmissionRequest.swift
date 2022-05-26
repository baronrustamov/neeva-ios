// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine
import Foundation
import Shared

public class TrustSignalRequest: MutationRequest<ReportDomainTrustSignalMutation> {
    public init(url: URL, trusted: Bool) {
        super.init(
            mutation: ReportDomainTrustSignalMutation(
                input: ReportDomainTrustSignalInput(
                    domain: url.baseDomain, signal: trusted ? .trusted : .malicious
                )))
    }
}

public let web3Extensions = [".io", ".xyz", ".com", ".art"]

public typealias DomainTrustSignal = GetDomainTrustSignalsQuery.Data.XyzDomainTrustSignal

public class TrustSignalController: QueryController<GetDomainTrustSignalsQuery, [DomainTrustSignal]>
{

    public override class func processData(_ data: GetDomainTrustSignalsQuery.Data)
        -> [DomainTrustSignal]
    {
        data.xyzDomainTrustSignals ?? []
    }

    @discardableResult static func getTrustSignals(
        domains: [String],
        completion: @escaping (Result<[DomainTrustSignal], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(
            query: GetDomainTrustSignalsQuery(
                input: DomainTrustSignalsInput(domains: domains)),
            completion: completion
        )
    }

    @discardableResult public static func getTrustSignals(
        domain: String,
        completion: @escaping (Result<[DomainTrustSignal], Error>) -> Void
    ) -> Combine.Cancellable {
        var domains = [domain]
        if let index = domain.lastIndex(of: ".") {
            domains.append(
                contentsOf: web3Extensions.map({ String(domain.prefix(upTo: index)) + $0 }))
        }

        return getTrustSignals(domains: domains, completion: completion)
    }
}
