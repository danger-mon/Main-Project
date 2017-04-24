import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {
    var freshLaunch = true
    var lastProfileUid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        for i in 0..<self.tabBar.items!.count {
            self.tabBar.items?[i].tag = i
        }

        self.tabBar.barTintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        self.tabBar.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.tabBar.isTranslucent = false
        self.navigationController?.navigationBar.isTranslucent = false
        

        
        UITabBar.appearance().alpha = 1
        UITabBar.appearance().backgroundColor = UIColor(red: 41/255, green: 37/255, blue: 47/255, alpha: 1)
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2
        
        
       /* let backgroundImage: UIImage = UIImage.init(named: "tabbar")!
        let imageView: UIImageView = UIImageView.init(frame: CGRect(x: 0, y: Int(UIScreen.main.bounds.height) - 100, width: Int(UIScreen.main.bounds.width), height: 100))
        imageView.contentMode = .scaleAspectFit
        imageView.image = backgroundImage
        self.view.addSubview(imageView) */
        
        tabBar.items?[0].title = "Saved"
        tabBar.items?[1].title = "Profile"
        
        tabBar.tintColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
        
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if freshLaunch == true {
            freshLaunch = false
            self.tabBarController?.selectedIndex = 2 // 3rd tab
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            lastProfileUid = ProfileViewController.uidToLoad
            ProfileViewController.uidToLoad = "self"
        } else if item.tag == 0 {
            ProfileViewController.uidToLoad = lastProfileUid
        }
    }

}
