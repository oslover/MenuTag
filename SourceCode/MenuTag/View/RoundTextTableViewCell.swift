//
//  RoundTextTableViewCell.swift
//  MenuTag
//
//  Created by John David on 9/12/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

class RoundTextTableViewCell: UITableViewCell {
    var value: String!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutSubviews()
        self.roundContainer.layer.cornerRadius = roundContainer.frame.size.height/2
        self.roundContainer.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func resetWithText(text: String){
        self.value = text
        self.lblTitle.text = text + "?"
        let size = (self.value as NSString).sizeWithAttributes([NSFontAttributeName: self.lblTitle.font])
        
        self.trailingConstraint.constant = self.contentView.bounds.size.width - 34 - size.width
        self.roundContainer.layoutIfNeeded()
    }
}
