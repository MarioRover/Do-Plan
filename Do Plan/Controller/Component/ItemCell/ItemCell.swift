//
//  ItemCellTableViewCell.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/6/1399 AP.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var doneCircle: UIImageView!
    @IBOutlet weak var priorityIcon: UIImageView!
    @IBOutlet weak var reminderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
