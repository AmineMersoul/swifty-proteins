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

    @IBOutlet weak var proteinScene: SCNView!
    
    @IBOutlet weak var atomName: UILabel!
    @IBOutlet weak var atomPhase: UILabel!
    @IBOutlet weak var atomSummary:UITextView!
    
    var oldNode: SCNNode?
    var oldColor: UIColor?
    var pdbfile : String?
    var name : String?
    var atoms: Elements?
    
    var pdbFile = "001"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        atomSummary.isEditable = false
        proteinScene.isHidden = true
        atomSummary.isHidden = true
        atomName.text = ""
        atomPhase.text = ""
        atoms = GetAtomInfo().getInfo()
        
        // creating spinner
        let spinner = SpinnerViewController()
        // add the spinner view controller
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        
        Api.app.getpdbFile(pdbFile: pdbFile) {(pdbContent) in
            DispatchQueue.main.async {
                
                //remove sipnner
                spinner.willMove(toParent: nil)
                spinner.view.removeFromSuperview()
                spinner.removeFromParent()
                
                self.proteinScene.backgroundColor = UIColor.white
                self.proteinScene.allowsCameraControl = true
                self.proteinScene.autoenablesDefaultLighting = true
                self.proteinScene.scene = ProteinScene(pdbFile: pdbContent)
                self.proteinScene.isHidden = false
            }
        }
        
        navigationItem.title = name ?? ""
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red: 220/255, green: 224/255, blue: 230/255, alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        let doneButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareAction))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.oldNode?.removeAllActions()
    }
    
    @objc func shareAction() {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let img = img {
            let objectsToShare = [img] as [UIImage]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: proteinScene)
        let hitList = proteinScene.hitTest(location, options: nil)
    
        DispatchQueue.main.async {
            if let hitObject = hitList.first {
                if hitObject.node.name != "CONECT" && touches.count == 1 {
                    
                    self.oldNode?.removeAllActions()
                    self.oldNode?.geometry?.firstMaterial?.diffuse.contents = self.oldColor
                    
                    for element in ((self.atoms?.elements)!) {
                        if (element.symbol?.lowercased() == hitObject.node.name?.lowercased()) {
                            self.initAtomLabels(element: element)
                            self.manageSphereSelection(sphere: hitObject.node)
                        }
                    }
                }
            } else if (touches.count > 1) {
                self.atomSummary.isHidden = true
                self.atomName.text = ""
                
                self.oldNode?.removeAllActions()
                self.oldNode?.geometry?.firstMaterial?.diffuse.contents = self.oldColor
            }
        }
    }
    
    func manageSphereSelection(sphere: SCNNode) {
        let oldColor = sphere.geometry?.firstMaterial?.diffuse.contents as! UIColor
        let newColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
        let duration: TimeInterval = 0.5
        let act0 = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
            let percentage = elapsedTime / CGFloat(duration)
            node.geometry?.firstMaterial?.diffuse.contents = self.aniColor(from: newColor, to: oldColor, percentage: percentage)
        })
        let act1 = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
            let percentage = elapsedTime / CGFloat(duration)
            node.geometry?.firstMaterial?.diffuse.contents = self.aniColor(from: oldColor, to: newColor, percentage: percentage)
        })
        
        let act = SCNAction.repeatForever(SCNAction.sequence([act0, act1]))
        sphere.runAction(act)
        
        self.oldNode = sphere
        self.oldColor = oldColor
    }
    
    func aniColor(from: UIColor, to: UIColor, percentage: CGFloat) -> UIColor {
        let fromComponents = from.cgColor.components!
        let toComponents = to.cgColor.components!
        
        let color = UIColor(red: fromComponents[0] + (toComponents[0] - fromComponents[0]) * percentage,
                            green: fromComponents[1] + (toComponents[1] - fromComponents[1]) * percentage,
                            blue: fromComponents[2] + (toComponents[2] - fromComponents[2]) * percentage,
                            alpha: fromComponents[3] + (toComponents[3] - fromComponents[3]) * percentage)
        return color
    }
    
    func initAtomLabels (element: AtomInfo) {
        atomSummary.isHidden = false
        atomName.text = element.name! + " (" + element.symbol! + ")"
        atomPhase.text = "Phase: " + (element.phase == nil ? "no info" : String(describing: element.phase!))
        atomSummary.text = element.summary
    }
}

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
