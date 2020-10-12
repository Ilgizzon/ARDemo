//
//  ViewController.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 12.10.2020.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

 
    // MARK: IBOutlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sessionInfoView: UIVisualEffectView!
    @IBOutlet weak var textureModeSelectionControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    

}
