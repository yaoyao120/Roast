//
//  CanvasTableViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-01-23.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import UIKit
import Photos

struct CanvasCellID {
    static let canvasImageCell = "CanvasImageCell"
    static let canvasHeaderCell = "CanvasHeaderCell"
    static let canvasTextCell = "CanvasTextCell"
    static let addNewCanvasCell = "AddNewCanvasCell"
}

enum CanvasType {
    case image
    case textField
    case header
    case footer
    case video
    case add
}

struct TextAlignment {
    static let left = "left"
    static let right = "right"
    static let center = "center"
    static let justified = "justified"
}

class CanvasViewController: UIViewController {
    
    let tableView: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    var keyBroadFrame: CGRect?
    let TOOLBAR_HEIGHT: CGFloat = 44
    let OFFSET_FROM_TOOLBAR: CGFloat = 10
    
    var canvas = Canvas()
    
    let placeholderAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "Oswald-Light", size: 30) as Any, NSForegroundColorAttributeName: UIColor.lightGray]
    let titleDefaultAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "Oswald-Light", size: 30) as Any, NSForegroundColorAttributeName: TextColor.textBlack]
    let paraDefaultAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 18) as Any, NSForegroundColorAttributeName: TextColor.textBlack]
    
    //MARK:- Canvas Table View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        registerReusableCell()
        registerKeyboardNotification()
        if canvas.dataSource.count == 0 {
            initializeNewCanvas()
        }
    }
    
    deinit {
        unregisterKeyboardNotification()
    }
    
    fileprivate func initializeNewCanvas() {
        
        //Add Header Cell Data
        let coverPlaceHolder = UIImage(named: "cover")
        let coverimageData = UIImagePNGRepresentation(coverPlaceHolder!)
        let title = NSAttributedString(string: "", attributes: titleDefaultAttribute)
        let headerCanvas = CanvasData(withCanvasType: CanvasType.header, imageData: coverimageData!, textContent: title)
        canvas.dataSource.append(headerCanvas)
        
        //Add Add Cell Data
        let addCanvas = CanvasData(withCanvasType: .add)
        canvas.dataSource.append(addCanvas)
        
    }
    
    //MARK: - User Interface Design Methods
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.bounces = true
        tableView.alwaysBounceVertical = true
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_close"), style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    //MARK: - User Interaction Handler Methods
    func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Configure canvas cell methods
    
    fileprivate func registerReusableCell() {
        
        tableView.register(CanvasImageCell.self, forCellReuseIdentifier: CanvasCellID.canvasImageCell)
        let canvasHeaderCellNib = UINib(nibName: CanvasCellID.canvasHeaderCell, bundle: nil)
        tableView.register(canvasHeaderCellNib, forCellReuseIdentifier: CanvasCellID.canvasHeaderCell)
        tableView.register(CanvasTextCell.self, forCellReuseIdentifier: CanvasCellID.canvasTextCell)
        tableView.register(AddNewCanvasCell.self, forCellReuseIdentifier: CanvasCellID.addNewCanvasCell)
    }
    
    fileprivate func updateCellTag() {
        
        for i in 0..<canvas.dataSource.count {
            let type = canvas.dataSource[i].canvasType!
            let indexPath = IndexPath(row: i, section: 0)
            switch type {
            case CanvasType.image:
                if let cell = tableView.cellForRow(at: indexPath) as? CanvasImageCell {
                    cell.singleImageView.tag = i
                    print("*** tag at row \(i) updated")
                }
            case CanvasType.header:
                if let cell = tableView.cellForRow(at: indexPath) as? CanvasHeaderCell {
                    cell.coverImageView.tag = i
                    cell.titleTextView.tag = i
                    cell.titleTextView.toolBar.tag = i
                    print("*** tag at row \(i) updated")
                }
            case CanvasType.textField:
                if let cell = tableView.cellForRow(at: indexPath) as? CanvasTextCell {
                    cell.textView.tag = i
                    cell.textView.toolBar.tag = i
                    print("*** tag at row \(i) updated")
                }
            case CanvasType.add:
                if let cell = tableView.cellForRow(at: indexPath) as? AddNewCanvasCell {
                    cell.addButton.tag = i
                    print("*** tag at row \(i) updated")
                }
            default:
                break
            }
        }
    }
    
    //MARK: - Keyboard Methods
    
    fileprivate func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    fileprivate func unregisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
                keyBroadFrame = keyboardFrame
                
            }
        }
    }
    
}

extension CanvasViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source and delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return canvas.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let canvasData = canvas.dataSource[indexPath.row]
        switch canvasData.canvasType! {
        case CanvasType.image:
            let cell = tableView.dequeueReusableCell(withIdentifier: CanvasCellID.canvasImageCell, for: indexPath) as! CanvasImageCell
            cell.configureCellWithImageData(canvasData.imageData!, tag: indexPath.row)
            cell.delegate = self
            
            return cell
        case CanvasType.header:
            let cell = tableView.dequeueReusableCell(withIdentifier: CanvasCellID.canvasHeaderCell, for: indexPath) as! CanvasHeaderCell
            cell.configureHeaderCellWith(tableView.bounds.width, imageData: canvasData.imageData!, text: canvasData.richText!, tag: indexPath.row)
            cell.titleTextView.delegate = self
            cell.titleTextView.editorDelegate = self
            cell.titleTextView.toolBar.imageDelegate = self
            cell.delegate = self
            
            return cell
        case CanvasType.textField:
            let cell = tableView.dequeueReusableCell(withIdentifier: CanvasCellID.canvasTextCell, for: indexPath) as! CanvasTextCell
            cell.configureTextCellWithContent(tableView.bounds.width, textContent: canvasData.richText!, tag: indexPath.row)
            cell.textView.delegate = self
            cell.textView.editorDelegate = self
            cell.textView.toolBar.imageDelegate = self
            
            return cell
        case CanvasType.add:
            let cell = tableView.dequeueReusableCell(withIdentifier: CanvasCellID.addNewCanvasCell, for: indexPath) as! AddNewCanvasCell
            cell.delegate = self
            cell.addButton.tag = indexPath.row
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CanvasCellID.canvasImageCell, for: indexPath) as! CanvasImageCell
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let canvasData = canvas.dataSource[indexPath.row]
        switch canvasData.canvasType! {
        case CanvasType.image:
            var height: CGFloat = 100
            if let image = UIImage(data: canvasData.imageData!) {
                let imageWidth = image.size.width
                let scaleRatio = imageWidth / (tableView.bounds.width - 30)
                let imageHeight = image.size.height
                height = (imageHeight / scaleRatio) + 20
            }
            return height
        case CanvasType.header:
            var height: CGFloat = 200
            if let image = UIImage(data: canvasData.imageData!) {
                let imageWidth = image.size.width
                let scaleRatio = imageWidth / (tableView.bounds.width)
                let imageHeight = image.size.height
                let heightByImage = (imageHeight / scaleRatio)
                
                let attributedString = canvasData.richText
                let testView = UITextView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude))
                if attributedString?.length == 0 {
                    //If no string, make one
                    testView.attributedText = NSAttributedString(string: "TEST", attributes: titleDefaultAttribute )
                } else {
                    testView.attributedText = attributedString
                }
                let rect = testView.sizeThatFits(CGSize(width: view.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude))
                let heightByTitle = rect.height
                
                height = heightByImage + heightByTitle
            }
            
            return height
        case CanvasType.textField:
            
            let attributedString = canvasData.richText
            let testView = UITextView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude))
            testView.attributedText = attributedString
            let rect = testView.sizeThatFits(CGSize(width: view.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude))
            let height = rect.height
            
            return height
        case CanvasType.add:
            return view.bounds.height / 1.5
        default:
            return 50
        }
    }

}

//MARK: - UITextView Methods

extension CanvasViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let canvasData = canvas.dataSource[textView.tag]
        canvasData.richText = textView.attributedText
        //Update the cell height without reloading the cell
        tableView.beginUpdates()
        tableView.endUpdates()
        
        //Scroll to Selected Range to Editing Position
        scrollSelectedTextToEditingPosition(textView, range: textView.selectedRange, checkPosition: true)
        
        print(textView.attributedText.string)
        print("*** textView did change")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let oldText = textView.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        if let richTextView = textView as? RichTextView {
            if newText.isEmpty {
                richTextView.showPlaceHolderLabel()
            } else {
                richTextView.hidePlaceHolderLabel()
            }
        }
        print("*** textView should change text")
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        print("*** textView should begin Editing")
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        DispatchQueue.main.async {
            //Scroll to Selected Range to Editing Position
            self.scrollSelectedTextToEditingPosition(textView, range: textView.selectedRange, checkPosition: true)
        }
        print("*** textView did begin Editing")
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if canvas.dataSource[textView.tag].canvasType == CanvasType.textField {
            if textView.text.isEmpty {
                canvas.dataSource.remove(at: textView.tag)
                tableView.deleteRows(at: [IndexPath(row: textView.tag, section: 0)], with: .automatic)
                //Update all cell tags
                updateCellTag()
            }
        }
        
        print("*** textView did End Editing")
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if let richTextView = textView as? RichTextView {
            richTextView.toolBar.updateToolBarWithAttribute(textView.typingAttributes)
        }
        
        print("*** textView did change selection")
    }
    
    fileprivate func scrollSelectedTextToEditingPosition(_ textView: UITextView, range: NSRange, checkPosition: Bool) {
        
        let textHeight = textView.heightOfTextBeforeRange(range, attributes: paraDefaultAttribute)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as? CanvasTextCell {
            if let keyFrame = keyBroadFrame {
                let visibleHeight = tableView.bounds.height - keyFrame.height - TOOLBAR_HEIGHT - OFFSET_FROM_TOOLBAR
                let textYInTableView = cell.frame.origin.y + cell.textView.frame.origin.y + textHeight
                if checkPosition {
                    DispatchQueue.main.async {
                        let currentOffset = self.tableView.contentOffset.y
                        if textYInTableView > currentOffset + visibleHeight {
                            self.tableView.setContentOffset(CGPoint(x: 0, y: textYInTableView - visibleHeight), animated: true)
                        }
                    }
                    
                } else {
                    tableView.setContentOffset(CGPoint(x: 0, y: textYInTableView - visibleHeight), animated: true)
                }
            }
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as? CanvasHeaderCell {
            if let keyFrame = keyBroadFrame {
                let visibleHeight = tableView.bounds.height - keyFrame.height - TOOLBAR_HEIGHT - OFFSET_FROM_TOOLBAR
                let textYInTableView = cell.frame.origin.y + cell.titleTextView.frame.origin.y + textHeight
                if checkPosition {
                    let currentOffset = tableView.contentOffset.y
                    if textYInTableView > currentOffset + visibleHeight {
                        tableView.setContentOffset(CGPoint(x: 0, y: textYInTableView - visibleHeight), animated: true)
                    }
                } else {
                    tableView.setContentOffset(CGPoint(x: 0, y: textYInTableView - visibleHeight), animated: true)
                }
            }
        }
        
    }
    
}

extension CanvasViewController: RichTextViewDelegate {
    func richTextViewDidChangeFont(_ textView: RichTextView, newAttributedString: NSAttributedString) {
        canvas.dataSource[textView.tag].richText = newAttributedString
    }
    
}

extension CanvasViewController: AddNewCanvasCellDelegate {
    
    func addNewCanvasCellDidTapAddButton(_ addButton: UIButton) {
        
        let attrText = NSAttributedString(string: "", attributes: paraDefaultAttribute)
        let newCanvasData = CanvasData(withCanvasType: .textField, textContent: attrText)
        canvas.dataSource.insert(newCanvasData, at: addButton.tag)
        
        let insertIndexPath = IndexPath(row: addButton.tag, section: 0)
        tableView.insertRows(at: [insertIndexPath], with: UITableViewRowAnimation.automatic)
        
        //Update all cell tags
        updateCellTag()
        
        if let cell = tableView.cellForRow(at: insertIndexPath) as? CanvasTextCell {
            cell.textView.becomeFirstResponder()
        }
    }
}

extension CanvasViewController: TextEditorTooBarImageDelegate {
    
    func textEditorToolBarDidTapAddImageButton(_ toolBar: TextEditorToolBar) {
        
        var pickerTag = toolBar.tag + 1
        if let cell = tableView.cellForRow(at: IndexPath(row: toolBar.tag, section: 0)) as? CanvasTextCell {
            if cell.textView.text.isEmpty {
                pickerTag = pickerTag - 1
            }
        }
        
        let imagePicker = ImagePickerViewController(nibName: "ImagePickerViewController", bundle: nil)
        imagePicker.setupImagePickerWithLimit(PickerMode.pickArticalImage, max: 99, highQuality: true)
        imagePicker.tag = pickerTag
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension CanvasViewController: ImagePickerViewControllerDelegate {
    
    func imagePickerViewControllerDidFinishPicking(_ imagePicker: ImagePickerViewController, data: [Data], assets: [PHAsset]) {
        
        guard data.count != 0 else {return}
        for i in 0..<data.count {
            
            let canvasData = CanvasData(withCanvasType: CanvasType.image, imageData: data[i])
            canvas.dataSource.insert(canvasData, at: imagePicker.tag + i)
        }
        //Update tableview and cell tags
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
}

extension CanvasViewController: CanvasImageCellDelegate {
    
    func canvasImageCellDidTapDeleteButtonIn(_ imageView: UIImageView) {
        
        //Must delete data first and delete row after that
        canvas.dataSource.remove(at: imageView.tag)
        tableView.deleteRows(at: [IndexPath(row: imageView.tag, section: 0)], with: .automatic)
        //Update all cell tags
        updateCellTag()
    }
    
    func canvasImageCellDidTapImageView(_ imageView: UIImageView) {
        tableView.scrollToRow(at: IndexPath(row: imageView.tag, section: 0), at: .top, animated: true)
        
    }
}

extension CanvasViewController: CanvasHeaderCellDelegate {
    
    func canvasHeaderCellDidTapImageView(_ imageView: UIImageView) {
        
    }
    
    func canvasHeaderCellDidTapDeleteButtonIn(_ imageView: UIImageView) {
        
    }
}
