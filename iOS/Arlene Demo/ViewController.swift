//
//  ViewController.swift
//  Arlene Demo
//
//  Created by DigitallySavvy on 6/21/19.
//  Copyright © 2019 Arlene. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    let debug = true
    
    
    // MARK: VC Events
    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    // MARK: Create UI
    func createUI() {
        
        // add branded logo to remote view
        guard let arleneLogo = UIImage(named: "Arlene-Logo") else { return }
        let splashLogo = UIImageView(image: arleneLogo)
        splashLogo.frame = CGRect(x: self.view.center.x-150, y: self.view.center.y-100, width: 300, height: 75)
        self.view.insertSubview(splashLogo, at: 1)

        //  create button
        let bannerDemoBtn = UIButton()
        bannerDemoBtn.frame = CGRect(x: self.view.center.x-75, y: splashLogo.frame.maxY + 20, width: 150, height: 50)
        bannerDemoBtn.backgroundColor = UIColor.systemBlue
        bannerDemoBtn.layer.cornerRadius = 5
        bannerDemoBtn.setTitle("Launch Demo", for: .normal)
        bannerDemoBtn.addTarget(self, action: #selector(loadArleneDemo), for: .touchUpInside)
        self.view.addSubview(bannerDemoBtn)
    }
    
    // MARK: Load Arlene Demo
    @IBAction func loadArleneDemo(_ sender: UIButton) {
        let arleneDemoVC = ArleneDemoVC()
        arleneDemoVC.placementsList = getDictsFromFile(withKey: "PLACEMENTS", within: "placementsConfig")
        arleneDemoVC.modalPresentationStyle = .fullScreen
        self.present(arleneDemoVC, animated: true, completion: nil)
    }
    
}

