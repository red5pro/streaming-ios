//
//  ParamCell.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 4/7/22.
//  Copyright © 2022 Infrared5. All rights reserved.
//

import UIKit

struct Param {
    var name = ""
    var value = ""
}

class ParamCell: UITableViewCell {
    
    var index: Int?
    var delegate: ParamCellDelegate?
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var valueInput: UITextField!
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup () {
        
//        self.contentView.addSubview(nameLabel)
//        nameLabel.text = "Name:"
//        self.contentView.addSubview(nameInput)
//
//        self.contentView.addSubview(valueLabel)
//        valueLabel.text = "Value:"
//        self.contentView.addSubview(valueInput)
//
//        self.contentView.addSubview(removeButton)
//        removeButton.setTitle("Remove", for: UIControl.State.normal)
    }
    
}

extension ParamCell: UITextFieldDelegate {
    
    func configure (_ delegate: ParamCellDelegate, name: String, value: String, index: Int) {
        self.delegate = delegate
        nameInput.text = name
        valueInput.text = value
        nameInput.delegate = self
        valueInput.delegate = self
        self.index = index
    }
    
    func getKV () -> Param {
        return Param(name: nameInput.text!, value: valueInput.text!)
    }
    
    func notifyUpdate () {
        self.delegate?.updateParamAt(param: getKV(), index: self.index!)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.nameInput.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        notifyUpdate()
        self.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        resignFirstResponder()
    }
    
}
