//
//  NFTTableViewCell.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 11/02/2022.
//

import UIKit

class NFTTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nftImageView: UIImageView!
    
    
    var image: UIImage? {
        didSet {
            nftImageView.image = image
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
}
