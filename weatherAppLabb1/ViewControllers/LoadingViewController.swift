//
//  LoadingViewController.swift
//  weatherAppLabb1
//
//  Created by Putte on 2020-02-19.
//  Copyright © 2020 Putte. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    //Create shapes
    var blackBox: UIView?
    var yellowSun: UIImageView?
    
    //Create animator
    var animator: UIDynamicAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()

        createAnimation()
    }
    
    func createAnimation(){
        //Navigate to next viewcontroller when time passed
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(navigateToRoot), userInfo: nil, repeats: false)
        
        //Create dimension
        var dimension = CGRect.init(x: self.view.frame.width / 2 - 75, y: 0, width: 150, height: 150)
        yellowSun = UIImageView(frame: dimension)
        yellowSun?.image = UIImage.init(named: "suncloud")
        
        dimension = CGRect.init(x: 0, y: -140, width: self.view.frame.width, height: 100)
        blackBox = UIView(frame: dimension)
        blackBox?.backgroundColor = UIColor.black
        
        //Add sun to Subview
        self.view.addSubview(yellowSun!)
        self.view.addSubview(blackBox!)
        
        //Initialize the animator
        animator = UIDynamicAnimator(referenceView: self.view)
        
        //Gravity
        let gravity = UIGravityBehavior(items: [blackBox!, yellowSun!])
        let direction = CGVector(dx: 0.0, dy: 0.4)
        gravity.gravityDirection = direction
        
        //Collision 1
        let edge = UIEdgeInsets(top: self.view.frame.height / 2 + 75, left: 0, bottom: 0, right: 0)
        let boundaries = UICollisionBehavior(items: [yellowSun!])
        boundaries.setTranslatesReferenceBoundsIntoBoundary(with: edge)
        
        //Collision 2
        let edge1 = UIEdgeInsets(top: self.view.frame.height / 2 - 150, left: 0, bottom: 0, right: 0)
        let boundaries1 = UICollisionBehavior(items: [blackBox!])
        boundaries1.setTranslatesReferenceBoundsIntoBoundary(with: edge1)
        
        //Create label inside of blackbox
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.blackBox!.frame.width, height: self.blackBox!.frame.height))
        label.textAlignment = .center
        label.font = label.font.withSize(40)
        label.textColor = UIColor.white
        label.text = "WeatherApp"
        self.blackBox!.addSubview(label)
        
        //Elasitcity
        let bounce = UIDynamicItemBehavior(items: [yellowSun!, blackBox!])
        bounce.elasticity = 0.0
        
        //Behavior
        animator?.addBehavior(bounce)
        animator?.addBehavior(boundaries)
        animator?.addBehavior(boundaries1)
        animator?.addBehavior(gravity)
    }
    
    //Navigate to Main screen when time passed.
    @objc func navigateToRoot(){
        self.performSegue(withIdentifier: "toMainScreen", sender: self)
    }
    
}
