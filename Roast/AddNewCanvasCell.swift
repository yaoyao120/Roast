//
//  AddNewCanvasCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-26.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol AddNewCanvasCellDelegate: class {
    func addNewCanvasCellDidTapAddButton(_ addButton: UIButton)
}

class AddNewCanvasCell: UITableViewCell {
    
    weak var delegate: AddNewCanvasCellDelegate?
    
    let addButton: UIButton = {
        let button = UIButton()
        return button
    }()

    let addImage = UIImage(named: "add_button")
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        addButton.tag = -1
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        setupAddButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupAddButton() {
        
        addSubview(addButton)
        addButton.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addButton.addTarget(self, action: #selector(addNewCanvas(_:)), for: .touchUpInside)
        addButton.setImage(addImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = ymDarkTintColor
    }

    func addNewCanvas(_ addButton: UIButton) {
        delegate?.addNewCanvasCellDidTapAddButton(addButton)
    }
    
    
}
