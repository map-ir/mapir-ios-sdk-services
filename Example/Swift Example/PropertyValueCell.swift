//
//  PropertyValueCell.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 26/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit

class PropertyValueCell: UITableViewCell {

    static let reuseIdentifier = "PropertyValueCell"

    @IBOutlet weak var propertyNameLabel: UILabel!
    @IBOutlet weak var propertyValueLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
