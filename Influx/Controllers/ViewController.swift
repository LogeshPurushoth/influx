//
//  ViewController.swift
//  Influx
//
//  Created by Logesh on 01/11/21.
//  Copyright © 2021 logesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var popOverView: UIView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    var popOverViewController : PopOverViewController? = nil
    var photos = [Image]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getImagesFromServer()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! photosCollectionViewCell
        let link = "https://api.opendota.com" + photos[indexPath.row].img
        cell.imageView.downloadedFrom(link: link)
        cell.imageView.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell : photosCollectionViewCell = collectionView.cellForItem(at: indexPath) as? photosCollectionViewCell {
            cell.backgroundColor = .blue
            cell.imageView.layer.cornerRadius = 0.5
            let selectedSourceView = self.imagesCollectionView.cellForItem(at: indexPath) as! photosCollectionViewCell
            let selectedSourceRect = selectedSourceView.imageView.convert(selectedSourceView.imageView.bounds, to: self.view)
            let popController = UIStoryboard(name: "popOverList", bundle: nil).instantiateViewController(withIdentifier: "popOver") as! PopOverViewController
            popController.modalPresentationStyle = UIModalPresentationStyle.popover
            popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            popController.popoverPresentationController?.delegate = self
            popController.popoverPresentationController?.sourceView = self.view
            popController.popoverPresentationController?.sourceRect = selectedSourceRect
            popController.preferredContentSize = CGSize(width: 420, height: 150)
            self.present(popController, animated: true, completion: nil)
            popController.lblHeroName.text = self.photos[indexPath.item].localized_name
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell : photosCollectionViewCell = collectionView.cellForItem(at: indexPath) as? photosCollectionViewCell {
            cell.backgroundColor = .clear
        }
    }
        
    internal func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func getImagesFromServer() {
        if let url = URL(string: "https://api.opendota.com/api/heroStats")
        {
            URLSession.shared.dataTask(with: url)
            { (data, response, error) in
                if error == nil
                {
                    do {
                        self.photos = try JSONDecoder().decode([Image].self, from: data!)
                        DispatchQueue.main.async {
                            self.imagesCollectionView.reloadData()
                        }
                    }catch {
                        print("\(self.photos.count)")
                    }
                } else
                {
                    print("error")
                }
            }.resume()
        }
    }
    extension UIImageView {
        func downloadedFrom(url: URL,contentMode mode: UIView.ContentMode = .scaleAspectFit) {
            contentMode = mode
            URLSession.shared.dataTask(with: url)
            { (data, response, error) in
                if error == nil {
                   let image = UIImage(data: data!)!
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
                else {
                    print("")
                }
            }.resume()
        }
        
        func downloadedFrom(link: String,contentMode mode: UIView.ContentMode = .scaleAspectFit) {
            guard let url = URL(string: link) else {
                return
            }
            downloadedFrom(url: url, contentMode: mode)
        }
    }
}

