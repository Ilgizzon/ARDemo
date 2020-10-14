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
    @IBOutlet weak var modelSelectionControl: UISegmentedControl!
    
    var viewModel: ViewModelControllerProtocol?
    
    init() {
        super.init(nibName: "ViewController", bundle: .main)
        
    }
    
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
        restartARSession()
    }
    
    @IBAction func changeModel(_ sender: UISegmentedControl) {
        restartARSession()
    }
    
    @IBAction func restartExperience() {
        restartARSession()
    }
    
    func restartARSession(){
        let autoScaleMode = autoscaleModeSelectionControl.selectedSegmentIndex == 0
        var selectedModel: SetCurrentModel = .gramophone
        // Remove anchors, change scale mode, set virtual object
        switch modelSelectionControl.selectedSegmentIndex {
        case 0:
            selectedModel = .gramophone
        case 1:
            selectedModel = .bike
        case 2:
            selectedModel = .lizardman
        default:
            break
        }
        viewModel?.resetAR(autoScaleMode, model: selectedModel)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController: ViewControllerDelegate {
    
    func infoMessage(message: String?) {
        // Show the message, or hide the label if there's no message.
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.sessionInfoLabel.text = message
                if message != nil {
                    self.sessionInfoView.alpha = 1
                } else {
                    self.sessionInfoView.alpha = 0
                }
            }
        }
    }
    
    func errorMessage(message: String?) {
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: message, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.restartARSession()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
