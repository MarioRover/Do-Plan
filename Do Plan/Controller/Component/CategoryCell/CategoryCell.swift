//
//  CategoryCellTableViewCell.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/28/1399 AP.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberItems: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberItems.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
