//
//  ArticleTableViewCell.swift
//  News
//
//  Created by Dmitry Reshetnik on 28.11.2020.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    static let ReuseIdentifier = "ArticleTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
