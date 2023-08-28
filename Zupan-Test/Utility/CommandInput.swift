//
//  CommandInput.swift
//  Zupan-Test
//
//  Created by Darshan Gajera on 28/08/23.
//

import Foundation

struct CommandInput {
    var command: String?
    var value: String?
}

enum State {
    case waiting
    case listening
}
