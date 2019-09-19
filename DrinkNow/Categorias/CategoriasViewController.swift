//
//  CategoriasViewController.swift
//  DrinkNow
//
//  Created by Melies Kubrick on 19/09/19.
//  Copyright © 2019 Melies Kubrick. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CategoriasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //  OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //  VARIÁVEIS
    let data = NSMutableData()
    let urlCategoriasJson = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
    let json = "{\"\":\"\"}"
    var categoriaArray = [String]()
    
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
                    let nome = item["strCategory"].stringValue
                    print("Nome da categoria \(nome)")
                    self.categoriaArray.append(nome)
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
        return categoriaArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CategoriasTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CategoriasTableViewCell
        
        // Colocando o nome dos drinks em cada linha
        cell.nomeCategoria.text = categoriaArray[indexPath.row]
        
        return cell
    }
    
}
