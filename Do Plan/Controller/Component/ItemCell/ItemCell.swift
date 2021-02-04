//
//  ItemCellTableViewCell.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/6/1399 AP.
//

import UIKit

class ItemCell: UITableViewCell {
    static let identifier = "ItemCell"

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var doneCircle: UIImageView!
    @IBOutlet weak var priorityIcon: UIImageView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
