//
//  MyQrGenerateViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/2.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class MyQrGenerateViewController: UIViewController {
    
    private var person: Person!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = generateQRCode(from: AuthUser.userId())
        myQrcode.image = image
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if (AuthUser.userId() != "") {
            loadPerson()
        }
    }
    
    @IBOutlet weak var myQrcode: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBAction func onCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func generateQRCode(from string: String) -> UIImage? {
        let timestamp = String(NSDate().timeIntervalSince1970)
        let original = string + "timestamp" + timestamp
        let data = original.data(using: String.Encoding.ascii)
        

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        if let person = person{
            name.text = person.fullname
            phoneNumber.text = person.phone
        }
    }
    @IBAction func onRefreshTapped(_ sender: Any) {
        myQrcode.image = generateQRCode(from: AuthUser.userId())
    }
    @IBAction func onShareTapped(_ sender: Any) {
    }
    @IBAction func onDownloadTapped(_ sender: Any) {
    }
    
}
