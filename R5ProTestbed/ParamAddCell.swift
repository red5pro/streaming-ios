//
//  ParamAddCell.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 4/14/22.
//  Copyright © 2022 Infrared5. All rights reserved.
//

import UIKit

class ParamAddCell : UITableViewCell {
    
    var delegate: ParamCellDelegate?
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func onAdd (_ sender: Any) {
        self.delegate?.addNewCell()
    }
    
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
    }
    
}

extension ParamAddCell {
    
    func configure (_ delegate: ParamCellDelegate) {
        self.delegate = delegate
    }
    
}
