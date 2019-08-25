//
//  SetPhotoViewController.swift
//  FlickrFoto
//
//  Created by Сергей Терехин on 24/08/2019.
//  Copyright © 2019 Сергей Терехин. All rights reserved.
//

import UIKit
import Kingfisher

class SetPhotoViewController: UIViewController {
    var photo: Photo?
    
    @IBOutlet weak var photoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photobuf = photo, let url = URL(string: photobuf.photo)
        {
            photoImageView.kf.setImage(with: url)
        }
    }
    

 
}
