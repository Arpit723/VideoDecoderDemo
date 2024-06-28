//
//  KSTimelineRulerView.swift
//  KSTimeline
//
//  Created by Shih on 24/11/2017.
//  Copyright © 2017 kenshih. All rights reserved.
//

import UIKit

@objc protocol KSTimelineRulerEventDataSource: NSObjectProtocol {
    
    func numberOfEvents(_ ruler: KSTimelineRulerView) -> Int
    
    func timelineRuler(_ ruler: KSTimelineRulerView, eventAt index: Int) -> KSTimelineEvent

}

@IBDesignable open class KSTimelineRulerView: UIView {
    
    static let unit_content_width = 2400.0

    var dataSource: KSTimelineRulerEventDataSource?
        
    var drawWave: Bool = false {
        
        didSet {
            
            self.setNeedsDisplay()
            
        }
        
    }
    
    lazy var dateFormatter: DateFormatter = {
        
        var dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM dd"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                
        return dateFormatter
        
    }()
    
    internal func drawEvent(rect: CGRect) {

        guard let dataSource = self.dataSource else { return }

        let numberOfEvents = dataSource.numberOfEvents(self)

        let padding = UIScreen.main.widthOfSafeArea()

        let contentWidth = self.bounds.width - padding
        

        let unit_hour_width =  KSTimelineRulerView.unit_content_width / 24
        
        let page = contentWidth / unit_hour_width

        //contentWidth
        let unit_minute_width = unit_hour_width / 60

        let unit_second_width = unit_minute_width / 60

        let unit_gap_height = CGFloat(20)

        let wave_height = CGFloat(5)

        for index in 0..<numberOfEvents {

            let event = dataSource.timelineRuler(self, eventAt: index)

            let start_hour = Calendar.current.component(.hour, from: event.start)

            let start_minute = Double(Calendar.current.component(.minute, from: event.start))

            let start_second = Double(Calendar.current.component(.second, from: event.start))

            let end_hour = Calendar.current.component(.hour, from: event.end)

            let end_minute = Double(Calendar.current.component(.minute, from: event.end))

            let end_second = Double(Calendar.current.component(.second, from: event.end))

            let start_x = (unit_hour_width * CGFloat(start_hour)) + (unit_minute_width * CGFloat(start_minute)) + (unit_second_width * CGFloat(start_second)) + (padding / 2)

            let end_x = (unit_hour_width * CGFloat(end_hour)) + (unit_minute_width * CGFloat(end_minute)) + (unit_second_width * CGFloat(end_second)) + (padding / 2)

            UIColor.blue.setFill()

            UIRectFill(CGRect(x: start_x, y: rect.size.height - wave_height - unit_gap_height, width: end_x - start_x, height: wave_height))

        }

    }

    override open func draw(_ rect: CGRect) {

        super.draw(rect)
        
        let padding = UIScreen.main.widthOfSafeArea()

        let contentWidth = self.bounds.width - padding

        //        print("contentWidth \(contentWidth)")
        let page = floor(contentWidth / KSTimelineRulerView.unit_content_width)

        let unit_hour_width = KSTimelineRulerView.unit_content_width / 24

        let unit_minute_width = unit_hour_width / 4
        
        let unit_second_width = unit_minute_width / 5

        //Height of the hour line in ruler
        let unit_hour_height = self.bounds.height / 4

        let unit_minute_height = unit_hour_height / 2

        let unit_sec_height = unit_minute_height / 2

        let show_hour = unit_hour_width > 10 ? true : false

        let show_minute = unit_minute_width > 10 ? true : false

        let show_second = unit_second_width > 10 ? true : false

        let unit_gap_height = CGFloat(20)

        var extra_padding = padding / 2
        
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
        ]
        
        let textDateFontAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.backgroundColor: UIColor.lightGray,
            NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
        ]
        
        let text_width = CGFloat(36)
        
        let text_height = CGFloat(12)
        
        UIColor.lightGray.setFill()

        if show_hour == true {

            let pageToTake = page == 0 ? 0 : page - 1

            for pageIndex in 0...Int(pageToTake) {
                for hour in 0...23 {
                    
                    //To draw in multiple pages added, added
                    let padding_page_wise = (KSTimelineRulerView.unit_content_width * Double(pageIndex))
                    let hour_x = CGFloat(hour) * unit_hour_width + extra_padding + padding_page_wise
                    
                    print("pageToTake \(pageIndex) hour_x \(hour_x) extra_padding \(extra_padding)")
                    
                    let hour_y = rect.size.height - unit_hour_height
                    
                    UIColor.red.setFill()
                    //Draw the hour line, for every hour
                    UIRectFill(CGRect(x: hour_x, y: hour_y - unit_gap_height, width: 1, height: unit_hour_height))
                    
                    if hour == 0 {
                        let text_x = hour_x - (text_width / 2) + 50
                        
                        let text_y = 0.0
                        
                        let dateToUse = KSTimelineView.offsetToDate(offset: text_x)
                        
                        //rect.size.height - 17
                        // Draw text to display every hour
                        (String(format: "%@", dateFormatter.string(from: dateToUse)) as NSString).draw(in: CGRect(x: text_x, y: text_y, width: 90.0, height: text_height), withAttributes: textDateFontAttributes)
                    }
                    if show_minute == true {
                        
                        for minute in 0..<5 {
                            
                            let minute_x = CGFloat(minute) * unit_minute_width
                            
                            let minute_y = rect.size.height - unit_minute_height
                            
                            UIColor.lightGray.setFill()
                            // Draw the minute line every 15 mins
                            UIRectFill(CGRect(x: hour_x + minute_x, y: minute_y - unit_gap_height, width: 1, height: unit_minute_height))
                            
                            if show_second == true {
                                
                                for second in 0..<5 {
                                    
                                    let second_x = CGFloat(second) * unit_second_width
                                    
                                    let second_y = rect.size.height - unit_sec_height
                                    
                                    UIColor.lightGray.setFill()
                                    
                                    UIRectFill(CGRect(x: hour_x + minute_x + second_x, y: second_y - unit_gap_height, width: 1, height: unit_sec_height))
                                    
                                }
                                
                            }
                            
                            if unit_minute_width > text_width {
                                
                                let text_x = hour_x + minute_x - (text_width / 2)
                                
                                let text_y = rect.size.height - 17
                                
                                (String(format: "%02d:%02d", hour, minute*10) as NSString).draw(in: CGRect(x: text_x, y: text_y, width: text_width, height: text_height), withAttributes: textFontAttributes)
                                
                            }
                            
                        }
                        
                    }
                    
                    let text_x = hour_x - (text_width / 2)
                    
                    let text_y = 0.0
                    //rect.size.height - 17
                    // Draw text to display every hour
                    (String(format: "%02d:00", hour) as NSString).draw(in: CGRect(x: text_x, y: text_y, width: text_width, height: text_height), withAttributes: textFontAttributes)
                    
                }
            }
            UIColor.lightGray.setFill()

//            UIRectFill(CGRect(x: extra_padding, y: 0, width: rect.size.width - extra_padding*2, height: 0.5))

            UIColor.red.setFill()

            UIRectFill(CGRect(x: extra_padding, y: rect.size.height - 20, width: rect.size.width - extra_padding*2, height: 2.0))

        }
        
        if self.drawWave {
            
            self.drawEvent(rect: rect)
            
        }
        
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clear
                
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    override open func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
    }

}
