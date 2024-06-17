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
  

    @IBOutlet weak var imageView: UIImageView!
    var decoder: VideoDecoder!
    var fps: Int = 20
    var type: EncodeType = .h264
    
    var videoFileReader: VideoFileReader!
    var decodeQueue = DispatchQueue(label: "com.videoDecoder.queue")
    var timer: Timer?
    var timerCounter = 1
    var decodeTimer: DispatchSourceTimer?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        videoFileReader = .init(.h264,counter: timerCounter)

        decoder = H264Decoder(delegate: self)
        timer = Timer.scheduledTimer(timeInterval: 0.001
                                     , target: self, selector: #selector(self.supplyDataToDecode), userInfo: nil, repeats: true)
    }
//    func setupTimer() {
//        if let _ = decodeTimer {
//            return
//        }
//        decodeTimer = DispatchSource.makeTimerSource(queue: decodeQueue)
//        decodeTimer?.schedule(deadline: .now(), repeating: .microseconds(1000000/fps))
//        takeVideoPackets()
//        decodeTimer?.setEventHandler(handler: {
//            self.takeVideoPackets()
//         })
//    }
//
    @objc  func supplyDataToDecode() {
        self.takeVideoPackets()
     }

    func takeVideoPackets() {
        //This is not the case in actual projects
        if let videoPacket = videoFileReader.nextVideoPacket()  {
            print("videoPacket found")
            decoder.decodeOnePacket(videoPacket)
        }else {//end
            print("takeVideoPackets is nil")
            timerCounter += 1
            videoFileReader = .init(.h264,counter: timerCounter)
            if timerCounter == 150 {
                timer?.invalidate()
                timer = nil
                Utility.showAlert(vc: self, title: "No more frames to show", message: "")
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
        
