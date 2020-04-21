//
//  ServiceCell.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 25/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit

class ServiceCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let reuseIdentifier = "ServiceCell"

    override func layoutSubviews() {
        super.layoutSubviews()

        setupRoundedCorners()
        setupShadows()
    }

    func setupRoundedCorners() {
        contentView.layer.cornerRadius = 12

        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
    }

    func setupShadows() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
    }

    override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {
            if newValue {
                let transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
                UIView.animate(withDuration: 0.2) {
                    self.transform = transform
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                }
            }

            super.isHighlighted = true
        }
    }

}
