//
//  ViewModel.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 13.10.2020.
//

import Foundation
import ARKit

class ControllerViewModel: ViewModelControllerProtocol {
    

    
    weak var delegate: ViewControllerDelegate?
    private var currentModel: SetCurrentModel = .gramophone
    private var arService: ARService?
    private let storageQueque = DispatchQueue(label: "storage queue")
    private let arQueque = DispatchQueue(label: "AR queue")
    private var arState: ARState = .none
    private var virtualModelState: VirtualModelState = .none
    private var tempTapGesture: UITapGestureRecognizer?
    init(with delegate: ViewControllerDelegate) {
        self.delegate = delegate
        storageQueque.async { [weak self] in
            guard let self = self else {
                return
            }
            self.loadVirtualObject()
        }
    }
    
    
    func setupARView(with sceneView: ARSCNView) {
        arService = ARService(arSceneView: sceneView)
        subscribeARListeners()
    }
    
    func pauseAR() {
        arService?.pauseSession()
    }
    
    func resetAR(_ autoScaleMode: Bool, model: SetCurrentModel, envMode: ARWorldTrackingConfiguration.EnvironmentTexturing) {
        currentModel = model
        arService?.resetTracking(autoScaleMode: autoScaleMode, environmentMode: envMode)
        self.loadVirtualObject()
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        
            switch self.virtualModelState {
            case .ready:
                arQueque.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.arService?.tap(gesture)
                }
                arState = . none
            case .loading:
                arState = .waitModel
                tempTapGesture = gesture
            case .none:
                break
            }
    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        arService?.pan(gesture)
    }
    
    func pinch(_ gesture: UIPinchGestureRecognizer) {
        arService?.pinch(gesture)
    }
    
    func rotation(_ gesture: UIRotationGestureRecognizer) {
        arService?.rotation(gesture)
    }
    
    private func loadVirtualObject(){
        self.virtualModelState = .loading
        StorageManager.shared.load(modelName: currentModel.rawValue) {[weak self] (comletion: Result<SCNNode, Error>) in
            guard let self = self else {
                return
            }
            switch comletion {
            case .success(let object):
                self.arService?.setVirtualObject(object: object)
                self.virtualModelState = .ready
                switch self.arState {
                
                case .waitModel:
                    self.arQueque.async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        self.arService?.tap(self.tempTapGesture)
                    }
                    
                case .none:
                    break
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func subscribeARListeners(){
        
        self.arService?.subscribeErrors {  [weak self] errors in
            guard let self = self else {
                return
            }
            self.delegate?.errorMessage(message: errors)
        }
        
        self.arService?.subscribeInfoMessages {  [weak self] messages in
            guard let self = self else {
                return
            }
            self.delegate?.infoMessage(message: messages)
        }
    }
    
    private enum VirtualModelState {
        case ready
        case loading
        case none
    }
    
    private enum ARState {
        case waitModel
        case none
    }
    
    deinit {
        arService = nil
    }
}
