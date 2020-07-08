//
//  CreateGroupViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/8.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addMemberCell", for: indexPath) as! AddMemberCell
            cell.circleView.cornerRadius = (UIScreen.main.bounds.width - 80) / 8
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addedMemberCell", for: indexPath) as! AddedMemberCell
            return cell
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 80) / 4
        let height = width + 40
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if let viewController = storyboard?.instantiateViewController(identifier: "addParticipantVC") as? AddParticipantsViewController {
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }

}
