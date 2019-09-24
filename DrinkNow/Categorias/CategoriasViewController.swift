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
import DataCache

class CategoriasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //  OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarCategorias: UISearchBar!
    
    //  VARIÁVEIS
    
    let data = NSMutableData()
    
    //  URL JSON das Categorias
    let urlCategoriasJson = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
    //  Formato do JSON
    let json = "{\"\":\"\"}"
    
    //  Arrays que serão preenchidos com os dados do JSON
    var categoriaArray = [String]()
    var categoriasFiltradas = [String]()
    var searchActive : Bool = false
    let itemName = "myJSONFromWeb"
    let defaults = UserDefaults.standard
    
    //  Leitura do JSON a partir da URL
    func lerJson() {
        let url = URL(string: urlCategoriasJson)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        if Connectivity.isConnectedToInternet() {
            Alamofire.request(request).responseJSON {
                (response) in
                
                let categoriesJSON: JSON = JSON(response.result.value!)
                
                if (try? JSON(data: jsonData)) != nil {
                    for item in categoriesJSON["drinks"].arrayValue {
                        
                        self.categoriaArray.append(item["strCategory"].stringValue)
                        
                        DataCache.instance.write(object: self.categoriaArray as NSCoding, forKey: "categoriaNome")
                        
                        //  Atualizando a tabela e removendo o loading
                        self.tableView.reloadData()
                        self.removeSpinner()
                        
                    }
                }
            }
        } else {
            //  Atualizando a tabela e removendo o loading
            self.tableView.reloadData()
            self.removeSpinner()
        }
        
    }
    
    //  Primeira atividade que é executada
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Carregamento
        self.showSpinner(onView: self.view)
        searchBarCategorias.delegate = self
        
        //  Nav Bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 76/255, green: 156/255, blue: 255/55, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //  Chama a leitura do JSON a partir da URL
        lerJson()
    }
    
    //  Especificações da tabela
    
    //  Número de linhas da tabela
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numeroDeLinhas = Int()
        if(searchActive) {
            return categoriasFiltradas.count
        }
        if Connectivity.isConnectedToInternet() {
            numeroDeLinhas = categoriaArray.count
        } else {
            let arrayCategorias = DataCache.instance.readObject(forKey: "categoriaNome") as! Array<String>
            numeroDeLinhas = arrayCategorias.count
        }
        return numeroDeLinhas
    }
    
    //  Número de de Seções da tabela
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //  Preenchimento das linhas com os dados do JSON
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CategoriasTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CategoriasTableViewCell
        
        if(searchActive){
            cell.nomeCategoria.text = categoriasFiltradas[indexPath.row]
        } else {
            var arrayCat = DataCache.instance.readObject(forKey: "categoriaNome") as! Array<String>
            cell.nomeCategoria.text = arrayCat[indexPath.row]
        }
        
        return cell
    }
    
    //  Altura da linha na tabela
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    //  Quando uma linha for selecionada
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vcDetail : ItensCategoriaViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailCategorias") as? ItensCategoriaViewController {
            
            if(searchActive == true){
                vcDetail.nomeCategoriaSelecionada = categoriasFiltradas[indexPath.row]
            } else {
                let categoria = DataCache.instance.readObject(forKey: "categoriaNome") as! Array<String>
                vcDetail.nomeCategoriaSelecionada = categoria[indexPath.row]
            }
            
            //  Atualizando a tabela
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
        
        let categoria = DataCache.instance.readObject(forKey: "categoriaNome") as! Array<String>
        
        categoriasFiltradas = categoria.filter({ (text) -> Bool in
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
