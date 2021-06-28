//
//  HomeViewController.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD
protocol CreateGroupDelegate {
    func onGroupCreated(group: Group)
}

protocol ChatViewControllerProtocol {
    func singleChatView(_ indexPath: IndexPath)
    func groupChatView(_ indexPath: IndexPath)
    func removeFriend(_ indexPath: IndexPath)
    func groupInfo(_ group: Group)
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CreateGroupDelegate, ChatViewControllerProtocol {

    private var person: Person!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var redCircle: UIImageView!
    
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var imageReceivedUnRead: UIImageView!
    @IBOutlet weak var addFriendView: UIView!
    @IBOutlet weak var agreeView: UIView!
    
    let hud = JGProgressHUD(style: .light)
    var headerSections =  [HeaderSection(name: "My Status", collapsed: false), HeaderSection(name: "Groups".localized+" 0", collapsed: false), HeaderSection(name: "Friends".localized+" 0", collapsed: false)]

    private var tokenFriends: NotificationToken? = nil
    private var tokenPersons: NotificationToken? = nil
    private var tokenGroups: NotificationToken? = nil
    private var tokenMembers: NotificationToken? = nil
    private var friends = realm.objects(Friend.self).filter(falsepredicate)
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    private var groups = realm.objects(Group.self).filter(falsepredicate)
    private var members = realm.objects(Group.self).filter(falsepredicate)
    @IBOutlet weak var textEULA: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#16406F")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "Search".localized
//        searchBar.backgroundColor = UIColor(hexString: "165c90")
        searchBar.set(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#96B4D2")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        searchBar.tintColor = UIColor(hexString: "#FFFFFF")
        searchBar.delegate = self        
        // Init TableView
        ExpandableHeaderCell.RegisterAsAHeader(withTableView: self.homeTableView)
        UserStatusCell.Register(withTableView: self.homeTableView)
        FriendCell.Register(withTableView: self.homeTableView)
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        if(PrefsManager.getReadEULA() == false){
            agreeView.isHidden = false
            addFriendView.isHidden = true
            let preferredLanguage = Bundle.main.preferredLocalizations.first!
            print(preferredLanguage)
            if(preferredLanguage == "ja"){
                textEULA.text = "モバイルアプリケーションをダウンロード、インストール、または使用する前に、これらの条件をよくお読みください。このアプリをダウンロード、インス トール、または使用することにより、または以下の「同意する」をクリックすること により、お客様は本契約を読み、理解し、その条件に拘束されることに同意したこと になります。本規約に同意しない場合は、このアプリのダウンロード、使用、サービ スの使用、または「同意する」をクリックしないでください。\n";
                textEULA.text += "\t1. 本エンドユーザー使用許諾契約書（以下「本EULA」）は、個人または事業体としての お客様（以下「お客様」）とMirai group Japan（以下「当社」）との間で締結さ れ、当社がダウンロードを可能にしているLIFEモバイルアプリケーションを含むが これに限られない、すべてのモバイルソフトウェアアプリケーション( (以下「本アプ リ」) に関連するおよび/または当社に代わって所有または管理さ れているその他のウェブサイト（総称して以下「本ウェブサイト」、本アプリと総称 して以下「本サービス」)のユーザーの使用を規定するものです。\n";
                textEULA.text += "\t2. お客様は、本EULAに定められた個人的（非商業的）な目的のために 本サービスを使用する非独占的かつ限定的な権利を有することを認めます。お 客様は、適用法によって明示的に許可されている場合を除き、リバースエンジ ニアリング、逆コンパイル、逆アセンブルまたは本サービスのソースコードへ のアクセスを試みることはできず、適用法で許可されている範囲で、契約上の 権利放棄が認められている場合、お客様はここにその権利を放棄するものとします。\n";
                textEULA.text += "\t3. お客様が本EULAに基づく重大な義務に違反した場合、本契約に基づくお客様の権 利は自動的に終了します。本EULAが終了した場合、お客様は本サービスのすべ てのコピーを速やかに破棄し、終了後は本サービスのすべての使用を停止するものとします。\n";
                textEULA.text += "\t4. 禁止事項。 ユーザーは、当社が単独で判断した「禁止コンテンツ」に該当すると判断したユーザーコンテンツを本サービスに投稿することはできません。禁止コンテンツには以下のものが含まれますが、これらに限定されません。\n";
                textEULA.text += "\t5. 性的に露骨な内容（例：アイコン、タイトル、音声、音声、写真、説明を含むポルノまたはアダルトコンテンツ）。 児童の性的虐待の画像は一切容認しない方針です。 児童の性的虐待の画像を含むユーザーコンテンツを発見した場合、直ちに当局に報告し、投稿されたユーザーアカウントを削除し、最大限の法的措置を講じます。\n";
                textEULA.text += "\t6. 暴力といじめ（例として、ユーザーコンテンツには、他のユーザーや第三者を脅迫、嫌がらせ、いじめるような内容のもの、暴力描写、人、場所や財産、その他の暴力描写、自殺を含む暴力行為を扇動するもの等）。\n";
            }else{
                textEULA.text = "Please read these terms carefully before downloading, installing, or using the mobile application. By downloading, installing, or using this app, or by clicking \"Agree\" below, you agree that you have read, understood, and are bound by the terms of this Agreement. I will. If you do not agree to these Terms, please do not download, use, use the service, or click I Agree.\n";
                textEULA.text += "\t1. This End User License Agreement (\"EULA\") is entered into between you as an individual or business entity (\"Customer\") and Mirai group Japan (\"Company\"). Related to, but not limited to, all mobile software applications (the \"Appli\") and / or owned or controlled on our behalf, including, but not limited to, the LIFE mobile application that allows download. It regulates the use of users of other websites (collectively, \"this website\", collectively, \"this service\").\n";
                textEULA.text += "\t2. You acknowledge that you have a non-exclusive and limited right to use the Services for personal (non-commercial) purposes set forth in this EULA. You may not attempt reverse engineering, decompiling, disassembling or accessing the source code of the Services except as expressly permitted by applicable law and is permitted by applicable law. To the extent that the contractual waiver is permitted, you hereby waive that right.\n";
                textEULA.text += "\t3. If you violate any material obligations under this EULA, your rights under this Agreement will automatically terminate. Upon termination of this EULA, you shall promptly destroy all her copies of the Services and suspend all use of the Services after termination.\n";
                textEULA.text += "\t4. Users may not post user content that we have determined to fall under \"prohibited content\" independently to this service. Banned content includes, but is limited to.\n";
                textEULA.text += "\t5. Sexually explicit content (eg pornographic or adult content including icons, titles, audio, audio, photos, descriptions). It is our policy not to tolerate any images of child sexual abuse. If we discover user content that contains images of child sexual abuse, we will immediately report it to the authorities, delete the posted user account and take maximum legal action.\n";
                textEULA.text += "\t6. Violence and bullying (for example, user content includes content that threatens, harasses, or bullies other users or third parties, depictions of violence, people, places or property, other depictions of violence, or acts of violence, including suicide. Those that incite).\n";
                
            }
            
        }else{
            agreeView.isHidden = true
            if(PrefsManager.getEULAAgree() == false){
                addFriendView.isHidden = true
            }else{
                addFriendView.isHidden = false
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        balanceView.isHidden = true
        if(Friends.friendPendingIds().count > 0){
            redCircle.isHidden = false
        }else{
            redCircle.isHidden = true
        }
        
        
        if (AuthUser.userId() != "") {
            loadPerson()
            //let _: [String] = Members.chatIds()
            loadMembers()
            //let _ = Friends.friendAcceptedIds()
            loadFriends()
        }
    }
    
    
    // MARK: - Realm methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func loadFriends() {

        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO  AND isAccepted == YES", AuthUser.userId())
        //// print("Auth UserId: \(predicate)")
        friends = realm.objects(Friend.self).filter(predicate)

        tokenFriends?.invalidate()
        friends.safeObserve({ changes in
            // load friend list
            self.loadPersons()
            //self.refreshTableView()
            
        }, completion: { token in
            self.tokenFriends = token
        })
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadPersons(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendAcceptedIds(), Blockeds.blockerIds())
        let predicate2 = (text != "") ? NSPredicate(format: "fullname CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")

        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenPersons = token
        })
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadGroups(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND isDeleted == NO", Members.chatIds())
        let predicate2 = (text != "") ? NSPredicate(format: "name CONTAINS[c] %@", text) : NSPredicate(value: true)

        groups = realm.objects(Group.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "name")

        tokenGroups?.invalidate()
        groups.safeObserve({ changes in
            
            self.refreshTableView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.hud.dismiss()
            }
            
        }, completion: { token in
            self.tokenGroups = token
        })
    }
    
    func loadMembers(text: String = "") {

        let predicate = NSPredicate(format: "userId == %@ AND isActive == YES", AuthUser.userId())
        let members = realm.objects(Member.self).filter(predicate)

        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadGroups()
        }, completion: { token in
            self.tokenMembers = token
        })
    }
    
    func onGroupCreated(group: Group) {
        Util.showAlert(vc: self, "\(group.name) " + "has been created successfully.".localized, "")
    }

    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func refreshTableView() {
        print("refreshTableView")
        headerSections[1].name = "Groups".localized+" \(groups.count)"
        headerSections[2].name = "Friends".localized+" \(persons.count)"
        homeTableView.reloadData()
    }
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        if(person.isBalanceRead == false){
            imageReceivedUnRead.isHidden = false
        }else{
            imageReceivedUnRead.isHidden = true
        }
        
        
    }
    @IBAction func onSettingPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Setting", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "settingNav") as! UINavigationController
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onAddFriendPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Friend", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "addFriendRootVC")
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func openPrivateChat(chatId: String, recipientId: String) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "chatViewController") as! ChatViewController
        vc.setParticipant(chatId: chatId, recipientId: recipientId)
        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSections.count
    }
    
    func createGroupView(){
        let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "createGroupVC") as! CreateGroupViewController
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func singleChatView(_ indexPath: IndexPath){
        let friend = persons[indexPath.row]
        let chatId = Singles.create(friend.objectId)
        openPrivateChat(chatId: chatId, recipientId: friend.objectId)
        
    }
    
    func groupChatView(_ indexPath: IndexPath){
        
        let chatId = groups[indexPath.row-1].chatId
        openPrivateChat(chatId: chatId, recipientId: "")
        
    }
    
    func removeFriend(_ indexPath: IndexPath) {
        let friend = persons[indexPath.row]
        let confirmationAlert = UIAlertController(title: "Remove Friend".localized, message: "Are you sure remove ".localized + friend.fullname, preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: {
                (action: UIAlertAction!) in
                confirmationAlert.dismiss(animated: true, completion: nil)
                Friends.removeFriend(friend.objectId){
                    self.loadFriends() 
                }
            
            })
        )
        
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
       
    }
    func groupInfo(_ group: Group){
        let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "configGroupVC") as! ConfigGroupViewController
        vc.group = group
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
                let vc = mainstoryboard.instantiateViewController(withIdentifier: "createGroupVC") as! CreateGroupViewController
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }/*else{
                let chatId = groups[indexPath.row-1].chatId
                openPrivateChat(chatId: chatId, recipientId: "")
            }*/
        }/*
        else if indexPath.section == 2 {
            let friend = persons[indexPath.row]
            let chatId = Singles.create(friend.objectId)
            openPrivateChat(chatId: chatId, recipientId: friend.objectId)
        }*/
    }*/
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandableHeaderCell.GetReuseIdentifier()) as! ExpandableHeaderCell
        header.titleLabel.text = headerSections[section].name
        header.setCollapsed(collapsed: headerSections[section].collapsed)
        header.section = section
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 40.00
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return headerSections[section].collapsed ? 0 : groups.count + 1
        }
        else if section == 2{
            return headerSections[section].collapsed ? 0 : persons.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userStatusCell", for: indexPath) as! UserStatusCell
            if person != nil{
                cell.loadPerson(withPerson: person)
            }
            return cell

        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupCell", for: indexPath) as! CreateGroupTableViewCell
                cell.homeViewController = self
                return cell
            }
            else {
                // Group Lists
                let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.GetCellReuseIdentifier(), for: indexPath) as! FriendCell
                cell.selectionStyle = .none
                let group = groups[indexPath.row-1]
                cell.homeViewController = self
                cell.bindGroupData(group: group, indexPath: indexPath)
                cell.loadGroupImage(group: group, tableView: tableView, indexPath: indexPath)
                return cell
            }
        }
 
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.GetCellReuseIdentifier(), for: indexPath) as! FriendCell
        cell.selectionStyle = .none
        if( indexPath.section == 2) {
            let person = persons[indexPath.row]
            cell.homeViewController = self
            cell.bindData(person: person, indexPath: indexPath)
            cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    // MARK: - ZedPayView
    
    @IBOutlet weak var labelBalance: UILabel!
    @IBAction func onZedPay(_ sender: Any) {
        labelBalance.text = "¥ " + String(format: "%.2f", person.getBalance())
        balanceView.isHidden = false
    }
    
    // MARK: - BalanceView close
    @IBAction func actionTapBalanceClose(_ sender: Any) {
        balanceView.isHidden = true
    }
    // MARK: - History Tap
    @IBAction func actionTapHistory(_ sender: Any) {
        /// Just for test
        ///person.update(balance: 500.23)
        
        let mainstoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "zedHistoryVC") as! ZedHistoryViewController
        vc.person = self.person
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - scan qr code
    
    @IBAction func actionTapScan(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "payQrcodeVC") as! PayQRCodeViewController
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Add Money
    @IBAction func actionTapAddMoney(_ sender: Any) {
        print("Add Money")
    }
    
    // MARK: - EULA
    @IBAction func actionTapAgree(_ sender: Any) {
        PrefsManager.setReadEULA(val: true)
        PrefsManager.setEULAAgree(val: true)
        agreeView.isHidden = true
        addFriendView.isHidden = false
        self.refreshTableView()
    }
    @IBAction func actionTapNoAgree(_ sender: Any) {
        PrefsManager.setReadEULA(val: true)
        PrefsManager.setEULAAgree(val: false)
        agreeView.isHidden = true
        addFriendView.isHidden = true
        self.refreshTableView()
    }
    
}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension HomeViewController: UISearchBarDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(true, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(false, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadGroups()
        loadPersons()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        
        loadGroups(text: searchText ?? "")
        loadPersons(text: searchText ?? "")
    }
}

extension HomeViewController: CollapsibleTableViewHeaderDelegate {
  func toggleSection(_ header: ExpandableHeaderCell, section: Int) {
    let collapsed = !headerSections[section].collapsed
        
    // Toggle collapse
    headerSections[section].collapsed = collapsed
    header.setCollapsed(collapsed: collapsed)
    
    // Reload the whole section
    homeTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
  }
}

struct HeaderSection {
  var name: String
  var collapsed: Bool
    
  init(name: String, collapsed: Bool = false) {
    self.name = name
    self.collapsed = collapsed
  }
}
    


