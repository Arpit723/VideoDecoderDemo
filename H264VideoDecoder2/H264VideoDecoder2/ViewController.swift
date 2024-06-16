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
    var timerCounter = 0
    var decodeTimer: DispatchSourceTimer?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        decoder = H265Decoder(delegate: self)
//        supplyDataToDecode()
//        setupTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.supplyDataToDecode), userInfo: nil, repeats: true)
     //   supplyDataToDecode()
        
        let fileUrl = Bundle.main.url(forResource: "frames-0090", withExtension: "h265")
         let player = AVPlayer(url: fileUrl!)
         player.play()
        
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

        timerCounter += 1

        videoFileReader = .init(.h265,counter: timerCounter)
        
        self.takeVideoPackets()

//        var name = String(format: "frames-%04d",timerCounter)
//         print("name of file \(name)")
//
//        if let filePathForResource = Bundle.main.url(forResource: name, withExtension: "h265") {
//            //       print("filePathForResource \(filePathForResource)")
//
//            do {
//                var data = try Data(contentsOf: filePathForResource)
//                print("data \(data.count)")
//                decoder.decodeOnePacket(data)
//            }
//            catch(let error) {
//                print(error.localizedDescription)
//            }
//            }

     }

    func takeVideoPackets() {
        //This is not the case in actual projects
        if let videoPacket = videoFileReader.nextVideoPacket()  {
            decoder.decodeOnePacket(videoPacket)
        }else {//end
//            videoFileReader = .init(type,counter: <#T##Int#>)
            DispatchQueue.main.async { [weak self] in
                if let self = self {
//                    if self.startButton.isSelected {
//                        self.startAction(self.startButton)
//                    }
                }
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
        
