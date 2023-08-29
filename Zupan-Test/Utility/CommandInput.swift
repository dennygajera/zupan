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

protocol CommandInputViewModel {
    var commandString: String {get}
    var commandValue: String {get}
}

class CommandInputDataItem: CommandInputViewModel {
    private var command: CommandInput!
    init(_ command: CommandInput) {
        self.command = command
    }
    
    var commandString: String {
        command.command ?? ""
    }
    
    var commandValue: String {
        command.value ?? ""
    }
}
