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
import DataCache

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
    
    @IBOutlet weak var imageDrink: UIImageView!
    
    func lerJson() {
        
        //  URL do modo de preparo de um drink selecionado
        let urlIngredientesJson = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=\(idDrink as! String)"
        let url = URL(string: urlIngredientesJson)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        //  Checando a internet
        if Connectivity.isConnectedToInternet() {
            self.showSpinner(onView: self.view)
            
            Alamofire.request(request).responseJSON {
                (response) in
                let ingredientesJSON: JSON = JSON(response.result.value!)
                
                if (try? JSON(data: jsonData)) != nil {
                    for item in ingredientesJSON["drinks"].arrayValue {
                        
                        //  Adiciona no array "ingredientes" e "quantidades" cada ingrediente separadamente e a quantidade
                        for i in 1...15  {
                            if item["strIngredient\(i)"].stringValue.isEmpty == false && item["strIngredient\(i)"].stringValue != " " {
                                self.ingredientes.append(item["strIngredient\(i)"].stringValue)
                            }
                            if item["strMeasure\(i)"].stringValue.isEmpty == false && item["strMeasure\(i)"].stringValue != " " && item["strMeasure\(i)"].stringValue != "\n" && item["strMeasure\(i)"].stringValue != "\r\n"{
                                self.quantidade.append(item["strMeasure\(i)"].stringValue)
                            }
                            
                        }
                        
                        //  Recupera os dados de intrução do drink
                        self.intrucao = item["strInstructions"].stringValue
                        self.title = item["strDrink"].stringValue
                        
                        print("Allll \(self.quantidade)")
                        
                        //  Implementando dados no Caching
                        DataCache.instance.write(object: self.intrucao as NSCoding, forKey: "instrucao")
                        DataCache.instance.write(object: self.intrucao as NSCoding, forKey: "titulo")
                        
                        self.tableViewCustom.reloadData()
                        self.removeSpinner()
                        
                    }
                }
            }
        } else {
            
            //  Implementando dados no Caching
            self.title = DataCache.instance.readObject(forKey: "titulo") as? String
            self.intrucao = DataCache.instance.readObject(forKey: "instrucao") as! String
            
            //  Atualizando a tabela
            self.tableViewCustom.reloadData()
            self.removeSpinner()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lerJson()
        
        tableViewCustom.delegate = self
        tableViewCustom.dataSource = self
        
        imageDrink.sd_setImage(with: URL(string: urlDaImagem), placeholderImage: UIImage(named: "default"))
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //  Configurando a TableView
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
        DataCache.instance.write(object: self.ingredientes as NSCoding, forKey: "ingredientes")
        DataCache.instance.write(object: self.quantidade as NSCoding, forKey: "quantidades")
        
        var ingredientesCount = Array<String>()
        var quantidadeCount = Array<String>()
        ingredientesCount = DataCache.instance.readObject(forKey: "ingredientes") as! [String]
        quantidadeCount = DataCache.instance.readObject(forKey: "quantidades") as! [String]
        
        var linhas: Int!
        if (section == 0){
            linhas = 1
        }
        if (section == 1){
            linhas = ingredientesCount.count
        }
        if (section == 2){
            linhas = quantidadeCount.count
        }
        
        return linhas
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellDetail = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CellDetail
        
        var nomesIngredientes = DataCache.instance.readObject(forKey: "ingredientes") as! Array<String>
        var nomesQuantidades = DataCache.instance.readObject(forKey: "quantidades") as! Array<String>
        
        let section = indexPath.section
        
        //  Seção 0 -> Intruções
        //  Seção 1 -> Ingredientes
        //  Seção 2 -> Modo de preparo
        
        if section == 0 {
            
            cell.imagemIngrediente.image = UIImage(named: "Intructions")
            cell.ingrediente.text = intrucao
            
        } else if section == 1 {
            
            cell.ingrediente.text = nomesIngredientes[indexPath.row]
            let urlImage = nomesIngredientes[indexPath.row].replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            cell.imagemIngrediente.sd_setImage(with: URL(string: "https://www.thecocktaildb.com/images/ingredients/\(urlImage).png"), placeholderImage: UIImage(named: "default"))
            
        } else if section == 2 {
            
            cell.ingrediente.text = "\(nomesQuantidades[indexPath.row]) \(nomesIngredientes[indexPath.row])"
            let urlImage = nomesIngredientes[indexPath.row].replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            cell.imagemIngrediente.sd_setImage(with: URL(string: "https://www.thecocktaildb.com/images/ingredients/\(urlImage).png"), placeholderImage: UIImage(named: "default"))
            
        }
        
        return cell
    }
    
}
