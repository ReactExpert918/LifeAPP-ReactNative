//
//  LoginViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var agreeView: UIView!
    @IBOutlet weak var privacyText: UITextView!
    
    @IBOutlet weak var textEULA: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(PrefsManager.getReadEULA() == false || PrefsManager.getEULAAgree() == false){
            agreeView.isHidden = false
            
            let preferredLanguage = Bundle.main.preferredLocalizations.first!
            print(preferredLanguage)
            if(preferredLanguage == "ja"){
                let baseString1 = "個人情報保護方針"
                let baseString = "エンドユーザーライセンス契約 & "
                let baseString2 = "エンドユーザーライセンス契約"
                let attributed = NSMutableAttributedString(string: baseString+baseString1)
                
                
                attributed.addAttribute(.font, value: RCDefaults.privacyFont, range:NSRange(location: 0, length: baseString2.count))
                
                attributed.addAttribute(.link, value: "https://en.zedinternational.net/life-eula-policies", range:NSRange(location: 0, length: baseString2.count))
                
                attributed.addAttribute(.font, value: RCDefaults.privacyFont, range:NSRange(location: baseString.count, length: baseString1.count))
                
                attributed.addAttribute(.link, value: "https://en.zedinternational.net/life-privacy-policy", range:NSRange(location: baseString.count, length: baseString1.count))
                privacyText.attributedText = attributed
                
                
                textEULA.text = "モバイルアプリケーションをダウンロード、インストール、または使用する前に、これらの条件をよくお読みください。このアプリをダウンロード、インス トール、または使用することにより、または以下の「同意する」をクリックすること により、お客様は本契約を読み、理解し、その条件に拘束されることに同意したこと になります。本規約に同意しない場合は、このアプリのダウンロード、使用、サービ スの使用、または「同意する」をクリックしないでください。\n";
                textEULA.text += "\t1. 本エンドユーザー使用許諾契約書（以下「本EULA」）は、個人または事業体としての お客様（以下「お客様」）とZED EI Japan（以下「当社」）との間で締結さ れ、当社がダウンロードを可能にしているLIFEモバイルアプリケーションを含むが これに限られない、すべてのモバイルソフトウェアアプリケーション( (以下「本アプ リ」) に関連するおよび/または当社に代わって所有または管理さ れているその他のウェブサイト（総称して以下「本ウェブサイト」、本アプリと総称 して以下「本サービス」)のユーザーの使用を規定するものです。\n";
                textEULA.text += "\t2. お客様は、本EULAに定められた個人的（非商業的）な目的のために 本サービスを使用する非独占的かつ限定的な権利を有することを認めます。お 客様は、適用法によって明示的に許可されている場合を除き、リバースエンジ ニアリング、逆コンパイル、逆アセンブルまたは本サービスのソースコードへ のアクセスを試みることはできず、適用法で許可されている範囲で、契約上の 権利放棄が認められている場合、お客様はここにその権利を放棄するものとします。\n";
                textEULA.text += "\t3. お客様が本EULAに基づく重大な義務に違反した場合、本契約に基づくお客様の権 利は自動的に終了します。本EULAが終了した場合、お客様は本サービスのすべ てのコピーを速やかに破棄し、終了後は本サービスのすべての使用を停止するものとします。\n";
                textEULA.text += "\t4. 禁止事項。 ユーザーは、当社が単独で判断した「禁止コンテンツ」に該当すると判断したユーザーコンテンツを本サービスに投稿することはできません。禁止コンテンツには以下のものが含まれますが、これらに限定されません。\n";
                textEULA.text += "\t5. 性的に露骨な内容（例：アイコン、タイトル、音声、音声、写真、説明を含むポルノまたはアダルトコンテンツ）。 児童の性的虐待の画像は一切容認しない方針です。 児童の性的虐待の画像を含むユーザーコンテンツを発見した場合、直ちに当局に報告し、投稿されたユーザーアカウントを削除し、最大限の法的措置を講じます。\n";
                textEULA.text += "\t6. 暴力といじめ（例として、ユーザーコンテンツには、他のユーザーや第三者を脅迫、嫌がらせ、いじめるような内容のもの、暴力描写、人、場所や財産、その他の暴力描写、自殺を含む暴力行為を扇動するもの等）。\n";
            }else{
                
                let baseString1 = "Privacy Policy"
                let baseString = "End-user license agreement & "
                let baseString2 = "End-user license agreement"
                let attributed = NSMutableAttributedString(string: baseString+baseString1)
                attributed.addAttribute(.font, value: RCDefaults.privacyFont, range:NSRange(location: 0, length: baseString2.count))
                
                attributed.addAttribute(.link, value: "https://en.zedinternational.net/life-eula-policies", range:NSRange(location: 0, length: baseString2.count))
                
                attributed.addAttribute(.font, value: RCDefaults.privacyFont, range:NSRange(location: baseString.count, length: baseString1.count))
                
                attributed.addAttribute(.link, value: "https://en.zedinternational.net/life-privacy-policy", range:NSRange(location: baseString.count, length: baseString1.count))
                privacyText.attributedText = attributed
                
                textEULA.text = "Please read these terms carefully before downloading, installing, or using the mobile application. By downloading, installing, or using this app, or by clicking \"Agree\" below, you agree that you have read, understood, and are bound by the terms of this Agreement. I will. If you do not agree to these Terms, please do not download, use, use the service, or click I Agree.\n";
                textEULA.text += "\t1. This End User License Agreement (\"EULA\") is entered into between you as an individual or business entity (\"Customer\") and ZED EI Japan (\"Company\"). Related to, but not limited to, all mobile software applications (the \"Application\") and / or owned or controlled on our behalf, including, but not limited to, the LIFE mobile application that allows download. It regulates the use of users of other websites (collectively, \"this website\", collectively, \"this service\").\n";
                textEULA.text += "\t2. You acknowledge that you have a non-exclusive and limited right to use the Services for personal (non-commercial) purposes set forth in this EULA. You may not attempt reverse engineering, decompiling, disassembling or accessing the source code of the Services except as expressly permitted by applicable law and is permitted by applicable law. To the extent that the contractual waiver is permitted, you hereby waive that right.\n";
                textEULA.text += "\t3. If you violate any material obligations under this EULA, your rights under this Agreement will automatically terminate. Upon termination of this EULA, you shall promptly destroy all her copies of the Services and suspend all use of the Services after termination.\n";
                textEULA.text += "\t4. Users may not post user content that we have determined to fall under \"prohibited content\" independently to this service. Banned content includes, but is limited to.\n";
                textEULA.text += "\t5. Sexually explicit content (eg pornographic or adult content including icons, titles, audio, audio, photos, descriptions). It is our policy not to tolerate any images of child sexual abuse. If we discover user content that contains images of child sexual abuse, we will immediately report it to the authorities, delete the posted user account and take maximum legal action.\n";
                textEULA.text += "\t6. Violence and bullying (for example, user content includes content that threatens, harasses, or bullies other users or third parties, depictions of violence, people, places or property, other depictions of violence, or acts of violence, including suicide. Those that incite).\n";
                
            }
            privacyText.delegate = self
        }else{
            agreeView.isHidden = true
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        //gotoMainViewController()
        let vc =  self.storyboard?.instantiateViewController(identifier: "signinVC") as! SignInViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onSignupPressed(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "signupViewController") as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc =  self.storyboard?.instantiateViewController(identifier: "basicDetailInsertVC") as! BasicDetailInsertViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoMainViewController() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIApplication.shared.windows.first?.rootViewController = vc
    }
    
    // MARK: - EULA
    @IBAction func actionTapAgree(_ sender: Any) {
        PrefsManager.setReadEULA(val: true)
        PrefsManager.setEULAAgree(val: true)
        agreeView.isHidden = true
        
    }
    @IBAction func actionTapNoAgree(_ sender: Any) {
        PrefsManager.setReadEULA(val: true)
        PrefsManager.setEULAAgree(val: false)
        agreeView.isHidden = true
        exit(0)
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
