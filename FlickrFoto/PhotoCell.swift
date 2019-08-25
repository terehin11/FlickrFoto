//
//  PhotoCell.swift
//  FlickrPhoto
//
//  Created by Сергей Терехин on 25/08/2019.
//  Copyright © 2019 Сергей Терехин. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imageURL: String? {
        //didSet выполниться, когда поменяется значение imageURL.
        //загрузка изображений
        didSet{
            if let imageURL = imageURL, let url = URL(string: imageURL)
            {
                photoImageView.kf.setImage(with: url)
            }
            else
            {
                photoImageView.image = nil
                photoImageView.kf.cancelDownloadTask()//остановка загрузки из сети
            }
        }
    }
    //при прокрутке обнуляет изображение и как следствие останавливается загрузка фотографий
    override func prepareForReuse() {
        super.prepareForReuse()
        imageURL = nil
    }
}
