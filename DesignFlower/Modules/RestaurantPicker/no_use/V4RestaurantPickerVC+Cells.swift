//
//  RestaurantListCityTableViewCell.swift
//  DishRank
//
//  Created by 朱紹翔 on 2018/10/31.
//

import UIKit

class RestaurantListCell: UITableViewCell {
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var restaurantNameLabel: UILabel!
  @IBOutlet var restaurantLocationLabel: UILabel!
  @IBOutlet var dishRankImageView: UIView!
  @IBOutlet weak var drImageView: UIImageView!
  @IBOutlet weak var privateOrDRLabel: UILabel!
}

class RestaurantListCityTableViewCell: UITableViewCell {
  @IBOutlet weak var cityNameLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
