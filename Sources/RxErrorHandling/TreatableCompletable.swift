//
//  TreatableCompletable.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension CompletableTrait: PrimitiveTreatableTrait {}

public typealias TreatableCompletable<Failure: Swift.Error> = TreatableSequence<CompletableTrait,
                                                                                Swift.Never,
                                                                                Failure>
