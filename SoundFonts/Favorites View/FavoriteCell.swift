//
//  SoundFontPatchCell.swift
//  SoundFonts
//
//  Created by Brad Howes on 12/21/18.
//  Copyright © 2018 Brad Howes. All rights reserved.
//

import UIKit

/**
 Specialization of `UICollectionViewCell` that knows how to render Favoite attributes.
 */
final class FavoriteCell: UICollectionViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var name: UILabel!

    @IBInspectable var normalBackgroundColor: UIColor!
    @IBInspectable var normalForegroundColor: UIColor!
    @IBInspectable var activeBackgroundColor: UIColor!
    @IBInspectable var activeForegroundColor: UIColor!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    /**
     Show the Favorite name and `active` indicator.
    
     - parameter name: the name to show
     - parameter isActive: true if the Favorite's patch is currently active.
     */
    func update(name: String, isActive: Bool) {
        self.name.text = name
        if isActive {
            self.backgroundColor = activeBackgroundColor
            self.name.textColor = activeForegroundColor
        }
        else {
            self.backgroundColor = normalBackgroundColor
            self.name.textColor = normalForegroundColor
        }
        
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return contentView.systemLayoutSizeFitting(targetSize)
    }

    private func setupView() {
        name.text = "Hello!"

        contentView.translatesAutoresizingMaskIntoConstraints = false
        invalidateIntrinsicContentSize()
    }
}
