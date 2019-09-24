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
import DataCache

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
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
    var itensArray = [Drink]()
    var itensArrayNome = [String]()
    var itensArrayThumb = [String]()
    var itensArrayId = [String]()
    var filter = [Drink]()
    
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
        
        //  Se tiver internet ele conecta, se não ele irá ler o Cache
        if Connectivity.isConnectedToInternet() {
            self.showSpinner(onView: self.view)
            Alamofire.request(request).responseJSON {
                (response) in
                
                self.title = self.nomeCategoriaSelecionada
                
                if self.nomeCategoriaSelecionada.isEmpty == false {
                    let categoriesJSON: JSON = JSON(response.result.value!)
                    
                    if (try? JSON(data: jsonData)) != nil {
                        for item in categoriesJSON["drinks"].arrayValue {
                            
                            self.itensArray.append(Drink(nome: item["strDrink"].stringValue, imagem: item["strDrinkThumb"].stringValue, id: item["idDrink"].stringValue))
                            self.itensArrayNome.append(item["strDrink"].stringValue)
                            self.itensArrayThumb.append(item["strDrinkThumb"].stringValue)
                            self.itensArrayId.append(item["idDrink"].stringValue)
                            
                            //  Implementando dados no Caching
                            DataCache.instance.write(object: self.itensArrayNome as NSCoding, forKey: "nome")
                            DataCache.instance.write(object: self.itensArrayThumb as NSCoding, forKey: "imagem")
                            DataCache.instance.write(object: self.itensArrayId as NSCoding, forKey: "id")
                            
                            self.tableViewCustom.reloadData()
                            self.removeSpinner()
                            
                        }
                    }
                }
            }
            
        } else {
            
            print("Sem Internet")
            
            //  Resgata os dados para serem usados no filtro
            let filterArray1 = DataCache.instance.readObject(forKey: "nome") as! Array<String>
            let filterArray2 = DataCache.instance.readObject(forKey: "imagem") as! Array<String>
            let filterArray3 = DataCache.instance.readObject(forKey: "id") as! Array<String>
            
            //  Adiciona os dados em uma array que será utilizada no filtro caso esteja sem internet
            for i in 0...filterArray1.count-1 {
                filter.append(Drink(nome: filterArray1[i], imagem: filterArray2[i], id: filterArray3[i]))
            }
            
            //  Atualiza a tabela
            self.tableViewCustom.reloadData()
            self.removeSpinner()
        }
        
    }
    
    //  Primeira atividade que é executada
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lerJson()
        
        tableViewCustom.delegate = self
        tableViewCustom.dataSource = self
        searchBarCustom.delegate = self
        
    }
    
    //  Especificações da tabela
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numeroDeLinhas = Int()
        if(searchActive) {
            return drinksFiltrados.count
        }
        
        if Connectivity.isConnectedToInternet() {
            numeroDeLinhas = itensArray.count
        } else {
            let arrayItem = DataCache.instance.readObject(forKey: "nome") as! Array<String>
            numeroDeLinhas = arrayItem.count
        }
        
        return numeroDeLinhas
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //  Preenchendo as linhas com nomes e imagens
        let cell: ItensCategoriaTableViewCell = self.tableViewCustom.dequeueReusableCell(withIdentifier: "cell") as! ItensCategoriaTableViewCell
        
        if(searchActive){
            cell.nomeDrink.text = drinksFiltrados[indexPath.row].nome
        } else {
            var nome = DataCache.instance.readObject(forKey: "nome") as! [String]
            cell.nomeDrink.text = nome[indexPath.row]
        }
        
        if(searchActive){
            cell.imagemDrink.sd_setImage(with: URL(string: drinksFiltrados[indexPath.row].imagem), placeholderImage: UIImage(named: "default"))
        } else {
            var imagem = DataCache.instance.readObject(forKey: "imagem") as! [String]
            cell.imagemDrink.sd_setImage(with: URL(string: imagem[indexPath.row]), placeholderImage: UIImage(named: "default"))
        }
        
        return cell
    }
    
    //  Quando um item da tabela é selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //  vcDetail -> Tela de detalhe do drink, onde irá mostrar o modo de preparo e as instruções
        
        if let vcDetail : ItemDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? ItemDetailViewController {
            
            if(searchActive == true){
                vcDetail.nomeDoDrink = drinksFiltrados[indexPath.row].nome
                vcDetail.urlDaImagem = drinksFiltrados[indexPath.row].imagem
                vcDetail.idDrink = drinksFiltrados[indexPath.row].id
            } else {
                let nome = DataCache.instance.readObject(forKey: "nome") as! [String]
                let imagem = DataCache.instance.readObject(forKey: "imagem") as! [String]
                let id = DataCache.instance.readObject(forKey: "id") as! [String]
                
                vcDetail.nomeDoDrink = nome[indexPath.row]
                vcDetail.urlDaImagem = imagem[indexPath.row]
                vcDetail.idDrink = id[indexPath.row]
            }
            
            //  Atualizando a tabela
            DispatchQueue.main.async {
                self.searchBarCustom.text = ""
                self.tableViewCustom.reloadData()
                self.searchActive = false
            }
            
            //  Mostrando a tela de detalhe
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
        
        if Connectivity.isConnectedToInternet() {
            drinksFiltrados = itensArray.filter({ drink -> Bool in
                guard let text = searchBarCustom.text else {return false}
                return drink.nome.contains(text)
            })
            
            if(drinksFiltrados.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }
            tableViewCustom.reloadData()
        } else {
            drinksFiltrados = filter.filter({ drink -> Bool in
                guard let text = searchBarCustom.text else {return false}
                return drink.nome.contains(text)
            })
            
            if(drinksFiltrados.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }
            tableViewCustom.reloadData()
        }
        
    }
    
}

// Carregamento personalizado
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
    let id: String
    
    init(nome: String, imagem: String, id: String) {
        self.nome = nome
        self.imagem = imagem
        self.id = id
    }
    
}
