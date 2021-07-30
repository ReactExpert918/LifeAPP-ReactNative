//
//  Const.swift
//

import Foundation
import UIKit

class Const {
    
    static let shared = Const()
    
    let SCREEN_WIDTH  = UIScreen.main.bounds.width
    let SCREEN_HEIGHT = UIScreen.main.bounds.height
    
    let alertAppearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: MyFont.MontserratSemiBold, size: 20)!,
        kTextFont: UIFont(name: MyFont.MontserratMedium, size: 14)!,
        kButtonFont: UIFont(name: MyFont.MontserratSemiBold, size: 14)!,
        
        showCloseButton: false,
        buttonCornerRadius : 20
    )
}

class R {
    static let appName             = "Life"
    static let btnOk               = "OK"
    static let btnYes              = "Yes"
    static let btnNo               = "No"
    static let btnDelete           = "Delete"
    static let btnCancel           = "Cancel"
    static let btnSave             = "Save"
    static let btnContinue         = "Continue"
    static let btnFollow           = "Follow"
    static let btnUnfollow         = "Unfollow"
    static let btnSend             = "Send"
    static let btnAccept           = "Accept"
    static let btnDecline          = "Decline"
    
    static let msgRegister              = "Please register or login to get the data"
    static let msgEnterEmail            = "Please enter your Email address"
    static let msgInvalidEmail          = "Email format is invalid. Please check it again"
    static let msgInvalidPhone          = "Phone number is invalid. Please check it again"
    static let msgEmailNoExist          = "Email doesn't exist"
    static let msgEnterPassword         = "Please enter your Password"
    static let msgConfirmPassword       = "Please confirm password"
    static let msgInvalidPassword       = "Password should be more than 8 characters including special characters"
    static let msgPwdDontMatch          = "Passwords don't match"
    static let msgEnterFirstName        = "Please enter First Name"
    static let msgEnterLastName         = "Please enter Last Name"
    static let msgEnterUsername         = "Please enter Username"
    static let msgEnterPhone            = "Please enter Phone Number"
    static let msgEnterCode             = "Please enter verification code"
    static let msgSendCode              = "A Verification code will be sent to this number via text messages."
    static let msgTakePhoto             = "Please take profile photo."
    static let msgEnterPublicName       = "Please enter public name."
    
    static let qstCancelLove            = "Do you want to remove this loved item?"
    
    static let altIapRestored           = "Successfully restored Premium membership"
    static let altIapFailed             = "Sorry. Failed to purchase Premium membership. Try it later."
    static let altResetSent             = "Password reset email sent."
    
    static let errFailedSignin          = "Incorrect email or password,\nPlease try again!"
    static let errNetwork               = "Network connection error,\nPlease try again!"
    static let errInvalidCode           = "Incorrect verification code, please try again."
    static let errFailedUploadPhoto     = "Picture upload error."
    static let errFailedReset           = "Password reset email sent has failed."
    
    static let titleError       = "Error!"
    static let titleWarning     = "Warning"
    static let titleNotice      = "Notice"
    static let titleSuccess     = "Success!"
    
}
