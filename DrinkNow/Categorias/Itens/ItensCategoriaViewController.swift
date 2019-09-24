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
import SDWebImage

//  Classe de Cache
class DataCache: NSObject {
    static let sharedInstance = DataCache()
    var cache = Dictionary<String, Any>()
}

class ItensCategoriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //  OUTLETS
    @IBOutlet weak var tableViewCustom: UITableView!
    @IBOutlet weak var searchBarCustom: UISearchBar!
    
    //  VARIÁVEIS
    let data = NSMutableData()
    var nomeCategoriaSelecionada = String()
    var drinksFiltrados = [Drink]()
    var searchActive : Bool = false
    
    //  Dados que serão escritos do JSON
    var nomeDrinkArray = [String]()
    var thumbDrinkArray = [String]()
    var idDrinkArray = [String]()
    
    var itensArray = [Drink]()
    
    //  FUNÇÕES
    
    //  Leitura do JSON
    func lerJson() {
        //  Configurações do JSON
        let nomeCategoriaSelecionadaFormatado = nomeCategoriaSelecionada.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let urlCategoriasJson = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=\(nomeCategoriaSelecionadaFormatado)"
        
        let json = "{\"\":\"\"}"
        let url = URL(string: urlCategoriasJson)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON {
            (response) in
            DispatchQueue.main.async {
                
                self.title = self.nomeCategoriaSelecionada
                
                if self.nomeCategoriaSelecionada.isEmpty == false {
                    let categoriesJSON: JSON = JSON(response.result.value!)
                    
                    if (try? JSON(data: jsonData)) != nil {
                        for item in categoriesJSON["drinks"].arrayValue {
                            
                            self.nomeDrinkArray.append(item["strDrink"].stringValue)
                            self.thumbDrinkArray.append(item["strDrinkThumb"].stringValue)
                            self.idDrinkArray.append(item["idDrink"].stringValue)
                            
                            self.itensArray.append(Drink(nome: item["strDrink"].stringValue, imagem: item["strDrinkThumb"].stringValue))
                            
                            DataCache.sharedInstance.cache["strDrink"] = self.nomeDrinkArray
                            
                            self.tableViewCustom.reloadData()
                            self.removeSpinner()
                            
                        }
                    }
                }
            }
        }
    }
    
    //  Primeira atividade que é executada
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.lerJson()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewCustom.delegate = self
        tableViewCustom.dataSource = self
        searchBarCustom.delegate = self
        
        self.showSpinner(onView: self.view)
    }
    
    //  Especificações da tabela
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return drinksFiltrados.count
        }
        return nomeDrinkArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //  Preenchendo as linhas com nomes e imagens
        let cell: ItensCategoriaTableViewCell = self.tableViewCustom.dequeueReusableCell(withIdentifier: "cell") as! ItensCategoriaTableViewCell
        
        if let nomedoDrink: Array = DataCache.sharedInstance.cache["strDrink"] as? Array<Any> {
            let nomeDosDrinks = nomedoDrink[indexPath.row]
            cell.imagemDrink.sd_setImage(with: URL(string: thumbDrinkArray[indexPath.row]), placeholderImage: UIImage(named: "default"))
            
            if(searchActive){
                cell.nomeDrink.text = drinksFiltrados[indexPath.row].nome
                cell.imagemDrink.sd_setImage(with: URL(string: drinksFiltrados[indexPath.row].imagem), placeholderImage: UIImage(named: "default"))
            } else {
                cell.nomeDrink.text = nomeDosDrinks as? String
            }
            
        }
        
        return cell
    }
    
    //  Quando um item da tabela é selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("o item " + nomeDrinkArray[indexPath.row] + " foi clicado na linha \(indexPath.row)")
        if let vcDetail : ItemDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? ItemDetailViewController {
            
            vcDetail.urlDaImagem = thumbDrinkArray[indexPath.row]
            vcDetail.idDrink = idDrinkArray[indexPath.row]
            
            if(searchActive == true){
                vcDetail.nomeDoDrink = drinksFiltrados[indexPath.row].nome
            } else {
                vcDetail.nomeDoDrink = nomeDrinkArray[indexPath.row]
            }
            
            
            self.show(vcDetail, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
//        drinksFiltrados = itensArray.filter({ drink -> Bool in
//            let tmp: NSString = text as NSString
//            let range = tmp.range(of: searchText, options: .caseInsensitive)
//            return range.location != NSNotFound
//        })
        
        drinksFiltrados = itensArray.filter({ drink -> Bool in
            guard let text = searchBarCustom.text else {return false}
            return drink.nome.contains(text)
        })
        
        if(drinksFiltrados.count == 0 || drinksFiltrados.count == nomeDrinkArray.count){
            searchActive = false;
        } else {
            searchActive = true;
        }
        tableViewCustom.reloadData()
    }
    
}

// Carregamento
var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

class Drink {
    let nome: String
    let imagem: String
    
    init(nome: String, imagem: String) {
        self.nome = nome
        self.imagem = imagem
    }
    
}
