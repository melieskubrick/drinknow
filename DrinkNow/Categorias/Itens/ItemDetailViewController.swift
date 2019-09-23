//
//  ItemDefaultViewController.swift
//  DrinkNow
//
//  Created by Melies Kubrick on 22/09/19.
//  Copyright © 2019 Melies Kubrick. All rights reserved.
//

import UIKit
import SDWebImage

class ItemDetailViewController: UIViewController {
    
    var nomeDoDrink: String!
    var urlDaImagem: String!
    
    @IBOutlet weak var nameDrink: UILabel!
    @IBOutlet weak var imageDrink: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameDrink.text = nomeDoDrink
        imageDrink.sd_setImage(with: URL(string: urlDaImagem), placeholderImage: UIImage(named: "default"))
    }

}
