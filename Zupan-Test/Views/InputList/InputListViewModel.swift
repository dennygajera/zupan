//
//  InputListViewModel.swift
//  Zupan-Test
//
//  Created by Darshan Gajera on 28/08/23.
//

import Foundation
import Combine

enum Command: String, CaseIterable {
    case code = "code"
    case count = "count"
    case back = "back"
    case reset = "reset"
    
    static func activationCommands() -> [Command] {
        return [.code, .count, .back]
    }
}

enum State {
    case waiting
    case listening
}


class InputListViewModel {
    
    struct Constant {
        static let waitingForCommand = "Waiting for command"
        static let activeCommand = "Active Command"
        
    }
    
    //MARK: Private Properties
    private let voiceManager = VoiceRecognitionManager(activationCommands: Command.activationCommands())
    
    //MARK: Public Properties
    @Published public var speech: String?
    @Published public var currentState: State = .waiting
    public var commandList = [CommandInput]()
    public var activeCommand: String { voiceManager.activeCommand?.rawValue ?? "" }
    public var noOfCommands: Int { self.commandList.count }
    
    var reloadList: (()->())?
    
    //MARK: Methods
    func startVoiceRecognizer() {
        
        voiceManager.startRecognition()
        
        voiceManager.activeSpeech = { [weak self] activeSpeech in
            self?.speech = activeSpeech
            self?.currentState = .listening
        }
        
        voiceManager.finalSpeechAndCommand = { [weak self] isFinal, command, description in
            guard let command = command, let description = description else { return }
            if isFinal {
                self?.validateSpeech("\(command) " + description)
            } else {
                self?.speech = "\(command)"
            }
            self?.currentState = isFinal ? .waiting : .listening
        }
    }
    
    private func validateSpeech(_ speech: String) {
        var finalCommands = [CommandInput]()
        var commandObj = CommandInput()
        
        let speechWords = speech.components(separatedBy: " ")
        
        speechWords.enumerated().forEach { index, word in
            // check word is command or not
            if isCommand(word) {
                if commandObj.command != nil {
                    finalCommands.append(commandObj)
                }
                commandObj = CommandInput()
                commandObj.command = word
            } else {
                commandObj.value = (commandObj.value ?? "") + wordToInt(word)
            }
            
            if index == speechWords.count - 1 {
                finalCommands.append(commandObj)
            }
        }
        
        validateCommands(finalCommands)
    }
    
    private func validateCommands(_ commands: [CommandInput]) {
        commands.forEach { command in
            
            switch command.command?.lowercased() {
            case Command.code.rawValue:
                saveCommand(command)
                break
            case Command.count.rawValue:
                saveCommand(command)
                break
            case Command.reset.rawValue:
                removeLastCommand()
                break
            case Command.back.rawValue:
                removeLastCommand()
                break
            default:
                debugPrint("")
            }
        }
    }
    
    private func wordToInt(_ word: String) -> String {
        if Int(word) != nil { return word }
        guard let intVal = wordToNumber(word) else { return "" }
        return "\(intVal)"
    }
    
    //MARK: Command's Methods
    private func isCommand(_ word: String) -> Bool {
        return Command.allCases.filter { $0.rawValue.lowercased() == word.lowercased() }.count > 0
    }
    
    private func saveCommand(_ command: CommandInput) {
        guard let value = command.value, value.count > 0 else { return }
        commandList.append(command)
        reloadList?()
    }
    
    private func removeLastCommand() {
        commandList = commandList.dropLast()
        reloadList?()
    }
    
    func wordToNumber(_ word: String) -> Int? {
        let wordToNumberMapping: [String: Int] = [
            "zero": 0,
            "one": 1,
            "two": 2,
            "three": 3,
            "four": 4,
            "five": 5,
            "six": 6,
            "seven": 7,
            "eight": 8,
            "nine": 9
        ]
        
        return wordToNumberMapping[word.lowercased()]
    }

    //MARK: Cell Data
    func dataForCell(at indexPath: IndexPath) -> CommandInputViewModel {
        return CommandInputDataItem(commandList[indexPath.section])
    }
}
