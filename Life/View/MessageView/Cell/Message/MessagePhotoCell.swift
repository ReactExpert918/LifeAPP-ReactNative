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

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MessagePhotoCell: UITableViewCell {

	private var imageViewPhoto: UIImageView!
	private var imageViewManual: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!
    
    var indexPath: IndexPath!
    var messagesView: ChatViewController!

    var viewBubble: UIView!
    private var objectionableMark: UIImageView!
    private var imageAvatar: UIImageView!
    private var labelTimeText: UILabel!
    private var viewStatus: UIView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {
        
        self.indexPath = indexPath
        self.messagesView = messagesView
        let rcmessage = messagesView.rcmessageAt(indexPath)
        backgroundColor = UIColor.clear

        if (viewBubble == nil) {
            viewBubble = UIView()
            viewBubble.layer.cornerRadius = RCDefaults.bubbleRadius
            viewBubble.layer.shadowColor = UIColor.black.cgColor
            viewBubble.layer.shadowOffset = CGSize(width: 0, height: 1)
            viewBubble.layer.shadowOpacity = 0.5
            viewBubble.layer.shadowRadius = 4.0
            contentView.addSubview(viewBubble)
            bubbleGestureRecognizer()
        }
        
        viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.callBubbleColorIncoming : RCDefaults.callBubbleColorOutgoing

        if (imageAvatar == nil) {
            imageAvatar = UIImageView()
            imageAvatar.layer.masksToBounds = true
            imageAvatar.layer.cornerRadius = 23
            imageAvatar.backgroundColor = RCDefaults.avatarBackColor
            imageAvatar.isUserInteractionEnabled = true
            contentView.addSubview(imageAvatar)
            avatarGestureRecognizer()
        }
        
        imageAvatar.image = messagesView.avatarImage(indexPath)
        
        if (viewStatus == nil) {
            viewStatus = UIView()
            viewStatus.layer.cornerRadius = 6
            viewStatus.layer.borderWidth = 2
            viewStatus.layer.borderColor = UIColor.white.cgColor
            viewStatus.backgroundColor = UIColor(hexString: "#6cc93e")
            contentView.addSubview(viewStatus)
        }
        
        if (labelTimeText == nil) {
            labelTimeText = UILabel()
            labelTimeText.font = RCDefaults.headerLowerFont
            labelTimeText.textColor = RCDefaults.headerLowerColor
            contentView.addSubview(labelTimeText)
        }

        labelTimeText.textAlignment = rcmessage.incoming ? .left : .right
        labelTimeText.text = messagesView.textHeaderLower(indexPath)
        
		if (imageViewPhoto == nil) {
			imageViewPhoto = UIImageView()
            
            imageViewPhoto.layer.masksToBounds = true
            imageViewPhoto.layer.cornerRadius = RCDefaults.bubbleRadius
			
			viewBubble.addSubview(imageViewPhoto)
		}

		if (activityIndicator == nil) {
			activityIndicator = UIActivityIndicatorView(style: .large)
			viewBubble.addSubview(activityIndicator)
		}

		if (imageViewManual == nil) {
			imageViewManual = UIImageView(image: RCDefaults.photoImageManual)
			viewBubble.addSubview(imageViewManual)
		}

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_UNKNOWN) {
			imageViewPhoto.image = nil
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_LOADING) {
			imageViewPhoto.image = nil
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
			imageViewPhoto.image = rcmessage.photoImage
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_MANUAL) {
			imageViewPhoto.image = nil
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = false
		}
        
        //imageViewManual.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {
        
        super.layoutSubviews()

		let size = MessagePhotoCell.size(messagesView, at: indexPath)
        
        let rcmessage = messagesView.rcmessageAt(indexPath)
        let widthTable = messagesView.tableView.frame.size.width
        
        let diameter: CGFloat = 46
        
        let xBubble = rcmessage.incoming ? diameter + 20 : (widthTable - diameter - 20 - size.width)
        
        
        
        viewBubble.frame = CGRect(x: xBubble, y: 0, width: size.width, height:size.height)
        
        
        labelTimeText.sizeToFit()
        
        let xTime = rcmessage.incoming ? xBubble + size.width + 8 : xBubble - labelTimeText.frame.width - 8
        
        labelTimeText.frame.origin = CGPoint(x: xTime, y: size.height - labelTimeText.frame.height)
        
        
        
        let xAvatar = rcmessage.incoming ? RCDefaults.avatarMarginLeft : (widthTable - RCDefaults.avatarMarginRight - diameter)
        
        imageAvatar.frame = CGRect(x: xAvatar, y: 0, width: diameter, height: diameter)
        viewStatus.frame = CGRect(x: xAvatar + 33, y: 0, width: 12, height: 12)

		imageViewPhoto.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		let widthActivity = activityIndicator.frame.size.width
		let heightActivity = activityIndicator.frame.size.height
		let xActivity = (size.width - widthActivity) / 2
		let yActivity = (size.height - heightActivity) / 2
		activityIndicator.frame = CGRect(x: xActivity, y: yActivity, width: widthActivity, height: heightActivity)

		let widthManual = imageViewManual.image?.size.width ?? 0
		let heightManual = imageViewManual.image?.size.height ?? 0
		let xManual = (size.width - widthManual) / 2
		let yManual = (size.height - heightManual) / 2
		imageViewManual.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGFloat {

		let size = self.size(messagesView, at: indexPath)
		return size.height
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func size(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGSize {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		let photoWidth = CGFloat(rcmessage.photoWidth)
		let photoHeight = CGFloat(rcmessage.photoHeight)
        

		let width = CGFloat.minimum(RCDefaults.photoBubbleWidth, photoWidth)
        
		return CGSize(width: width, height: photoHeight * width / photoWidth)
	}
    
    // MARK: - Gesture recognizer methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func bubbleGestureRecognizer() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
        viewBubble.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
        viewBubble.addGestureRecognizer(longGesture)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func avatarGestureRecognizer() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
        imageAvatar.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }

    // MARK: - User actions
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionTapBubble() {

        messagesView.dismissKeyboard()
        messagesView.actionTapBubble(indexPath)
    }
    
    @objc func actionContentView() {

        messagesView.dismissKeyboard()
        //messagesView.actionTapBubble(indexPath)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionTapAvatar() {

        messagesView.dismissKeyboard()
        messagesView.actionTapAvatar(indexPath)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionLongBubble(_ gestureRecognizer: UILongPressGestureRecognizer) {

        switch gestureRecognizer.state {
            case .began:
                actionMenu()
                break
            case .changed:
                break
            case .ended:
                break
            case .possible:
                break
            case .cancelled:
                break
            case .failed:
                break
            default:
                break
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionMenu() {

        if (messagesView.messageInputBar.inputTextView.isFirstResponder == false) {
            let menuController = UIMenuController.shared
            menuController.menuItems = messagesView.menuItems(indexPath)
            menuController.showMenu(from: contentView, rect: viewBubble.frame)
        } else {
            messagesView.messageInputBar.inputTextView.resignFirstResponder()
        }
    }
}
