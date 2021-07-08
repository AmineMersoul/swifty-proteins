//
//  SceneViewController.swift
//  swifty-proteins
//
//  Created by Amine Mersoul on 7/7/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import UIKit
import SceneKit

class SceneViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.scene = SCNScene(named: "Earth.usdz")
    }
    

}
