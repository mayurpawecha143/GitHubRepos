//
//  ViewController.swift
//  GitHubRepos
//
//  Created by Mayur Pawecha on 8/16/18.
//  Copyright © 2018 MayurPawecha. All rights reserved.
//

import UIKit
enum ViewType {
    case List
    case Grid
}

class RepositoaryViewCell: UICollectionViewCell {
    @IBOutlet weak var iName: UILabel!
    @IBOutlet weak var iDescription: UILabel!
    @IBOutlet weak var iCreatedAt: UILabel!
    @IBOutlet weak var License: UILabel!
    
    func DisplayContent(repos: Repos) {
        iName.text = repos.name
        iDescription.text = repos.description
        iCreatedAt.text = repos.created_At
        License.text = repos.license
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var iTabBar: UITabBar!
    @IBOutlet weak var iTextField: UITextField!
    @IBOutlet weak var iCollectionView: UICollectionView!
    @IBOutlet weak var iSendBtn: UIButton!
    
    var iViewType = ViewType.List
    let store = DataStore.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateReposList(notification:)), name: NSNotification.Name(rawValue: "UpdateRepos"), object: nil)
        iTabBar.selectedItem = iTabBar.items![0] as UITabBarItem
    }
    
    @objc func UpdateReposList(notification: NSNotification){
        DispatchQueue.main.async {
            self.iCollectionView.reloadData()
        }
    }

    @IBAction func ShowRepos(_ sender: Any) {
        if !(iTextField.text?.isEmpty)! {
            ReloadView(value: 0)
        }
    }
    
    func ReloadView(value:Int) {
        store.GetRepoList(name: iTextField.text!, value: value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.ReposList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var reusableIdentifier = "singleCell"
        if iViewType == .Grid
        {
            reusableIdentifier = "halfCell"
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath as IndexPath) as! RepositoaryViewCell
        let repo = store.ReposList[indexPath.row]
        cell.DisplayContent(repos: repo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == store.ReposList.count - 1{
            ReloadView(value: indexPath.row + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize(width:self.view.frame.size.width , height:110)
        if self.iViewType == .Grid
        {
            cellSize = CGSize(width:self.view.frame.size.width/2 - 5 , height:110)
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

extension ViewController: UITabBarDelegate{
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if tabBar.selectedItem?.tag == 0
        {
            iViewType = .List
        }
        else
        {
            iViewType = .Grid
        }
        self.iCollectionView.reloadData()
    }
}

