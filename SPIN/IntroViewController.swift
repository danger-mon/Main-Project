//
//  IntroViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 17/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit

class IntroViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    let appearance = UIPageControl.appearance()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        // Do any additional setup after loading the view.
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
    }
    
    func setupPageControl(hidden: Bool) {
        
        if hidden{
            appearance.pageIndicatorTintColor = UIColor.lightGray
            appearance.currentPageIndicatorTintColor = UIColor.darkGray
            appearance.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            appearance.bounds = CGRect(x: 0, y: (0), width: UIScreen.main.bounds.width, height: 50)
            appearance.alpha = 0
            self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        } else {
            appearance.pageIndicatorTintColor = UIColor.lightGray
            appearance.currentPageIndicatorTintColor = UIColor.darkGray
            appearance.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            appearance.bounds = CGRect(x: 0, y: (0), width: UIScreen.main.bounds.width, height: 50)
            self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        setupPageControl(hidden: false)
        return 7
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "intro0"),
                self.newViewController(name: "spin1"),
                self.newViewController(name: "spin2"),
                self.newViewController(name: "spin3"),
                self.newViewController(name: "spin4"),
                self.newViewController(name: "spin5"),
            self.newViewController(name: "login")]
    }()
    
    private func newViewController(name: String) -> UIViewController {
        if name != "login" {
            
            let toReturn = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "intro1") as! IntroSubScreenViewController
            let _ = toReturn.view.description
            toReturn.imageView.contentMode = .scaleAspectFit
            toReturn.imageView.clipsToBounds = true
            
            if name == "intro1" {
                toReturn.imageView.image = #imageLiteral(resourceName: "Intro_0")
                toReturn.textView.text = " \nBuy, sell and rent dresses and special event wear from those around you"
            } else if name == "intro2" {
                toReturn.imageView.image = #imageLiteral(resourceName: "Intro_1")
                toReturn.textView.text = "\nArrange for pick up quickly and flexibly, through easy private messaging"
            } else if name == "intro3" {
                toReturn.imageView.image = #imageLiteral(resourceName: "Intro_2")
                toReturn.textView.text = "\nSave money and extend your wardrobe this may ball season!"
            } else if name == "intro0" {
                toReturn.imageView.image = nil
                toReturn.textView.text = "S P I N"
                toReturn.textView.font = UIFont(name: "Avenir-Light", size: 36)
                toReturn.textView.textAlignment = .center
            } else if name == "spin1" {
                var newFrame = toReturn.view.frame
                newFrame.origin.y += 30
                newFrame.size.height -= 60
                let imageView = UIImageView(frame: newFrame)
                imageView.image = #imageLiteral(resourceName: "spin1")
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = false
                toReturn.view.addSubview(imageView)
            } else if name == "spin2" {
                var newFrame = toReturn.view.frame
                newFrame.origin.y += 40
                newFrame.size.height -= 80
                let imageView = UIImageView(frame: newFrame)
                imageView.image = #imageLiteral(resourceName: "spin2")
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = false
                toReturn.view.addSubview(imageView)
            } else if name == "spin3" {
                var newFrame = toReturn.view.frame
                newFrame.origin.y += 40
                newFrame.size.height -= 80
                let imageView = UIImageView(frame: newFrame)
                imageView.image = #imageLiteral(resourceName: "spin3")
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = false
                toReturn.view.addSubview(imageView)
            } else if name == "spin4" {
                var newFrame = toReturn.view.frame
                newFrame.origin.y += 40
                newFrame.size.height -= 80
                let imageView = UIImageView(frame: newFrame)
                imageView.image = #imageLiteral(resourceName: "spin4")
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = false
                toReturn.view.addSubview(imageView)
            } else if name == "spin5" {
                var newFrame = toReturn.view.frame
                newFrame.origin.y += 40
                newFrame.size.height -= 80
                let imageView = UIImageView(frame: newFrame)
                imageView.image = #imageLiteral(resourceName: "spin5")
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = false
                toReturn.view.addSubview(imageView)
            }
            return toReturn
        } else {
            let toReturn = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
            return toReturn
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}
