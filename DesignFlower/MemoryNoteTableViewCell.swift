//
//  MemoryNoteTableViewCell.swift
//  2017-dishrank-ios
//
//  Created by larvata_ios on 2018/7/3.
//

import UIKit

class MemoryNoteTableViewCell: UITableViewCell {
  @IBOutlet weak var dishImg: UIImageView!
  @IBOutlet weak var titleLbl: UILabel!
  @IBOutlet weak var restNameLbl: UILabel!
  @IBOutlet weak var cityLbl: UILabel!
  @IBOutlet weak var dishReviewCountLbl: UILabel!
  @IBOutlet weak var picsCountLbl: UILabel!
  @IBOutlet weak var isLikeBt: UIButton!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var toRestStackView: UIStackView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // Initialization code
  }
  
    func configCell(memoryNoteData: RLMRestReviewV4) {
        titleLbl.text = memoryNoteData.title
        
        if memoryNoteData.restaurant == nil {
            cityLbl.isHidden = true
        }else{
            cityLbl.isHidden = false
        }
        
        let restCityAttribute = NSMutableAttributedString(string: "city")
        restCityAttribute
            .addAttribute(NSAttributedStringKey.foregroundColor,
                          value: UIColor.init(red: 186/255,
                                              green: 143/255,
                                              blue: 92/255,
                                              alpha: 1.0),
                          range: NSMakeRange(0, 1))
        cityLbl.attributedText = restCityAttribute
        
        restNameLbl.text = memoryNoteData.restaurant?.name
        
        dishReviewCountLbl.text = memoryNoteData.dishReviews.count.description + "道菜"
        picsCountLbl.text = memoryNoteData.dishReviews.reduce(0, { (result, dishReview) -> Int in
            return (result + dishReview.images.count)
        }).description + "張照片"
        phoneLabel.text = memoryNoteData.restaurant?.phoneNumber
        
        let address = memoryNoteData.restaurant?.address ?? "address"
        addressLabel.text = address
        
        
        isLikeBt.isHidden = true
        selectionStyle = .none
        
        
        if let localName = memoryNoteData.dishReviews.first?.images.first?.localName {
            let localImagePath = KVOImageV4.localFolder.appendingPathComponent(localName)
          if let imgData = try? Data.init(contentsOf: localImagePath) {
            let img = UIImage(data: imgData)
            dishImg.image = img
          }
        } else {
            dishImg.image = UIImage(named: "restaurant_placeholder")
        }
//        if let urlString = memoryNoteData.dishReviews.first?.images.first?.url {
//            let url = URL(string: urlString)
//            dishImg.sd_setImage(with: url)
//        } else {
//            dishImg.image = nil
//        }
    }
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}

