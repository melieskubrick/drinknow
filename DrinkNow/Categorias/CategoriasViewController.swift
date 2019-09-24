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

class CategoriasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //  OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarCategorias: UISearchBar!
    
    //  VARIÁVEIS
    let data = NSMutableData()
    let urlCategoriasJson = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
    let json = "{\"\":\"\"}"
    var categoriaArray = [String]()
    var categoriasFiltradas = [String]()
    var searchActive : Bool = false
    let itemName = "myJSONFromWeb"
    let defaults = UserDefaults.standard
    
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
                    
                    DataCache.sharedInstance.cache["catArray"] = self.categoriaArray
                    
                    self.tableView.reloadData()
                    self.removeSpinner()
                    
                }
            }
        }
    }
    
    //  Primeira atividade que é executada
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner(onView: self.view)
        searchBarCategorias.delegate = self
        
        //  Nav Bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 76/255, green: 156/255, blue: 255/55, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        lerJson()
    }
    
    //  Especificações da tabela
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return categoriasFiltradas.count
        }
        return categoriaArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CategoriasTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CategoriasTableViewCell
        
        // Colocando o nome dos drinks em cada linha
        cell.nomeCategoria.text = categoriaArray[indexPath.row]
        
        if let categoriaDrink: Array = DataCache.sharedInstance.cache["catArray"] as? Array<Any> {
            let nomeCategoria = categoriaDrink[indexPath.row]
            
            if(searchActive){
                cell.nomeCategoria.text = categoriasFiltradas[indexPath.row]
            } else {
                cell.nomeCategoria.text = nomeCategoria as? String
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vcDetail : ItensCategoriaViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailCategorias") as? ItensCategoriaViewController {
            
            if(searchActive == true){
                vcDetail.nomeCategoriaSelecionada = categoriasFiltradas[indexPath.row]
            } else {
                vcDetail.nomeCategoriaSelecionada = categoriaArray[indexPath.row]
            }
            
            DispatchQueue.main.async {
                self.searchBarCategorias.text = ""
                self.tableView.reloadData()
                self.searchActive = false
            }
            
            self.show(vcDetail, sender: nil)
        }
    }
    
    //  Configurações da Search Bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        categoriasFiltradas = categoriaArray.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: .caseInsensitive)
            return range.location != NSNotFound
        })
        
        if(categoriasFiltradas.count == 0 || categoriasFiltradas.count == categoriaArray.count){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    //  Status Bar Branco
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
