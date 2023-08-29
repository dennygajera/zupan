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
    private let strings = InputListViewModel.Constant.self
    
    @IBOutlet weak var inputStack: UIStackView?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var speechLabel: UILabel?
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            tableView?.register(UINib(nibName: "CommandCell", bundle: .main), forCellReuseIdentifier: CommandCell.reuseIdentifier)
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startVoiceRecognizer()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        inputStack?.layer.cornerRadius = 5.0
        inputStack?.layer.masksToBounds = true
        setLabelUI(statusLabel)
        setLabelUI(speechLabel)
    }
    
    private func setLabelUI(_ label: UILabel?) {
        label?.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        label?.layer.masksToBounds = true
        label?.layer.cornerRadius = 5.0
    }
    
    private func bind() {
        viewModel.$speech.sink(receiveValue: { [weak self] speech in
            if speech != nil {
                self?.speechLabel?.text = speech
            }
        }).store(in: &cancellables)
        
        viewModel.$currentState.sink(receiveValue: { [unowned self] currentState in
            let command = viewModel.activeCommand
            statusLabel?.text = currentState == .listening ? "\(strings.activeCommand): \(command)" : strings.waitingForCommand
            statusLabel?.backgroundColor = currentState == .listening ? UIColor.green : UIColor.red
            if currentState == .waiting {speechLabel?.text = "" }
        }).store(in: &cancellables)
        
        viewModel.reloadList = {
            self.tableView?.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.noOfCommands
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommandCell.reuseIdentifier, for: indexPath) as? CommandCell else { return UITableViewCell() }
        let commandData = viewModel.dataForCell(at: indexPath)
        cell.setData(commandData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


