//
//  MainViewController.swift
//  FlickrFoto
//
//  Created by Сергей Терехин on 24/08/2019.
//  Copyright © 2019 Сергей Терехин. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
//Структура для парсинга строки url_q из JSON
struct Photo
{
    var photo: String
    
    init?(json: JSON)
    {
        guard let  url_q = json["url_q"].string else {return nil}
        self.photo = url_q
    }
}

class MainViewController: UIViewController {
    var photoImage: [Photo] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Progress()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
         //проверяем открыли ли мы контроллер и получаем индекс картинки, которую хотим открыть
        if let buf = segue.destination as? SetPhotoViewController, let indexPathCell = collectionView.indexPathsForSelectedItems?.first
        {
            buf.photo = photoImage[indexPathCell.row]
            
        }
    }
    
}

//Поисковая строка
extension MainViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) // called when keyboard search button pressed
    {
        searchBar.resignFirstResponder()//Убираем клавиатуру и посылаем новый запрос на сервер
        Progress(textSearch: searchBar.text)
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout
{
    //Переопределям метод отвечающий за размер ячейки.Изначально у нас был список, а нам нужна сетка
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let widthPhoto = collectionView.bounds.width/4
        return CGSize(width: widthPhoto, height: widthPhoto)
    }
}

//Расширения класса для реализации протокола DataSource. Также говорим, что наш контролеер может быть Delegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    //Поисковая строка
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionView.elementKindSectionHeader
        {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotoSearchHeader", for: indexPath) 
        }
        
        
        return reusableView
    }
//Сколько элементов в секции
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoImage.count
    }
    
    //Должны вернуть UI настроенную ячейку
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //возвращает ячейку, которая соответсвует indexPath и приводим к нашему типу ячеек
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        
        //берем элемент из массива, соответствующий indexPath, берем из него url, передаем в PhotoCell и она по url загружает картинку
        let photobuf = photoImage[indexPath.row]
        cell.imageURL = photobuf.photo //передаем url
        
        return cell
    }
    
}
//Расширение класса для Networking
extension MainViewController
{
    func Progress(textSearch: String? = nil)
    {
        MBProgressHUD.showAdded(to: view, animated: true)
        LoadFlickrFoto(textSearch: textSearch)
        {
            [weak self](photos)in
            guard let looping = self else {return} //превращает указатель из опционального в неопциональный. Помогает избежать зацикливания.
            MBProgressHUD.hide(for: looping.view, animated: true)
            
            if let buf = photos
            {
                looping.photoImage = buf
                looping.collectionView.reloadData()
            }
        }
        
    }
    
    }
    //Функция загрузки фотографий с сервера
    //textSeach - запрос. Может отсутствовать
    //complition - массив фотографий. Может отсутствовать или nil, если загрузка не удалась
    func LoadFlickrFoto(textSearch: String? = nil, complition: (([Photo]?)->Void)? = nil)
    {
        
        let url = URL(string: "https://www.flickr.com/services/rest/")!
        var param = [
            "method" : "flickr.interestingness.getList",//метод возвращает коллекцию фотографий
            "api_key" : "ec71d015083b2dfb6f4b2f24409cc156",
            "per_page" : "500",//кол-во фотографий на странице
            "format" : "json",
            "nojsoncallback" : "1",
            "extras" : "url_q"
        ]
        if let textSearchBuf = textSearch
        {
            param["method"] = "flickr.photos.search"
            param["text"] = textSearchBuf
        }
        //отправляем запрос и проверяем успешный ли он
        Alamofire.request(url, method: .get, parameters: param).validate()
            .responseData{(response) in //приходи bool resutl
        switch response.result{
        case .success: //если ответ пришел успышный мы пытаемся извлечь данные,если во время парсинга произошла ошибка, то сообщаем об ошибке и выходим
            guard let photo = response.data, let json = try? JSON(data: photo) else
            {
                print("Error while parsing JSON")
                complition?(nil)
                return
            }
            print("All OK! ")
            let photosJSON = json["photos"]["photo"] // получаем массив данных из JSON - json-объект
            let photos = photosJSON.arrayValue.compactMap {Photo (json: $0)}//получаем массив из json-объекта и приводим его к виду заданному типу
            complition?(photos)
        case .failure(let error):
            print("Error while load photo: \(error.localizedDescription)")
            complition?(nil)
                }
                
        }
    }


