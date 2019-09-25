<!--
*** Thanks for checking out this README Template. If you have a suggestion that would
*** make this better, please fork the repo and create a pull request or simply open
*** an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
-->





<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->


<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="Images/logo_dn.png" alt="Logo" width="80" height="80">
  </a>

  <h4 align="center">DrinkNow</h4>

## Proposta
  <p align="left">
   O DRINKNOW é um aplicativo que te ajuda a preparar os melhores drinks! Nele você pode selecionar uma categoria de drink específico, selecionar o drink e ver todo o seu modo de preparo! É bem simples, escolha agora mesmo seu drink e aprecie com moderação.
</p>

## Pods Utilizados
Aqui estão os pods que foram utilizados para a construção deste app! Estes pods agilizam e melhoram a performace da aplicação
* [Alamofire](https://github.com/Alamofire/Alamofire)
<br/>Alamofire é uma biblioteca de rede HTTP para requisições e é utilizada no projeto para leitura de URLS JSON
* [AlamofireImage](https://github.com/Alamofire/AlamofireImage)
<br/>Download e caching das imagens para performace e agilidade
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
<br/>Facilita o manuseio de dados JSON no Swift, simplificando linhas de código e rapidez na leitura
* [SDWebImage](https://github.com/SDWebImage/SDWebImage)
<br/>Downloader de imagem assíncrono com suporte a cache
* [DataCache](https://github.com/huynguyencong/DataCache)
<br/>Utilizado para armezenar os dados em cache e permitir aplicação o funcionamento offline com dados em caching

### Podfile
```sh
target 'DrinkNow' do
  use_frameworks!

  # Pods for DrinkNow
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'AlamofireImage'
  pod 'SDWebImage'
  pod 'DataCache'
  
end
```

<!-- GETTING STARTED -->
## Conhecendo os Arquivos
Aqui estão os arquivos e suas devidas funcionalidades dentro desta aplicação

<b>CategoriasViewController.swift</b>
<br/><p>  - Arquivo responsável pela leitura e exibição das categorias de drinks através da API do <b>thecocktaildb</b>. Aqui é feita a conexão com a api e a população da tabela de categoria dos drinks utilizando <b>TableView</b>.</p> 

<b>CategoriasTableViewCell.swift</b>
<br/><p>  - Recursos que fazem parte da linha (ROW) da tabela das categorias</p>

<b>ItensCategoriaViewController.swift</b>
<br/><p>  - Este arquivo é responsável pela leitura e exibição dos drinks de cada categori. Aqui é feita a conexão com a api e a população da tabela de drinks utilizando <b>TableView</b></p>

<b>ItensCategoriaTableViewCell.swift</b>
<br/><p>  - Recursos que fazem parte da linha (ROW) da tabela de drinks das categorias</p>

<b>ItemDetailViewController.swift</b>
<br/><p>  - Página de detalhe do drink, onde exibe a instrução, ingredientes e modo de preparo do drink</p>

## Setup inicial -> CategoriasViewController.swift

A url é personalizada para leitura das categorias individualmente
```SWIFT
let urlCategorias = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
```

Para ler os dados do json utilizaremos o Alamofire para persistir os dados e requisitá-los e assim adicionar esses dados em um array

-> "strCategory" é a chave para chamar o nome da categoria do drink, neste caso irá retornar os nomes de categorias para adicionar no array de categorias

```SWIFT
Alamofire.request(request).responseJSON { (response) in
  let categoriasJSON: JSON = JSON(response.result.value!)
                
  if (try? JSON(data: jsonDados)) != nil {
      for item in categoriasJSON["drinks"].arrayValue {
                        
          //  Inserindo os nomes das categorias do JSON no Array de categorias
          self.arrayCategorias.append(item["strCategory"].stringValue)
                        
          //  Inserindo as o array de categorias em Caching
          DataCache.instance.write(object: self.arrayCategorias as NSCoding, forKey: "categoriaNome")
                        
          //  Atualizando a tabela e removendo o loading
          self.tableView.reloadData()
          self.removeSpinner()       
    }
  }
}
```

## Caching dos dados
<br/>-> Após a leitura e o armazenamentos dos dados em um array utilizaremos o "DataCache" para armazenar o nome da categoria em caching, assim as categorias serão exibidas sem precisar de uma conexão com a internet

```SWIFT
DataCache.instance.write(object: self.arrayCategorias as NSCoding, forKey: "categoriaNome")
```

## ItensCategoriaViewController.swift
 
Após selecionar uma categoria na tabela da página "CategoriasViewController" irá para o setup dos drinks. Utilizando uma url personalizada conseguimos ler todos os drinks de uma categoria específica
```SWIFT
let urlDrinks = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=\(NomeDaCategoriaSelecionada)"
```
Utilizaremos o SDWebImage para fazer download em cache da imagem e exibir uma imagem padrão antes da imagem do drink ser carregada e assim iremos popular a tabela de drinks com a imagem e o nome do drink

```SWIFT
var nome = DataCache.instance.readObject(forKey: "nome") as! [String]
            cell.nomeDrink.text = nome[indexPath.row]
            
cell.imagemDrink.sd_setImage(with: URL(string: imagem[indexPath.row]), placeholderImage: UIImage(named: "default"))
```

o `DataCache.instance.readObject(forKey: "nome") as! [String]` está sendo utilizado para recuperar o nome do drink do caching para evitar uma nova requisição e utilização do processador, assim gerando performace

## Preenchendo a página de detalhe dos drinks -> ItemDetailViewController.swift

Para popular a lista da página de detalhes com a instrução, os ingredientes e o modo de preparo do drink faremos assim:

```SWIFT
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
```
Lembrando que a "Section 0" é a seção de instrução, "Section 1" a de ingredientes e "Section 2" a de modo de preparo
