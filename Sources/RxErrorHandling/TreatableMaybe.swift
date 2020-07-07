//
//  TreatableMaybe.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension MaybeTrait: PrimitiveTreatableTrait {}

public typealias TreatableMaybe<Element, Failure: Swift.Error> = TreatableSequence<MaybeTrait,
                                                                                   Element,
                                                                                   Failure>
