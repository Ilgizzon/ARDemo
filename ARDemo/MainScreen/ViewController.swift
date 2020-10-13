//
//  ViewController.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 12.10.2020.
//

import UIKit
import ARKit

class ViewController: UIViewController {

 
    // MARK: IBOutlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sessionInfoView: UIVisualEffectView!
    @IBOutlet weak var autoscaleModeSelectionControl: UISegmentedControl!
    
    var viewModel: ViewModelControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ControllerViewModel(with: self)
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.setupARView(with: sceneView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.pauseAR()
    }
    
    // MARK: - Session management
    
    @IBAction func changeMode(_ sender: UISegmentedControl) {
        let autoScaleMode = sender.selectedSegmentIndex == 0
        // Remove anchors and change scale mode
        viewModel?.resetAR(autoScaleMode)
    }
    
    @IBAction func restartExperience() {
        
        let autoScaleMode = autoscaleModeSelectionControl.selectedSegmentIndex == 0
        // Remove anchors and change scale mode
        viewModel?.resetAR(autoScaleMode)
    }
    
    private func setupGestures(){
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.rotation(_:)))
        self.view.addGestureRecognizer(rotationGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(_:)))
        self.view.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func rotation(_ sender: UIRotationGestureRecognizer) {
        viewModel?.rotation(sender)
    }
    
    @objc private func pinch(_ sender: UIPinchGestureRecognizer) {
        viewModel?.pinch(sender)
    }
    
    @objc private func pan(_ sender: UIPanGestureRecognizer) {
        viewModel?.pan(sender)
    }
    
    @objc private func tap(_ sender: UITapGestureRecognizer) {
        viewModel?.tap(sender)
    }
    

}

extension ViewController: ViewControllerDelegate {
    func infoMessage(message: String) {
        print(message)
    }
    
    
}
