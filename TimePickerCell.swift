//
//  TimePickerCell.swift
//  Out
//
//  Created by Stephen Silber on 4/22/16.
//  Copyright © 2016 Out. All rights reserved.
//

import Foundation
import UIKit

class TimePickerCell: UICollectionViewCell {
    private var marksDrawn = false
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.textColor     = .color1shade2()
        label.font          = .gothamFontOfSize(14)
        label.textAlignment = .Center
        
        return label
    }()
    
    let nowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.baseColor()
        return view
    }()
    
    let nowLabel: UILabel = {
        let label = UILabel()
        label.text          = NSLocalizedString("now", comment: "Now").uppercaseString
        label.textColor     = .color1shade2()
        label.font          = .gothamFontOfSize(10)
        label.textAlignment = .Center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clearColor()
        
        addSubview(descriptionLabel)
        descriptionLabel.snp_makeConstraints { (make) in
            make.top.bottom.equalTo(self).inset(35)
            make.leading.trailing.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if !marksDrawn {
            drawTimeMarks()
        }
    }
    
    private func drawTimeMarks() {
        let lineWidth: CGFloat = UIScreen.screenPixel()
        let notchesPerHour = 12
        let context = UIGraphicsGetCurrentContext()
        let color = UIColor.whiteColor().colorWithAlphaComponent(0.25)
        let width = CGRectGetWidth(frame)
        let spacing = (width / (CGFloat(notchesPerHour) * 6))

        var xPosition: CGFloat = 0
        for _ in 0...notchesPerHour * 6 {
            CGContextSaveGState(context)
            
            let topPath = UIBezierPath()
            topPath.moveToPoint(CGPointMake(xPosition, 0))
            topPath.addLineToPoint(CGPointMake(xPosition, 35))
            color.setStroke()
            topPath.lineWidth = lineWidth
            topPath.stroke()
            
            let bottomPath = UIBezierPath()
            bottomPath.moveToPoint(CGPointMake(xPosition, 65))
            bottomPath.addLineToPoint(CGPointMake(xPosition, 100))
            color.setStroke()
            bottomPath.lineWidth = lineWidth
            bottomPath.stroke()
            
            CGContextRestoreGState(context)
            
            xPosition += spacing
        }
        
        marksDrawn = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nowContainer.removeFromSuperview()
    }
    
    func drawNowMark(markPosition: CGFloat) {
        nowContainer.addSubview(nowLabel)
        addSubview(nowContainer)
        
        // Handle case where now is at the far left of the picker
        var position = markPosition
        if position < CGRectGetWidth(nowLabel.frame) {
            position += CGRectGetWidth(nowLabel.frame) / 2
        }
        nowContainer.backgroundColor = .baseColor()
        
        nowContainer.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.snp_leading).offset(position)
            make.bottom.equalTo(self.snp_top).offset(35)
        }
        nowLabel.snp_makeConstraints { (make) in
            make.edges.equalTo(nowContainer).inset(5)
        }
    }
    
    func configure(dayPeriod period: DayPeriod) {
        self.descriptionLabel.text = period.description
    }
}
