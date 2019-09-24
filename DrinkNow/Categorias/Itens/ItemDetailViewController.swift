//
//  ItemDefaultViewController.swift
//  DrinkNow
//
//  Created by Melies Kubrick on 22/09/19.
//  Copyright © 2019 Melies Kubrick. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON

class ItemDetailViewController: UITableViewController {
    
    @IBOutlet var tableViewCustom: UITableView!
    
    var nomeDoDrink: String!
    var urlDaImagem: String!
    var idDrink: String!
    
    //  VARIÁVEIS
    let data = NSMutableData()
    let json = "{\"\":\"\"}"
    var ingredientes = [String]()
    var quantidade = [String]()
    var intrucao = String()
    
    @IBOutlet weak var nameDrink: UILabel!
    @IBOutlet weak var imageDrink: UIImageView!
    
    func lerJson() {
        let urlIngredientesJson = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=\(idDrink as! String)"
        
        print("Alves \(urlIngredientesJson)")
        let url = URL(string: urlIngredientesJson)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON {
            (response) in
            let ingredientesJSON: JSON = JSON(response.result.value!)
            
            if (try? JSON(data: jsonData)) != nil {
                for item in ingredientesJSON["drinks"].arrayValue {
                    
                    for i in 1...15  {
                        if item["strIngredient\(i)"].stringValue.isEmpty == false && item["strIngredient\(i)"].stringValue != " " {
                            self.ingredientes.append(item["strIngredient\(i)"].stringValue)
                        }
                        if item["strMeasure\(i)"].stringValue.isEmpty == false && item["strMeasure\(i)"].stringValue != " " && item["strMeasure\(i)"].stringValue != "\n" {
                            self.quantidade.append(item["strMeasure\(i)"].stringValue)
                        }
                    }
                    
                    self.intrucao = item["strInstructions"].stringValue
                    
                    print("Ingredientes Melies \(self.ingredientes)")
                    print("Ingredientes Melies \(self.quantidade)")
                    
                    self.title = item["strDrink"].stringValue
                    
                    self.tableViewCustom.reloadData()
                    self.removeSpinner()
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        nameDrink.text = nomeDoDrink
        
        tableViewCustom.delegate = self
        tableViewCustom.dataSource = self
        
        imageDrink.sd_setImage(with: URL(string: urlDaImagem), placeholderImage: UIImage(named: "default"))
        self.showSpinner(onView: self.view)
        lerJson()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat()
        let section = indexPath.section
        
        if section == 0 {
            height = UITableView.automaticDimension
        } else {
            height = 50
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var retorno: String!
        if (section == 0){
            retorno = "Instrução"
        }
        if (section == 1){
            retorno = "Ingredientes"
        }
        if (section == 2){
            retorno = "Modo de preparo"
        }
        
        return retorno
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var linhas: Int!
        if (section == 0){
            linhas = 1
        }
        if (section == 1){
            linhas = ingredientes.count
        }
        if (section == 2){
            linhas = quantidade.count
        }
        
        return linhas
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellDetail = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CellDetail
        
        let section = indexPath.section
        if section == 0 {
            cell.imagemIngrediente.image = UIImage(named: "Intructions")
            cell.ingrediente.text = intrucao
        } else if section == 1 {
            cell.ingrediente.text = ingredientes[indexPath.row]
            
            let urlImage = ingredientes[indexPath.row].replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            cell.imagemIngrediente.sd_setImage(with: URL(string: "https://www.thecocktaildb.com/images/ingredients/\(urlImage).png"), placeholderImage: UIImage(named: "default"))
        } else if section == 2 {
            cell.ingrediente.text = "\(quantidade[indexPath.row]) \(ingredientes[indexPath.row])"
            let urlImage = ingredientes[indexPath.row].replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            cell.imagemIngrediente.sd_setImage(with: URL(string: "https://www.thecocktaildb.com/images/ingredients/\(urlImage).png"), placeholderImage: UIImage(named: "default"))
        }
        
        return cell
    }
    
}
