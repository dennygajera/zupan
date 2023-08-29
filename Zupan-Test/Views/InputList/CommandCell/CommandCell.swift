//
//  CommandCell.swift
//  Zupan-Test
//
//  Created by Darshan Gajera on 29/08/23.
//

import UIKit

class CommandCell: UITableViewCell {
    
    static let reuseIdentifier = "CommandCell"
    @IBOutlet weak var commandLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setData(_ commandInput: CommandInputViewModel) {
        commandLabel?.text = "Command: " + commandInput.commandString
        valueLabel?.text = "Value: " + commandInput.commandValue
    }
}
