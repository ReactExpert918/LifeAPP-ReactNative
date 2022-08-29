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
        
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.isHidden = true
        
        nextButton.isHidden = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellOfType: WalkthroughItemCell.self)
    }
    
    @IBAction func nextButtonDidTap(_ sender: Any) {
        view.isUserInteractionEnabled = false
        checkLogin()
        PrefsManager.setIgnoreWalkthrough(val: true)
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
    
    func scrollViewDidEndDecelerating(isLastVisible: Bool) {
        if isLastVisible {
            nextButton.isHidden = false
            nextButton.setTitle("Finish", for: .normal)
        } else {
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndices: [Int] = collectionView.visibleCells.compactMap({ collectionView.indexPath(for: $0)?.row })
        if visibleIndices.contains(model.items.count - 1) {
            scrollViewDidEndDecelerating(isLastVisible: true)
        } else {
            scrollViewDidEndDecelerating(isLastVisible: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let verticalPadding: CGFloat = 75
        let imageHeight: CGFloat = collectionView.frame.width - 50
        
        let label = UILabel(frame: .init(origin: .zero,
                                         size: .init(width: collectionView.frame.width, height: 0)))
        label.font = UIFont(name: "Montserrat-Regular", size: 15.0)
        label.text = model.items[indexPath.row].description
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        label.sizeToFit()
        
        let labelHeight: CGFloat = label.frame.height
    
        return CGSize(width: collectionView.frame.width,
                      height: labelHeight
                              + verticalPadding
                              + imageHeight)
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
