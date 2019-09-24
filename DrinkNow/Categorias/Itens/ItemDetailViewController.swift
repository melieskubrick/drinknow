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
        let urlIngredientes = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=\(idDrink as! String)"
        let url = URL(string: urlIngredientes)!
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
                        
                        //  Implementando dados no Caching
                        DataCache.instance.write(object: self.ingredientes as NSCoding, forKey: "ingredientes")
                        DataCache.instance.write(object: self.quantidade as NSCoding, forKey: "quantidades")
                        DataCache.instance.write(object: self.intrucao as NSCoding, forKey: "instrucao")
                        
                        self.intrucao = DataCache.instance.readObject(forKey: "instrucao") as! String
                        
                        self.tableViewCustom.reloadData()
                        self.removeSpinner()
                        
                    }
                }
            }
        } else {
            
            let alert = UIAlertController(title: "Alert", message: "You are offline and will navigate using app caching", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            //  Atualizando a tabela
            self.tableViewCustom.reloadData()
            self.removeSpinner()
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lerJson()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = nomeDoDrink
        
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
            retorno = "Instruction"
        }
        if (section == 1){
            retorno = "Ingredients"
        }
        if (section == 2){
            retorno = "Method of preparation"
        }
        
        return retorno
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        var linhas: Int!
        
        if (section == 0){
            linhas = 1
        }
        if (section == 1){
            
            if DataCache.instance.readObject(forKey: "ingredientes") != nil {
                let itens = DataCache.instance.readObject(forKey: "ingredientes") as! [String]
                linhas = itens.count
            } else {
                linhas = 0
            }
            
        }
        if (section == 2){
            if DataCache.instance.readObject(forKey: "quantidades") != nil {
                let itens = DataCache.instance.readObject(forKey: "quantidades") as! [String]
                linhas = itens.count
            } else {
                linhas = 0
            }
        }
        
        return linhas
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellDetail = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CellDetail
        
        let section = indexPath.section
        
        //  Seção 0 -> Intruções
        //  Seção 1 -> Ingredientes
        //  Seção 2 -> Modo de preparo
        
        if section == 0 {
            
            cell.imagemIngrediente.image = UIImage(named: "Intructions")
            cell.ingrediente.text = DataCache.instance.readObject(forKey: "instrucao") as? String
            
        } else if section == 1 {
            
            let nomesIngredientes = DataCache.instance.readObject(forKey: "ingredientes") as! [String]
            
            cell.ingrediente.text = nomesIngredientes[indexPath.row]
            let urlImage = nomesIngredientes[indexPath.row].replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            cell.imagemIngrediente.sd_setImage(with: URL(string: "https://www.thecocktaildb.com/images/ingredients/\(urlImage).png"), placeholderImage: UIImage(named: "default"))
            
        } else if section == 2 {
            
            let nomesIngredientes = DataCache.instance.readObject(forKey: "ingredientes") as! [String]
            let nomesQuantidades = DataCache.instance.readObject(forKey: "quantidades") as! [String]
            
            cell.ingrediente.text = "\(nomesQuantidades[indexPath.row]) \(nomesIngredientes[indexPath.row])"
            let urlImage = nomesIngredientes[indexPath.row].replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            cell.imagemIngrediente.sd_setImage(with: URL(string: "https://www.thecocktaildb.com/images/ingredients/\(urlImage).png"), placeholderImage: UIImage(named: "default"))
            
        }
        
        return cell
    }
    
}
