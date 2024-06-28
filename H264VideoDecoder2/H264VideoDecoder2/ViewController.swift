//
//  ViewController.swift
//  H264VideoDecoder2
//
//  Created by Ravi Chokshi on 15/06/24.
//

import UIKit
import VideoToolbox
import VideoDecoder
import AVFoundation

class ViewController: UIViewController {
  
    @IBOutlet weak var timeLineView: KSTimelineView!
    
    @IBOutlet weak var baseDateLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var decoder: VideoDecoder!
    var fps: Double = 80.0
    var type: EncodeType = .h264
    
    var videoFileReader: VideoFileReader!
    var decodeQueue = DispatchQueue(label: "com.videoDecoder.queue")
    var timer: Timer?
    var decodeTimer: DispatchSourceTimer?

    var timerCounter = 1
    var baseDate: Date?

    lazy var dateFormatter: DateFormatter = {
        
        var dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                
        return dateFormatter
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timeLineView.delegate = self
        videoFileReader = .init(.h264,counter: timerCounter)
        decoder = H264Decoder(delegate: self)
        startTimer()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1/fps
                                     , target: self, selector: #selector(self.supplyDataToDecode), userInfo: nil, repeats: true)
        
    }
    @objc  func supplyDataToDecode() {
        self.takeVideoPackets()
     }

    func takeVideoPackets() {
        //This is not the case in actual projects
        if let videoPacket = videoFileReader.nextVideoPacket()  {
//            print("videoPacket found")
            decoder.decodeOnePacket(videoPacket)
        }else {//end
//            print("takeVideoPackets is nil")
            timerCounter += 1
            videoFileReader = .init(.h264,counter: timerCounter)
            
            //TimeeCounter -> Starts from base date -> Date
            if let newDateToScroll = self.baseDate?.addingTimeInterval(floor(Double(timerCounter)/fps)) {
                print("Scrolling timeline view")
                self.dateLbl.text = self.dateFormatter.string(from: newDateToScroll)
                self.timeLineView.scrollToDate(date: newDateToScroll)
            }
            
            if timerCounter >= 7590 {
                timer?.invalidate()
                timer = nil
                Utility.showAlert(vc: self, title: "No more frames to show", message: "")
            } else {
                takeVideoPackets()
            }
        }
    }

}

extension ViewController:  VideoDecoderDelegate {
    func decodeOutput(video: CMSampleBuffer) {
        if let image = video.image {
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    func decodeOutput(error: DecodeError) {
        print("error: \(error.localizedDescription)")
    }
    
}
        
extension ViewController: KSTimelineDelegate {
    
    func timelineStartScroll(_ timeline: KSTimelineView) {
        print(#function)
    }

    func timelineEndScroll(_ timeline: KSTimelineView) {
        print(#function)
    }
    
    func timeline(_ timeline: KSTimelineView, didScrollTo date: Date) {
        print(#function)
    }
    
    func updateVideoFrame(for date: Date) {
        print(#function)
        self.dateLbl.text = self.dateFormatter.string(from: date)
        let  timeDifference = abs(self.baseDate?.timeIntervalSince(date) ?? 0.0)
        print("timedifference \(timeDifference)")
        let newFileCounter = timeDifference * fps
//        print("newFileCounter \(newFileCounter)")
        self.timerCounter = Int(newFileCounter)
        if timerCounter <= 7590 && timer == nil {
            startTimer()
        }
    }
    
    func setBaseDate(date: Date) {
        self.baseDate = date
        self.baseDateLbl.text = self.dateFormatter.string(from: date)
        self.timeLineView.scrollToDate(date: date)
        timerCounter = 0
    }
}
