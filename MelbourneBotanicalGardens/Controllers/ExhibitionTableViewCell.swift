//
//  ExhibitionTableViewCell.swift
//  MelbourneBotanicalGardens
//
//  Created by Sugandh Singhal on 6/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ExhibitionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var setImageIcon: UIImageView!
    
    @IBOutlet weak var setNameLabel: UILabel!
    
    @IBOutlet weak var setDescribeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
