//
//  OverlayView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

enum GGOverlayViewMode {
    case ggOverlayViewModeLeft
    case ggOverlayViewModeRight
}

class OverlayView: UIView{
    var _mode: GGOverlayViewMode! = GGOverlayViewMode.ggOverlayViewModeLeft
    var imageView: UIImageView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(image: UIImage(named: "noButton"))
        self.addSubview(imageView)
    }

    func setMode(_ mode: GGOverlayViewMode) -> Void {
        if _mode == mode {
            return
        }
        _mode = mode

        if _mode == GGOverlayViewMode.ggOverlayViewModeLeft {
            imageView.image = UIImage(named: "noButton")
        } else {
            imageView.image = UIImage(named: "yesButton")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 400, width: 100, height: 100)
    }
}
