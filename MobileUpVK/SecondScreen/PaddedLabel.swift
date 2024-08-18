//
//  Project name: MobileUpVK
//  File name: PaddedLabel.swift
//
//  Copyright © Gromov V.O., 2024
//

import UIKit

class PaddedLabel: UILabel {
    var padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: padding)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}
