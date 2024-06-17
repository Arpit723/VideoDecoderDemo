import Foundation
import VideoDecoder

class VideoFileReader {
    
    static var fps: Int = 20
    
    var type: EncodeType
    
    var streamBuffer: [UInt8] = []
    var fileStream: InputStream?
    private var fps: Int {
        return VideoFileReader.fps
    }
    
    init(_ type: EncodeType,counter :Int) {
        self.type = type
        let forResource = String(format: "frames-%04d", counter)
        print("Reading new file \(forResource)")
        guard let path = Bundle.main.path(forResource: forResource, ofType: "h265") else {
            return
        }
        fileStream = InputStream.init(fileAtPath: path)
        fileStream?.open()
    }
    
    func nextVideoPacket() -> VideoPacket? {
        
        guard streamBuffer.count != 0 || readStremData() != 0 else {
            print("streamBuffer count is 0, \nreadStream data is zero")
            print("Returning")
            return nil
        }
        
        guard streamBuffer.count > 4 && [UInt8](streamBuffer[0...3]) == [0,0,0,1] else {
            print("streamBuffer count is less than 4, \nstram buffer does not contain 0,0,0,1 header")
            print("Returning")
            return nil
        }
        
        var startIndex = 4

        
            while ((startIndex + 3) < streamBuffer.count) {
//                print("1st while lopp")
//                print("startIndex \(startIndex) , Stream buffer count \(streamBuffer.count)")
                if [UInt8](streamBuffer[startIndex...startIndex+3]) == [0,0,0,1] {
                    let data = [UInt8](streamBuffer[0..<startIndex])
                    streamBuffer.removeSubrange(0..<startIndex)
                    return VideoPacket.init(data, fps: fps, type: type, videoSize: CGSize(width: 1920, height: 1080))
                }
                startIndex += 1
            }
            if startIndex > 4 {
//                print("start index is greater than 4, \n then read and return video packet")
                let data = [UInt8](streamBuffer[0...startIndex])
                streamBuffer.removeSubrange(0...startIndex)
                return VideoPacket.init(data, fps: fps, type: type, videoSize: CGSize(width: 1920, height: 1080))
            }
            print("return nil")
            return nil
            
        }
//        @Arpit723



        
//        while true {
//            while ((startIndex + 3) < streamBuffer.count) {
//                if [UInt8](streamBuffer[startIndex...startIndex+3]) == [0,0,0,1] {
//                    let data = [UInt8](streamBuffer[0..<startIndex])
//                    streamBuffer.removeSubrange(0..<startIndex)
//                    return VideoPacket.init(data, fps: fps, type: type, videoSize: CGSize(width: 1920, height: 1080))
//                }
//                startIndex += 1
//            }
//            if readStremData() == 0 {
//                return nil
//            }
//        }
//    }
    
    func readStremData() -> Int {
        if let stream = fileStream, stream.hasBytesAvailable {
            var tempArray = [UInt8](repeating: 0, count: 512 * 1024)
            let bytes = stream.read(&tempArray, maxLength: 512 * 1024)
            if bytes > 0 {
                streamBuffer.append(contentsOf: Array(tempArray[0..<bytes]))
            }
            return bytes
        }
        return 0
    }
    
}
