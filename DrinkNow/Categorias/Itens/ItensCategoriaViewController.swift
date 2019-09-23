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

class ItensCategoriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //  OUTLETS
    @IBOutlet weak var tableViewCustom: UITableView!
    
    //  VARIÁVEIS
    let data = NSMutableData()
    var nomeCategoriaSelecionada = String()
    
    //  Dados que serão escritos do JSON
    var nomeDrinkArray = [String]()
    var thumbDrinkArray = [String]()
    var idDrinkArray = [String]()
    
    //  FUNÇÕES
    
    //  Leitura do JSON
    func lerJson() {
        //  Configurações do JSON
        let nomeCategoriaSelecionadaFormatado = nomeCategoriaSelecionada.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let urlCategoriasJson = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=\(nomeCategoriaSelecionadaFormatado)"
        print("Kubrick \(urlCategoriasJson)")
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
                
                if self.nomeCategoriaSelecionada.isEmpty == false {
                    let categoriesJSON: JSON = JSON(response.result.value!)
                    
                    if (try? JSON(data: jsonData)) != nil {
                        for item in categoriesJSON["drinks"].arrayValue {
                            
                            self.nomeDrinkArray.append(item["strDrink"].stringValue)
                            self.thumbDrinkArray.append(item["strDrinkThumb"].stringValue)
                            self.idDrinkArray.append(item["idDrink"].stringValue)
                            
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
        self.showSpinner(onView: self.view)
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
        let cell: ItensCategoriaTableViewCell = self.tableViewCustom.dequeueReusableCell(withIdentifier: "cell") as! ItensCategoriaTableViewCell
        
        if let nomedoDrink: Array = DataCache.sharedInstance.cache["strDrink"] as? Array<Any> {
            let nomeDosDrinks = nomedoDrink[indexPath.row]
            cell.nomeDrink.text = nomeDosDrinks as? String
        }
        
        cell.imagemDrink.sd_setImage(with: URL(string: thumbDrinkArray[indexPath.row]), placeholderImage: UIImage(named: "default"))
        
        return cell
    }
    
    //  Quando um item da tabela é selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("o item " + nomeDrinkArray[indexPath.row] + " foi clicado na linha \(indexPath.row)")
        if let vcDetail : ItemDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? ItemDetailViewController {
            
            vcDetail.nomeDoDrink = nomeDrinkArray[indexPath.row]
            vcDetail.urlDaImagem = thumbDrinkArray[indexPath.row]
            
            self.present(vcDetail, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

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
