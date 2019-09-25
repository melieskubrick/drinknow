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

  <p align="center">
   O DRINKNOW é um aplicativo que te ajuda a preparar os melhores drinks! Nele você pode selecionar uma categoria de drink específico, selecionar o drink e ver todo o seu modo de preparo! É bem simples, escolha agora mesmo seu drink e aprecie com moderação.
</p>

### Pods Utilizados
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


<!-- GETTING STARTED -->
## Conhecendo os Arquivos
Aqui estão os arquivos e suas devidas funcionalidades dentro desta aplicação

<b>CategoriasViewController.swift</b>
<br/>-> Arquivo responsável pela leitura e exibição das categorias de drinks através da API do <b>thecocktaildb<b/>

<b>CategoriasTableViewCell.swift</b>
<br/>-> Recursos que fazem parte da linha (ROW) da tabela das categorias

<b>ItensCategoriaViewController.swift</b>
<br/>-> Este arquivo é responsável pela leitura e exibição dos drinks de cada categoria

<b>ItensCategoriaTableViewCell.swift</b>
<br/>-> Recursos que fazem parte da linha (ROW) da tabela de drinks das categorias

<b>ItemDetailViewController.swift</b>
<br/>-> Página de detalhe do drink, onde exibe a instrução, ingredientes e modo de preparo do drink

## Setup inicial -> CategoriasViewController.swift

A url é personalizada para leitura das categorias individualmente
```SWIFT
let urlCategorias = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
```

Para ler os dados do json adicionamos utilizaremos o Alamofire para persistir os dados e requisitá-los para adicionar em um array

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

Após a leitura do json a partir da url os dados ficam armazenados em um "Dictionary", onde podem ser resgatados pela chave de identificação do item no json

-> "strCategory" é a chave para chamar o nome do drink, neste caso irá retornar o nome da categoria para exibir na tabela de categorias
```SWIFT
 item["strCategory"].stringValue
 ```
 
<b>Caching dos dados</b>
<br/>-> Após a leitura e o armazenamentos dos dados em um array utilizaremos o "DataCache" para armazenar o nome da categoria em caching, assim as categorias serão exibidas sem precisar de uma conexão com a internet

```SWIFT
DataCache.instance.write(object: self.arrayCategorias as NSCoding, forKey: "categoriaNome")
```

## ItensCategoriaViewController.swift
 
Após selecionar uma categoria na tabela da página "CategoriasViewController" irá para o setup dos drinks. Utilizando uma url personalizada conseguimos ler todos os drinks de uma categoria específica
```SWIFT
let urlDrinks = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=\(NomeDaCategoriaSelecionada)"
```



### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* npm
```sh
npm install npm@latest -g
```

### Installation

1. Get a free API Key at [https://example.com](https://example.com)
2. Clone the repo
```sh
git clone https:://github.com/your_username_/Project-Name.git
```
3. Install NPM packages
```sh
npm install
```
4. Enter your API in `config.js`
```JS
const API_KEY = 'ENTER YOUR API';
```



<!-- USAGE EXAMPLES -->
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_



<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/othneildrew/Best-README-Template/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Your Name - [@your_twitter](https://twitter.com/your_username) - email@example.com

Project Link: [https://github.com/your_username/repo_name](https://github.com/your_username/repo_name)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
* [Img Shields](https://shields.io)
* [Choose an Open Source License](https://choosealicense.com)
* [GitHub Pages](https://pages.github.com)
* [Animate.css](https://daneden.github.io/animate.css)
* [Loaders.css](https://connoratherton.com/loaders)
* [Slick Carousel](https://kenwheeler.github.io/slick)
* [Smooth Scroll](https://github.com/cferdinandi/smooth-scroll)
* [Sticky Kit](http://leafo.net/sticky-kit)
* [JVectorMap](http://jvectormap.com)
* [Font Awesome](https://fontawesome.com)





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=flat-square
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=flat-square
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=flat-square
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=flat-square
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=flat-square
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
