//
//  CameraView.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI
import AVFoundation
import UIKit
import Photos

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturePhoto: Bool
    @Binding var isFlashOn: Bool
    @Binding var capturedImage: UIImage?
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }
            
            // Send the captured image back to ContentView
            DispatchQueue.main.async {
                self.parent.capturedImage = image
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if capturePhoto {
            uiViewController.capturePhoto()
            DispatchQueue.main.async {
                capturePhoto = false
            }
        }
        uiViewController.updateFlashMode(isFlashOn)
    }
}

class CameraViewController: UIViewController {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentDevice: AVCaptureDevice?
    private var loadingView: UIView?
    
    var delegate: CameraView.Coordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        checkCameraPermissions()
    }
    
    private func setupLoadingView() {
        loadingView = UIView(frame: view.bounds)
        loadingView?.backgroundColor = .black
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        if let loadingView = loadingView {
            view.addSubview(loadingView)
            loadingView.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
            ])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let captureSession = captureSession {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionDeniedMessage()
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        currentDevice = videoCaptureDevice
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession?.canAddInput(videoInput) ?? false {
                captureSession?.addInput(videoInput)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput,
               captureSession?.canAddOutput(photoOutput) ?? false {
                captureSession?.addOutput(photoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            
            if let previewLayer = previewLayer {
                view.layer.addSublayer(previewLayer)
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
                DispatchQueue.main.async {
                    self?.loadingView?.removeFromSuperview()
                    self?.loadingView = nil
                }
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        if let device = currentDevice, device.hasFlash {
            settings.flashMode = device.isTorchAvailable && device.torchMode == .on ? .on : .off
        }
        
        photoOutput.capturePhoto(with: settings, delegate: delegate!)
    }
    
    func updateFlashMode(_ isOn: Bool) {
        guard let device = currentDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error updating flash: \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func showCameraPermissionDeniedMessage() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.loadingView?.removeFromSuperview()
            
            let messageLabel = UILabel()
            messageLabel.text = "Camera access is required to scan egg photos.\nPlease enable camera access in Settings."
            messageLabel.textColor = .white
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.backgroundColor = .black
            self.view.addSubview(messageLabel)
            
            NSLayoutConstraint.activate([
                messageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                messageLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
                messageLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40)
            ])
        }
    }
}