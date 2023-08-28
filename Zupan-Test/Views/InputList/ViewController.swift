//
//  ViewController.swift
//  Zupan-Test
//
//  Created by Darshan Gajera on 28/08/23.
//

import UIKit
import Combine

class ViewController: UIViewController {

    var viewModel = InputListViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var speechLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startVoiceRecognizer()
        bind()
    }
    
    private func bind() {
        viewModel.$speech.sink(receiveValue: { [weak self] speech in
            if speech != nil {
                self?.speechLabel?.text = speech
            }
        }).store(in: &cancellables)
        
        
        viewModel.$commandList.sink(receiveValue: { [weak self] commandList in
                print(commandList)
        }).store(in: &cancellables)
        
        viewModel.$currentState.sink(receiveValue: { [weak self] currentState in
            if currentState != nil {
//                self?.statusLabel?.text = currentState.rawValue
                print(currentState)
            }
        }).store(in: &cancellables)
    }
    
}


