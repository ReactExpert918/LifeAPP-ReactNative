//
//  LifeAppMessageInput.swift
//  Life
//
//  Created by mac on 2021/6/16.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class SampleData {
    
    class Conversation {
        
        let title: String
        
        var messages: [Message]
        
        var users: [User]
        
        var lastMessage: Message? { return messages.last }
        
        init(users: [User], messages: [Message]) {
            self.users = users
            self.messages = messages
            self.title = Lorem.words(nbWords: 4).capitalized
        }
    }
    
    class Message {
        
        let text: String
        let user: User
        
        init(user: User, text: String) {
            self.user = user
            self.text = text
        }
    }
    
    class User {
        
        let id: String = UUID().uuidString
        //let image: UIImage
        let name: String
        /*
        init(name: String, image: UIImage) {
            self.image = image
            self.name = name
        }*/
        init(name: String) {
            //self.image = image
            self.name = name
        }
    }
    
    static var shared = SampleData()
    
    let users = [User(name: "Avatar"), User(name: "Ninja"), User(name: "Anonymous"), User(name: "Rick Sanchez"), User(name: "Nathan Tannar")]
    
    var currentUser: User { return users.last! }
    
    private init() {}
    
    func getConversations(count: Int) -> [Conversation] {
        
        var conversations = [Conversation]()
        for _ in 0..<count {
            
            var messages = [Message]()
            for i in 0..<30 {
                let user = users[i % users.count]
                if i % 2 == 0 {
                    let message = Message(user: user, text: Lorem.sentence())
                    messages.append(message)
                } else {
                    let message = Message(user: user, text: Lorem.paragraph())
                    messages.append(message)
                }
            }
            let newConversation = Conversation(users: users, messages: messages)
            conversations.append(newConversation)
        }
        return conversations
    }
}


final class LifeAppMessageInput: InputBarViewController {

    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.inputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        manager.maxSpaceCountDuringCompletion = 1
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        inputBar.inputTextView.autocorrectionType = .no
        inputBar.inputTextView.autocapitalizationType = .none
        inputBar.inputTextView.keyboardType = .twitter
        let size = UIFont.preferredFont(forTextStyle: .body).pointSize
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body),.foregroundColor: UIColor.systemBlue,.backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1)])
        autocompleteManager.register(prefix: "#", with: [.font: UIFont.boldSystemFont(ofSize: size)])
        inputBar.inputPlugins = [autocompleteManager]
    }

    override func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        setStateSending()
        DispatchQueue.global(qos: .background).async { [weak self] in
            sleep(2)
            DispatchQueue.main.async { [weak self] in
                self?.setStateReady()
            }
        }
    }

    private func setStateSending() {
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.placeholder = "Sending..."
        inputBar.inputTextView.isEditable = false
        inputBar.sendButton.startAnimating()
    }

    private func setStateReady() {
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.placeholder = "Aa"
        inputBar.inputTextView.isEditable = true
        inputBar.sendButton.stopAnimating()
    }
}

extension LifeAppMessageInput: AutocompleteManagerDelegate, AutocompleteManagerDataSource {

    // MARK: - AutocompleteManagerDataSource

    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {

        if prefix == "@" {
            let name = SampleData.shared.currentUser.name
                .lowercased().replacingOccurrences(of: " ", with: ".")
            return [AutocompleteCompletion(text: name)]
        } else {
            return ["InputBarAccessoryView", "iOS"].map { AutocompleteCompletion(text: $0) }
        }
    }

    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        if session.prefix == "@" {
            let user = SampleData.shared.currentUser
            //cell.imageView?.image = user.image
            cell.imageViewEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            cell.imageView?.layer.cornerRadius = 8
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.layer.borderColor = UIColor.systemBlue.cgColor
            cell.imageView?.layer.masksToBounds = true
        }
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15, keepPrefix: session.prefix == "#" )
        return cell
    }

    // MARK: - AutocompleteManagerDelegate

    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }

    // MARK: - AutocompleteManagerDelegate Helper

    func setAutocompleteManager(active: Bool) {
        let topStackView = inputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        inputBar.invalidateIntrinsicContentSize()
    }
}

