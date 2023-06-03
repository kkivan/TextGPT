//
//  Interpreter.swift
//  TextGPT
//
//  Created by Ivan Kvyatkovskiy on 27/03/2023.
//

import Foundation

struct Request {
    let textBefore: String
    let request: String
}

struct Recongnizer {
    func recognizeRequest(_ text: String) -> Request? {
        let comps = text.components(separatedBy: "/gpt")

        guard comps.count < 3 else {
            assertionFailure("multiple /gpt detected")
            return nil
        }
        if comps.count > 1 {
            if let last = comps.last?.trimmingCharacters(in: .controlCharacters) {
                return .init(textBefore: comps[0], request: last)
            }
        }
        return nil
    }
}
