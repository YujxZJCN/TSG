//
//  LibraryTableViewCell.swift
//  TSG
//
//  Created by 俞佳兴 on 2020/10/29.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {

    @IBOutlet var libraryNameLabel: UILabel!
    @IBOutlet var checkImageView: UIImageView!
    @IBOutlet var leftNumberLabel: UILabel!
    @IBOutlet var totalNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func animate() {
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseIn) {
            self.contentView.layoutIfNeeded()
        }
    }
    

}
