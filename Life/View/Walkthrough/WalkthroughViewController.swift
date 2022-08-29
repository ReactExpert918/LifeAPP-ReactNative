//
//  WalkthorughViewController.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/24/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import JamitFoundation

class WalkthroughViewController: StatefulViewController<WalkthroughViewModel> {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!

    var currentPage: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

//        pageControl.backgroundColor = UIColor(named: "messageOutgoingColor")?.withAlphaComponent(0.5)
//        pageControl.layer.cornerRadius = 13
        pageControl.isHidden = true
        
        nextButton.isHidden = true

//        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellOfType: WalkthroughItemCell.self)
        
        
    }

    @IBAction func nextButtonDidTap(_ sender: Any) {
        if currentPage == model.items.count - 1 {
            view.isUserInteractionEnabled = false
            checkLogin()
            PrefsManager.setIgnoreWalkthrough(val: true)
        } else {
            currentPage += 1
            let indexPath = IndexPath(row: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            scrollEnd()
        }
    }
    override func didChangeModel() {
        collectionView.reloadData()
        pageControl.numberOfPages = model.items.count
    }

    private func checkLogin() {
        let email = PrefsManager.getEmail()
        if email != "" {
            let password = PrefsManager.getPassword()
            AuthUser.signIn(email: email, password: password) {[weak self] (error) in
                guard let self = self else { return }
                if error != nil {
                    self.postUserLogin()
                    self.gotoMainViewController()
                    return
                }
                let userId = AuthUser.userId()
                FireFetcher.fetchPerson(userId) { error in
                    self.dismiss(animated: true) {
                        if error != nil {
                            self.gotoWelcomeViewController()
                        }
                        else {
                            self.postUserLogin()
                            self.gotoMainViewController()
                        }
                    }
                }
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.gotoWelcomeViewController()
            }
        }
    }

    private func postUserLogin() {
        NotificationCenter.default.post(name: Notification.Name(NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
    }

    private func gotoWelcomeViewController() {
        let mainstoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "rootNavigationViewController")
        UIApplication.shared.windows.first?.rootViewController = vc
    }

    private func gotoMainViewController() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIApplication.shared.windows.first?.rootViewController = vc
    }

    func scrollEnd() {
//        pageControl.currentPage = currentPage
        if model.items.count - 1 == currentPage {
            nextButton.isHidden = false
            nextButton.setTitle("Finish", for: .normal)
        } else {
//            nextButton.setTitle("Next", for: .normal)
            nextButton.isHidden = true
        }
    }
}

extension WalkthroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cellOfType: WalkthroughItemCell.self, for: indexPath)
        cell.model = model.items[indexPath.item]
        return cell
    }
}

extension WalkthroughViewController: UICollectionViewDelegate {
}

extension WalkthroughViewController: UICollectionViewDelegateFlowLayout {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
//        scrollEnd()
//    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentPage = indexPath.row
        scrollEnd()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}
