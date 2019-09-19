//
//  CategoriasViewController.swift
//  DrinkNow
//
//  Created by Melies Kubrick on 19/09/19.
//  Copyright © 2019 Melies Kubrick. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ItensCategoriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //  OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //  VARIÁVEIS
    let data = NSMutableData()
    let urlCategoriasJson = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Ordinary%20Drink"
    let json = "{\"\":\"\"}"
    var nomeDrinkArray = [String]()
    var thumbDrinkArray = [String]()
    var idDrinkArray = [String]()
    
    //  FUNÇÕES
    //  Leitura do JSON
    func lerJson() {
        let url = URL(string: urlCategoriasJson)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON {
            (response) in
            let categoriesJSON: JSON = JSON(response.result.value!)
            
            if (try? JSON(data: jsonData)) != nil {
                for item in categoriesJSON["drinks"].arrayValue {
                    
                    self.nomeDrinkArray.append(item["strDrink"].stringValue)
                    self.thumbDrinkArray.append(item["strDrinkThumb"].stringValue)
                    self.idDrinkArray.append(item["idDrink"].stringValue)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //  Primeira atividade que é executada
    override func viewDidLoad() {
        super.viewDidLoad()
        lerJson()
    }
    
    //  Especificações da tabela
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nomeDrinkArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //  Preenchendo as linhas com nomes e imagens
        let cell: ItensCategoriaTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ItensCategoriaTableViewCell
        cell.nomeDrink.text = nomeDrinkArray[indexPath.row]
        if var imageURL = thumbDrinkArray[indexPath.row] as? String {
            Alamofire.request(thumbDrinkArray[indexPath.row]).responseImage(completionHandler: {(response) in
                
                print(response)
                if let image = response.result.value {
                    DispatchQueue.main.async {
                        cell.imagemDrink.image = image
                    }
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("o item " + nomeDrinkArray[indexPath.row] + " foi clicado na linha \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}
