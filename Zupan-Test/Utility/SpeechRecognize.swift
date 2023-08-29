//
//  SpeechRecognize.swift
//  Zupan-Test
//
//  Created by Darshan Gajera on 28/08/23.
//

import Foundation
import Speech
import AVKit

class VoiceRecognitionManager {
    
    //MARK: Private properties
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private let stopTimerSeconds = 5.0
    private var recognitionTask: SFSpeechRecognitionTask?
    private var activationCommands: [Command] = []
    
    //MARK: Public properties
    public var activeCommand: Command?
    public var finalSpeechAndCommand: ((Bool, Command?, String?) -> ())?
    public var activeSpeech: ((String?) -> ())?
    public var speech: String?
    public var stopTimer = Timer()
    
    //MARK: Life Cycle
    init(activationCommands: [Command]) {
        self.activationCommands = activationCommands
    }

    //MARK: Methods
    public func startRecognition() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                self.startAudioEngine()
            }
        }
    }
    
    public func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        recognitionTask?.cancel()
    }

    private func startAudioEngine() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            request.shouldReportPartialResults = true
            recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
                
                var isFinal = false
                if let result = result {
                    
                    self?.resetTimer()
                    let recognizedText = result.bestTranscription.formattedString
                    isFinal = result.isFinal

                    // active command speech
                    if self?.activeCommand != nil {
                        self?.speech = recognizedText
                        self?.activeSpeech?("\(self?.activeCommand?.rawValue ?? "") " + recognizedText)
                    }
                    
                    //  found new command
                    if let command = self?.isActivationCommand(recognizedText) {
                        if self?.activeCommand == nil {
                            self?.activeCommand = command
                            self?.finalSpeechAndCommand?(false, self?.activeCommand, command.rawValue)
                            self?.restartRecognise()
                        }
                    }
                    
                    // final segment
                    if error != nil || isFinal {
                        debugPrint("speech done")
                        self?.finalSpeechAndCommand?(true, self?.activeCommand, recognizedText)
                        self?.activeCommand = nil
                        self?.restartRecognise()
                    }
                } else if let error = error {
                    debugPrint(error.localizedDescription)
                }
            }
        } catch {
            // Handle errors
        }
    }
    
    private func resetTimer() {
        stopTimer.invalidate()
        stopTimer = Timer.scheduledTimer(withTimeInterval: stopTimerSeconds, repeats: false) { [weak self] timer in
            self?.stopTimer.invalidate()
            self?.stopTimerCalled()
        }
    }
    
    private func stopTimerCalled() {
        finalSpeechAndCommand?(true, activeCommand, self.speech)
        self.speech = ""
        activeCommand = nil
        restartRecognise()
    }
    
    private func restartRecognise() {
        self.stopRecognition()
        self.startAudioEngine()
    }
    
    private func isActivationCommand(_ text: String) -> Command? {
        for command in activationCommands {
            if text.lowercased().contains(command.rawValue.lowercased()) {
                return command
            }
        }
        return nil
    }
    
    private func commandDescription(isDetectNewCommand: Bool = true, _ description: String) -> String {
        if isDetectNewCommand {
            return description.components(separatedBy: " ").dropLast().joined(separator: " ")
        }
        return description
    }
}
