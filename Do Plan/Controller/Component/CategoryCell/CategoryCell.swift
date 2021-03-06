//
//  CategoryCellTableViewCell.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/28/1399 AP.
//

import UIKit

class CategoryCell: UITableViewCell {
    static let identifier = "CategoryCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var precentLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
