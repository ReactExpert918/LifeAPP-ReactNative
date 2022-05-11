//
//  AddCardViewController.swift
//  Life
//
//  Created by Yansong Wang on 2022/5/11.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import FormTextField
import CreditCardValidator
import JGProgressHUD
import RealmSwift
import CoreLocation

class AddCardViewController: UIViewController {
    @IBOutlet weak var btnAddCard: RoundButton!
    
    @IBOutlet weak var cardNo: FormTextField!
    @IBOutlet weak var cardExp: FormTextField!

    @IBOutlet weak var cardCVC: FormTextField!
    
    @IBOutlet weak var labelCountry: UILabel!
    
    
    @IBOutlet weak var addCardForm: UIView!
    
    private var tokenPaymentmethod: NotificationToken? = nil
    
    private var paymentMethods = realm.objects(PaymentMethod.self).filter(falsepredicate)
    let hud = JGProgressHUD(style: .light)
    var delegate: UpdatePayDelegateProtocol?
    private let locationManager = CLLocationManager()
    
    let alertController = UIAlertController(title: "Select Country", message: "", preferredStyle: .actionSheet)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNo.formatter = CardNumberFormatter()
        cardExp.formatter = CardExpirationDateFormatter()
        cardExp.inputValidator = CardExpirationDateInputValidator()

        var validation = Validation()
        validation.minimumLength = 19
        validation.maximumLength = 19
        cardNo.inputValidator = InputValidator(validation: validation)

        var validation1 = Validation()
        validation1.minimumLength = 3
        validation1.maximumLength = 4
        cardCVC.inputValidator = InputValidator(validation: validation1)

        cardExp.textFieldDelegate = self
        cardNo.textFieldDelegate = self
        cardCVC.textFieldDelegate = self
        btnAddCard.isHidden = true
        
        self.setCountry()
        self.prepareCountry()
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionAdd(_ sender: Any) {
        self.hud.show(in: self.view, animated: true)
        let predicate = NSPredicate(format: "userId == %@ AND status == %@", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        if let customer = realm.objects(StripeCustomer.self).filter(predicate).first {
            let cardNumber = cardNo.text?.replacingOccurrences(of: " ", with: "")
            let cvc = cardCVC.text!
            let cardExpDates = cardExp.text?.components(separatedBy: "/")
            let cardExpMonth = cardExpDates?[0]
            let cardExpYear = cardExpDates?[1]
            self.hud.show(in: self.view, animated: true)
            PaymentMethods.create(userId: AuthUser.userId(), customerId: customer.customerId, cardNumber: cardNumber!, expMonth: cardExpMonth!, expYear:cardExpYear!, cvc: cvc, country: self.labelCountry.text!)
            let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO", AuthUser.userId())
            paymentMethods = realm.objects(PaymentMethod.self).filter(predicate)

            tokenPaymentmethod?.invalidate()
            paymentMethods.safeObserve({ changes in
                self.addPaymentMethod()
            }, completion: { token in
                self.tokenPaymentmethod = token
            })


        }else{
            self.hud.dismiss()
            self.dismiss(animated: true){
                self.delegate?.updateCard(result: false)
            }
        }
    }
    
    @IBAction func actionCountry(_ sender: Any) {
        self.present(alertController, animated: true)
    }
    
    func prepareCountry() {
        var countries: [String] = []

        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
        
        for country in countries {
            alertController.addAction(UIAlertAction(title: country, style: .default, handler: { _ in
                self.labelCountry.text = country
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func addPaymentMethod(){
        guard let paymentMethod = paymentMethods.first else{
            self.hud.dismiss()
            return
        }

        if paymentMethod.status == ZEDPAY_STATUS.PENDING {
            self.hud.dismiss()
            return
        }

        self.hud.dismiss()
        self.dismiss(animated: true){
            self.delegate?.updateCard(result: true)
        }

        if paymentMethod.status == ZEDPAY_STATUS.FAILED {
            self.hud.dismiss()
            self.dismiss(animated: true){
                self.delegate?.updateCard(result: false)
            }
        }
        if paymentMethod.status == ZEDPAY_STATUS.SUCCESS {
            self.hud.dismiss()
            self.dismiss(animated: true){
                self.delegate?.updateCard(result: true)
            }

        }
    }
    
    func setCountry() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.setCountryWithLocale()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.delegate = self
                self.locationManager.startMonitoringSignificantLocationChanges()
                break
            @unknown default:
                self.setCountryWithLocale()
                break
            }
        } else {
            self.setCountryWithLocale()
        }
    }
    
    func setCountryWithLocale() {
        if let regionCode = Locale.current.regionCode, let country = self.countryName(countryCode: regionCode) {
            self.labelCountry.text = country
        } else {
            self.labelCountry.text = "Japan"
        }
    }
    
    func countryName(countryCode: String) -> String? {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: countryCode)
    }
}

extension AddCardViewController: FormTextFieldDelegate {
    func formTextField(_ textField: FormTextField, didUpdateWithText text: String?){

        let number = cardNo.text!
        if CreditCardValidator(number).isValid {
            if CreditCardValidator(number).isValid(for: .visa) {
            } else if CreditCardValidator(number).isValid(for: .amex){
            } else if CreditCardValidator(number).isValid(for: .masterCard){
            } else if CreditCardValidator(number).isValid(for: .maestro){
            } else if CreditCardValidator(number).isValid(for: .dinersClub){
            } else if CreditCardValidator(number).isValid(for: .discover){
            } else if CreditCardValidator(number).isValid(for: .unionPay){
            } else if CreditCardValidator(number).isValid(for: .mir){
            } else if CreditCardValidator(number).isValid(for: .jcb){
            } else{
                btnAddCard.isHidden = true
                return
            }

            if( cardExp.validate() && cardCVC.validate()){
                btnAddCard.isHidden = false
            }else{
                btnAddCard.isHidden = true
            }
        } else {
            btnAddCard.isHidden = true

        }


    }
}

extension AddCardViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else {
            self.setCountryWithLocale()
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { placeMarks, error in
            guard let currentPlacemark = placeMarks?.first else {
                self.setCountryWithLocale()
                return
            }
            
            if let regionCode = currentPlacemark.isoCountryCode, let country = self.countryName(countryCode: regionCode) {
                self.labelCountry.text = country
            } else {
                self.labelCountry.text = "Japan"
            }
        }
    }
}
