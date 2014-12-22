//
//  HomeListCell.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-12-21.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit

class HomeListCell: UITableViewCell {

    @IBOutlet weak var cardRectangle: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        cardRectangle.layer.cornerRadius = 2
        cardRectangle.layer.masksToBounds = false
        cardRectangle.layer.shadowOffset = CGSizeMake(0, 1)
        cardRectangle.layer.shadowRadius = 1
        cardRectangle.layer.shadowOpacity = 0.3
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        
        //profilePic.image = UIImage(named: "tabbar_home")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
