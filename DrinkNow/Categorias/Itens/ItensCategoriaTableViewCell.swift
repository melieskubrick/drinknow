//
//  ItensCategoriaTableViewCell.swift
//  DrinkNow
//
//  Created by Melies Kubrick on 19/09/19.
//  Copyright © 2019 Melies Kubrick. All rights reserved.
//

import UIKit

class ItensCategoriaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imagemDrink: UIImageView!
    @IBOutlet weak var nomeDrink: UILabel!
    
    override func layoutSubviews() {
        
        //  Estilos
        imagemDrink.layer.masksToBounds = true
        imagemDrink.layer.cornerRadius = 10
        
    }
    
}
