//
//  SceneViewController.swift
//  swifty-proteins
//
//  Created by Amine Mersoul on 7/7/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import UIKit
import SceneKit

struct Elements : Decodable {
    let elements: [AtomInfo]?
}

struct AtomInfo: Decodable {
    let name: String?
    let phase: String?
    let summary: String?
    let symbol: String?
}

class GetAtomInfo {
    
    func getInfo() -> Elements? {
        var jsonResult:Elements? = nil
        if let path = Bundle.main.path(forResource: "PeriodicTable", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                jsonResult = try JSONDecoder().decode(Elements.self, from: data) as Elements?
                return jsonResult
            } catch {
                print("error vse dela")
            }
        }
        return jsonResult
    }
}


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
    
    let pdbFile = "001_ideal"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proteinScene.backgroundColor = UIColor.white
        proteinScene.allowsCameraControl = true
        proteinScene.autoenablesDefaultLighting = true
        atomSummary.isEditable = false
        
        
        if let path = Bundle.main.path(forResource: pdbFile, ofType: "pdb"){
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                let pdbContent = myStrings.joined(separator: "\n")
                proteinScene.scene = ProteinScene(pdbFile: pdbContent)
            } catch {
                print(error)
            }
        }
        
        atomSummary.isHidden = true
        atomName.text = ""
        atomPhase.text = ""
        atoms = GetAtomInfo().getInfo()
        
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

class AtomConnections: SCNNode {
    
    init (v1: SCNVector3, v2: SCNVector3) {
        super.init()
        let parentNode = SCNNode()
        let height = distance(v1: v1, v2: v2)

        self.position = v1
        let nodeV2 = SCNNode()
        nodeV2.position = v2
        parentNode.addChildNode(nodeV2)
        
        let layDown = SCNNode()
        layDown.eulerAngles.x = Float(Double.pi / 2)
        
        let cylinder = SCNCylinder(radius: 0.1, height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = UIColor.white
        
        let nodeWithCylinder = SCNNode(geometry: cylinder)
        nodeWithCylinder.position.y = -height / 2
        layDown.addChildNode(nodeWithCylinder)
        
        self.addChildNode(layDown)
        self.constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func distance (v1: SCNVector3, v2: SCNVector3) -> Float {
        let xd = v2.x - v1.x
        let yd = v2.y - v1.y
        let zd = v2.z - v1.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
    
}

class ProteinScene: SCNScene, SCNNodeRendererDelegate {
    
    var atoms : [SCNNode?] = []
    var cameraNode: SCNNode!
    
    init(pdbFile: String) {
        super.init()
        initCamera()
        self.background.contents = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
        let protein = pdbFile.split(separator: "\n")
        
        for line in protein {
            let splitedLine = line.split(separator: " ")
            if splitedLine[0] == "ATOM" {
                let sphereGeometry = SCNSphere(radius: 0.3)
                sphereGeometry.firstMaterial?.diffuse.contents = spkColoring(atomName: String(splitedLine[11]))
                let sphereNode = SCNNode(geometry: sphereGeometry)
                sphereNode.position = SCNVector3(Double(splitedLine[6])!, Double(splitedLine[7])!, Double(splitedLine[8])!)
                sphereNode.name = String(splitedLine[11])
                atoms.append(sphereNode)
                self.rootNode.addChildNode(sphereNode)
            }
            else if splitedLine[0] == "CONECT" {
                var i: Int = 0
                let atomsRange = atoms.count
                let parentAtom: Int = Int(splitedLine[1])! - 1
                for elem in splitedLine {
                    let dauterAtom = (Int(elem) ?? 0) - 1
                    if i > 1 {
                        if (parentAtom < atomsRange && dauterAtom < atomsRange) {
                            let newConnection = AtomConnections(v1: (atoms[parentAtom]?.position)!, v2: (atoms[Int(elem)! - 1]?.position)!)
                            newConnection.name = "CONECT"
                            self.rootNode.addChildNode(newConnection)
                        }
                    }
                    i += 1
                }
            }
        }
    }
    
    func initCamera () {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 30)
        
        self.rootNode.addChildNode(cameraNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spkColoring (atomName: String) -> UIColor {
        switch atomName.lowercased() {
        case "h":
            return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        case "c":
            return UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        case "n":
            return UIColor(red: 37/255, green: 51/255, blue: 245/255, alpha: 1)
        case "o":
            return UIColor(red: 234/255, green: 62/255, blue: 37/255, alpha: 1)
        case "f", "cl" :
            return UIColor(red: 113/255, green: 236/255, blue: 78/255, alpha: 1)
        case "br":
            return UIColor(red: 141/255, green: 45/255, blue: 19/255, alpha: 1)
        case "i":
            return UIColor(red: 93/255, green: 14/255, blue: 180/255, alpha: 1)
        case "he", "ne", "ar", "xe", "kr":
            return UIColor(red: 117/255, green: 251/255, blue: 253/255, alpha: 1)
        case "p":
            return UIColor(red: 240/255, green: 158/255, blue: 57/255, alpha: 1)
        case "s":
            return UIColor(red: 251/255, green: 230/255, blue: 84/255, alpha: 1)
        case "b":
            return UIColor(red: 243/255, green: 174/255, blue: 128/255, alpha: 1)
        case "li", "na", "k", "rb", "cs", "fr":
            return UIColor(red: 108/255, green: 18/255, blue: 245/255, alpha: 1)
        case "be", "mg", "ca", "sr", "ba", "ra":
            return UIColor(red: 51/255, green: 117/255, blue: 31/255, alpha: 1)
        case "ti":
            return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        case "fe":
            return UIColor(red: 207/255, green: 124/255, blue: 45/255, alpha: 1)
        default:
            return UIColor(red: 208/255, green: 124/255, blue: 248/255, alpha: 1)
        }
    }
    
}
