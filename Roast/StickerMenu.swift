//
//  StickerMenu.swift
//  Roast
//
//  Created by Xiang Li on 2017-06-12.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol StickerMenuDelegate: class {
    func stickerMenuDidSelectSticker(image: UIImage)
    func stickerMenuDidSelectPickImage()
}

class StickerMenu: UIView {
    
    weak var delegate: StickerMenuDelegate?
    
    fileprivate let cellID = "CellID"
    var stickers: [UIImage] = [#imageLiteral(resourceName: "add_button"), #imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face"),#imageLiteral(resourceName: "face")]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        cv.register(StickerMenuCell.self, forCellWithReuseIdentifier: self.cellID)
        cv.bounces = true
        cv.alwaysBounceHorizontal = true
        cv.alwaysBounceVertical = false
        cv.isScrollEnabled = true
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension StickerMenu: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! StickerMenuCell
        cell.imageView.image = stickers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.height - 8, height: frame.height - 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("*** selected stickermenu")
        if indexPath.item == 0 {
            delegate?.stickerMenuDidSelectPickImage()
        } else {
            let image = stickers[indexPath.item]
            delegate?.stickerMenuDidSelectSticker(image: image)
        }
    }
    
}

class StickerMenuCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        backgroundColor = .lightGray
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
