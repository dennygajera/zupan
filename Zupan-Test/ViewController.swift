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
            if commandList != nil {
                print(commandList)
            }
        }).store(in: &cancellables)
    }
    
}


