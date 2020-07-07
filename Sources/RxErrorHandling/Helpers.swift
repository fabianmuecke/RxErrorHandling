//
//  Helpers.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import Foundation

func rxFatalErrorInDebug(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
        fatalError(lastMessage(), file: file, line: line)
    #else
        print("\(file):\(line): \(lastMessage())")
    #endif
}
