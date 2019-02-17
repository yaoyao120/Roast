//
//  TextEditorToolBar.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-27.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol TextEditorTooBarImageDelegate: class {
    func textEditorToolBarDidTapAddImageButton(_ toolBar: TextEditorToolBar)
}

protocol TextEditorTooBarTextDelegate: class {
    func textEditorToolBarDidSelectUndo()
    func textEditorToolBarDidSelectFont()
    func textEditorToolBarDidSelectBold()
    func textEditorToolBarDidSelectItalic()
    func textEditorToolBarDidSelectAlignment()
    func textEditorToolBarDidSelectColor(_ textColor: UIColor)
}

struct TextColor {
    static let textRed = UIColor.hex("#e2574c", alpha: 1)
    static let textOrange = UIColor.hex("#f37600", alpha: 1)
    static let textYellow = UIColor.hex("#fcc04e", alpha: 1)
    static let textGreen = UIColor.hex("52a557", alpha: 1)
    static let textBlue = UIColor.hex("1188ff", alpha: 1)
    static let textGold = UIColor.hex("#b79567", alpha: 1)
    static let textLightBlue = UIColor.hex("24c4f8", alpha: 1)
    static let textTiffanyBlue = UIColor.hex("81D8D0", alpha: 1)
    static let textPink = UIColor.hex("#ff3666", alpha: 1)
    static let textLightPick = UIColor.hex("#ffaec2", alpha: 1)
    static let textLightPurple = UIColor.hex("a6b7d8", alpha: 1)
    static let textPurple = UIColor.hex("#762889", alpha: 1)
    static let textGray = UIColor.gray
    static let textBlack = UIColor.hex("#3f3f3f", alpha: 1)
    
}

class TextEditorToolBar: UIView {
    
    let textColors: [UIColor] = [TextColor.textBlack, TextColor.textRed, TextColor.textOrange, TextColor.textYellow, TextColor.textGreen, TextColor.textBlue, TextColor.textGray, TextColor.textLightPick, TextColor.textTiffanyBlue, TextColor.textLightBlue, TextColor.textLightPurple, TextColor.textPink, TextColor.textGold, TextColor.textPurple]
    
    fileprivate let addImageImage = UIImage(named: "add_photo_btn")
    fileprivate let colorImage = UIImage(named: "text_color")
    
    weak var imageDelegate: TextEditorTooBarImageDelegate?
    weak var textDelegate: TextEditorTooBarTextDelegate?
    
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var italicButton: UIButton!
    @IBOutlet weak var alignmentButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var moreSelectionButton: UIButton!
    
    @IBOutlet weak var fontEditorView: UIView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    
    var shouldShowColorSelctionView = false

    class func instance() -> TextEditorToolBar {
        return UINib(nibName: "TextEditorToolBar", bundle: nil).instantiate(withOwner: self, options: nil).first as! TextEditorToolBar
    }
    
    func initialize() {
        
        //Setup view appearance
        self.backgroundColor = ymBackgroundColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        
        //Setup Color Collection View
        let colorCellNib = UINib(nibName: "ColorCollectionViewCell", bundle: nil)
        colorCollectionView.register(colorCellNib, forCellWithReuseIdentifier: "ColorCollectionViewCell")
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.isHidden = true
        colorCollectionView.isUserInteractionEnabled = false
        
        //Setup tool bar button
        
        colorButton.setImage(colorImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        colorButton.tintColor = TextColor.textBlack
    
        addImageButton.setImage(addImageImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        addImageButton.tintColor = ymDarkTintColor
        
        moreSelectionButton.tintColor = TextColor.textBlack
        moreSelectionButton.titleLabel?.text = "•••"
    }
    
    deinit {
        print("TextEditorToolBar did removed")
    }
    
    //User Interface Design Methods
    
    fileprivate func showColorSelectionView() {
        colorCollectionView.layer.removeAllAnimations()
        let barMover = CABasicAnimation(keyPath: "position.x")
        barMover.fromValue = colorCollectionView.bounds.width * 1.6
        barMover.toValue = colorCollectionView.center.x
        barMover.duration = 0.3
        barMover.isRemovedOnCompletion = true
        barMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let shower = CABasicAnimation(keyPath: "opacity")
        shower.fromValue = 0
        shower.toValue = 1
        shower.duration = 0.3
        shower.isRemovedOnCompletion = true
        shower.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let viewMover = CABasicAnimation(keyPath: "position.x")
        viewMover.fromValue = fontEditorView.center.x
        viewMover.toValue = fontEditorView.center.x * -1
        viewMover.duration = 0.3
        viewMover.isRemovedOnCompletion = true
        viewMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let fader = CABasicAnimation(keyPath: "opacity")
        fader.fromValue = 1
        fader.toValue = 0
        fader.duration = 0.3
        fader.isRemovedOnCompletion = true
        fader.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        colorCollectionView.layer.add(shower, forKey: "fadeIn")
        colorCollectionView.layer.add(barMover, forKey: "showColorBar")
        fontEditorView.layer.add(viewMover, forKey: "hideView")
        fontEditorView.layer.add(fader, forKey: "fadeOut")
        
        colorCollectionView.isHidden = false
        colorCollectionView.isUserInteractionEnabled = true
        
    }
    
    fileprivate func hideColorSelectionView() {
        let barMover = CABasicAnimation(keyPath: "position.x")
        barMover.fromValue = colorCollectionView.center.x
        barMover.toValue = colorCollectionView.bounds.width * 1.6
        barMover.duration = 0.3
        barMover.isRemovedOnCompletion = false
        barMover.fillMode = kCAFillModeForwards
        barMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let fader = CABasicAnimation(keyPath: "opacity")
        fader.fromValue = 1
        fader.toValue = 0
        fader.duration = 0.3
        fader.isRemovedOnCompletion = true
        fader.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let viewMover = CABasicAnimation(keyPath: "position.x")
        viewMover.fromValue = fontEditorView.center.x * -1
        viewMover.toValue = fontEditorView.center.x
        viewMover.duration = 0.3
        viewMover.isRemovedOnCompletion = true
        viewMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let shower = CABasicAnimation(keyPath: "opacity")
        shower.fromValue = 0
        shower.toValue = 1
        shower.duration = 0.3
        shower.isRemovedOnCompletion = true
        shower.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        colorCollectionView.layer.add(fader, forKey: "fadeOut")
        colorCollectionView.layer.add(barMover, forKey: "hideColorBar")
        fontEditorView.layer.add(viewMover, forKey: "showView")
        fontEditorView.layer.add(shower, forKey: "fadeIn")
        
        
        colorCollectionView.isUserInteractionEnabled = false
    }
    
    func updateToolBarWithAttribute(_ attribute: [String: Any]) {
        if let color = attribute[NSForegroundColorAttributeName] as? UIColor {
            UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.colorButton.tintColor = color
            }, completion: nil)
        }
        
        
    }
    
    //User Interaction Methods
    @IBAction func undo(_sender: UIButton) {
        textDelegate?.textEditorToolBarDidSelectUndo()
    }
    
    @IBAction func fontSelected(_ sender: UIButton) {
        textDelegate?.textEditorToolBarDidSelectFont()
    }
    
    @IBAction func boldSelected(_ sender: UIButton) {
        
        textDelegate?.textEditorToolBarDidSelectBold()
    }
    
    @IBAction func italicSelected(_ sender: UIButton) {
        textDelegate?.textEditorToolBarDidSelectItalic()
    }
    
    @IBAction func alignmentSelected(_ sender: UIButton) {
        textDelegate?.textEditorToolBarDidSelectAlignment()
    }
    
    @IBAction func colorSelected(_ sender: UIButton) {
        shouldShowColorSelctionView = !shouldShowColorSelctionView
        if shouldShowColorSelctionView {
            showColorSelectionView()
        } else {
            hideColorSelectionView()
        }
        colorButton.popWith(force: 1.4, duration: 1, repeatCount: 0, delay: 0)
        
    }
    
    @IBAction func didTapAddImageButton(_ sender: UIButton) {
        imageDelegate?.textEditorToolBarDidTapAddImageButton(self)
    }
    
    @IBAction func moreSelectionSelected(_ sender: UIButton) {
    }
    
}

extension TextEditorToolBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return textColors.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
        cell.colorButton.tintColor = textColors[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        colorButton.popWith(force: 1.4, duration: 1, repeatCount: 0, delay: 0)
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.colorButton.tintColor = self.textColors[indexPath.item]
        }, completion: nil)
        textDelegate?.textEditorToolBarDidSelectColor(textColors[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = colorCollectionView.bounds.height
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
