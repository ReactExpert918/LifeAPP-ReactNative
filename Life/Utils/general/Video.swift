//
// Copyright (c) 2020 Related Code 
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import AVFoundation

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Video: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func thumbnail(path: String) -> UIImage {

		let asset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
		let generator = AVAssetImageGenerator(asset: asset)
		generator.appliesPreferredTrackTransform = true

        let timestamp = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)

		if let cgImage = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
			return UIImage(cgImage: cgImage)
		}

		return UIImage()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func duration(path: String) -> Int {

		let asset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
		return Int(round(CMTimeGetSeconds(asset.duration)))
	}
}
