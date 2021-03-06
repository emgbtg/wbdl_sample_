//
//  ComicDetailsViewController.swift
//  WBDL_Sample
//
//  Created by Eric Gilbert on 10/13/18.
//  Copyright © 2018 Eric Gilbert. All rights reserved.
//

import UIKit

class SeriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
}
class ComicCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
}

class ComicDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var comicSeriesTitleLabel: UILabel!
    @IBOutlet weak var characterSectionLabel: UILabel!
    
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var comicSeriesCollectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pageCountLabel: UILabel!
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    var comicsInSeriesDict: [String:String] = [:]
    var characters: [CharacterInfo]!
    var comic: Comic!
    var seriesKeys: [String] = []
    private var cache = [UICollectionViewLayoutAttributes]()
    //var series:
    
    override func viewWillAppear(_ animated: Bool) {
        // Data is often incomplete in this API. This logic will adjust the layout accordingly.
        var newHeight = containerView.frame.size.height
        if characters.count == 0 || comicsInSeriesDict.count <= 1 {
            if characters.count == 0 {
                newHeight -= (charactersCollectionView.frame.size.height + characterSectionLabel.frame.size.height)
                characterSectionLabel.isHidden = true
                charactersCollectionView.isHidden = true
            }
            if comicsInSeriesDict.count <= 1 {
                newHeight -= comicSeriesTitleLabel.frame.size.height + comicSeriesCollectionView.frame.size.height
                comicSeriesCollectionView.isHidden = true
                comicSeriesTitleLabel.isHidden = true
                if characters.count > 0 {
                    characterSectionLabel.frame.origin.y = descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 20
                    charactersCollectionView.frame.origin.y = characterSectionLabel.frame.origin.y + characterSectionLabel.frame.size.height + 20
                }
            }
            containerViewHeightConstraint.constant = newHeight
            
        } else {
            containerViewHeightConstraint.constant = 1200
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.imageFromServerURL(urlString: comic.thumbnail.path + "." + comic.thumbnail.thumbnailExtension.rawValue)
        titleLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.text = comic.title
        priceLabel.text = "Price: $" + String(comic.prices[0].price)
        pageCountLabel.text = "Pages: " + String(comic.pageCount)
        
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.text = comic.description ?? "No Description"
        comicSeriesTitleLabel.text = comic.series.name
        
        seriesKeys = Array(comicsInSeriesDict.keys)
        
        comicSeriesCollectionView.delegate  = self
        comicSeriesCollectionView.dataSource = self
        
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/2-10, height: 240)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        comicSeriesCollectionView.collectionViewLayout = flowLayout
        
        // need a seperate UICollectionViewFlowLayout for the second collection view to avoid layout issues.
        let flowLayout2 = UICollectionViewFlowLayout()
        flowLayout2.itemSize = CGSize(width: UIScreen.main.bounds.width/2-10, height: 240)
        flowLayout2.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout2.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout2.minimumInteritemSpacing = 0.0
        charactersCollectionView.collectionViewLayout = flowLayout2

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return comicsInSeriesDict.count
        } else if collectionView.tag == 1{
            return characters.count
        }
        return 0
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath as IndexPath) as! SeriesCollectionViewCell
            cell.containerView.layer.cornerRadius = 8
            cell.containerView.layer.masksToBounds = true
            
            cell.titleLabel.adjustsFontSizeToFitWidth = true
            cell.titleLabel.text = seriesKeys[indexPath.row]
            
            let thumbnailURL = comicsInSeriesDict[seriesKeys[indexPath.row]]
            cell.imageView.imageFromServerURL(urlString:thumbnailURL ?? "")
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "charactersCell", for: indexPath as IndexPath) as! ComicCollectionViewCell
            cell.titleLabel.adjustsFontSizeToFitWidth = true
            cell.titleLabel.text = characters[indexPath.row].name
            
            let thumbnailURL = characters[indexPath.row].thumbnail.path + "." + characters[indexPath.row].thumbnail.thumbnailExtension.rawValue
            cell.imageView.imageFromServerURL(urlString: thumbnailURL)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){

    }
    
}
