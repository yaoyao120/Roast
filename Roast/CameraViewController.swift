//
//  CameraViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-05.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol CameraViewControllerDelegate: class {
    func cameraViewControllerDidAddPhoto(withData data: Data?)
}

class CameraViewController: UIViewController {
    
    fileprivate var session: AVCaptureSession!
    fileprivate var device: AVCaptureDevice!
    fileprivate var videoInput: AVCaptureDeviceInput!
    fileprivate var photoOutput: AVCapturePhotoOutput!
    fileprivate var videoLayer: AVCaptureVideoPreviewLayer!
    fileprivate let flashOnImage = UIImage(named: "ic_flash_on")
    fileprivate let flashOffImage = UIImage(named: "ic_flash_off")
    fileprivate let flashAutoImage = UIImage(named: "ic_flash_auto")
    fileprivate let retakeImage = UIImage(named: "ic_retake")
    fileprivate let doneImage = UIImage(named: "ic_check")
    
    fileprivate let videoDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaTypeVideo, position: .unspecified)!
    fileprivate var movieFileOutput: AVCaptureMovieFileOutput? = nil
    fileprivate var flashMode = AVCaptureFlashMode.off
    fileprivate var photoData: Data? = nil
    fileprivate var isCameraRunning = false
    weak var delegate: CameraViewControllerDelegate?
    
    @IBOutlet weak var buttonViewContainer: UIView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var snapButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Initial View
        buttonViewContainer.backgroundColor = UIColor.black
        tempImageView.isHidden = true
        tempImageView.contentMode = .scaleAspectFit
        flashButton.setImage(flashOffImage, for: .normal)
        snapButton.isEnabled = false
        flipButton.isEnabled = false
        flashButton.isEnabled = false
        
        //Check user camera authorization
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted:Bool) -> Void in
                DispatchQueue.main.async {
                    if granted {
                        print("*** camera authorized")
                        self.startCamera()
                    }
                    else {
                        print("*** camera denied")
                    }
                }
                
            })
        case .authorized:
            print("*** camera authorized")
            DispatchQueue.main.async {
                self.startCamera()
            }
        case .denied, .restricted:
            print("*** camera denied")
            DispatchQueue.main.async {
                self.albumViewShowCameraUnauthorizedAlert()
            }
        }
    }
    
    deinit {
        print("*** Camera View Removed")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Camera Setup Related Function
    fileprivate func startCamera() {
        session = AVCaptureSession()
        device = getDefaultDevice()
        flashButton.isHidden = device.hasFlash ? false : true
        cancelButton.backgroundColor = ymBackgroundColor.withAlphaComponent(0.95)
        doneButton.backgroundColor = ymBackgroundColor.withAlphaComponent(0.95)
        cancelButton.setImage(retakeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        doneButton.setImage(doneImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.tintColor = ymDarkTintColor
        doneButton.tintColor = ymCheckedColor
        cancelButton.layer.cornerRadius = cancelButton.bounds.width/2
        doneButton.layer.cornerRadius = doneButton.bounds.width/2
        cancelButton.isHidden = true
        doneButton.isHidden = true
        
        // Get video input for the default camera.
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else {
            print("Unable to obtain video input for default camera.")
            return
        }
        self.videoInput = videoInput
        
        // Create and configure the photo output.
        photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        
        // Make sure inputs and output can be added to session.
        guard self.session.canAddInput(videoInput) else { return }
        guard self.session.canAddOutput(photoOutput) else { return }
        
        // Configure the session.
        session.beginConfiguration()
        // Select highest preset resolution
        session.sessionPreset = getPreferredPreset(ofDevice: device)
        //session.sessionPreset = AVCaptureSessionPreset1280x720
        session.addInput(videoInput)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        
        // Configure the previewlayer
        videoLayer = AVCaptureVideoPreviewLayer(session: session)
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
        if statusBarOrientation != .unknown {
            if let videoOrientation = statusBarOrientation.videoOrientation {
                initialVideoOrientation = videoOrientation
            }
        }
        videoLayer?.connection.videoOrientation = initialVideoOrientation
        videoLayer?.frame = self.view.bounds
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(videoLayer!)
        self.view.bringSubview(toFront: buttonViewContainer)
        buttonViewContainer.backgroundColor = UIColor.clear
        
        snapButton.isEnabled = true
        flipButton.isEnabled = true
        flashButton.isEnabled = true
        
        isCameraRunning = true
        session.startRunning()
    }
    
    fileprivate func stopCamera() {
        isCameraRunning = false
        session.stopRunning()
    }
    
    fileprivate func getDefaultDevice() -> AVCaptureDevice {
        
        // Choose the back dual camera if available, otherwise default to a wide angle camera.
        if let dualCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .back) {
            return dualCameraDevice
        }
        else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
            // If the back dual camera is not available, default to the back wide angle camera.
            return backCameraDevice
        }
        else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
            // In some cases where users break their phones, the back wide angle camera is not available. In this case, we should default to the front wide angle camera.
            return frontCameraDevice
        } else {
            print("*** error get device")
            fatalError("All supported devices are expected to have at least one of the queried capture devices.")
        }
        
    }
    
    fileprivate func albumViewShowCameraUnauthorizedAlert() {
        
        print("Camera unauthorized")
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your carema", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - User Interaction Methods
    @IBAction private func dismissCarema(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func capturePhoto(_ sender: UIButton) {
        
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. We do this to ensure UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = videoLayer.connection.videoOrientation
        
        DispatchQueue.main.async {
            // Update the photo output's connection to match the video orientation of the video preview layer.
            if let photoOutputConnection = self.photoOutput.connection(withMediaType: AVMediaTypeVideo) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation
            }
            
            // Capture a JPEG photo with flash set to flashMode and high resolution photo enabled.
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.flashMode = self.flashMode
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.isAutoStillImageStabilizationEnabled = true
            
            /*
             The Photo Output keeps a weak reference to the photo capture delegate so
             we store it in an array to maintain a strong reference to this object
             until the capture is completed.
             */
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    @IBAction private func changeCamera(_ sender: UIButton) {
        snapButton.isEnabled = false
        flipButton.isEnabled = false
        dismissButton.isEnabled = false
        flashButton.isEnabled = false
        
        DispatchQueue.main.async {
            let currentVideoDevice = self.videoInput.device
            let currentPosition = currentVideoDevice!.position
            
            let preferredPosition: AVCaptureDevicePosition
            let preferredDeviceType: AVCaptureDeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDuoCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
            }
            
            let devices = self.videoDeviceDiscoverySession.devices!
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
            if let device = devices.filter({ $0.position == preferredPosition && $0.deviceType == preferredDeviceType }).first {
                newVideoDevice = device
            }
            else if let device = devices.filter({ $0.position == preferredPosition }).first {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                
                print(videoDevice.deviceType.rawValue)
                
                
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    //When changing from back to front, have to change preset back to low preset first, otherwise the session with highresolution can not add input with front device
                    if self.session.canSetSessionPreset(self.getPreferredPreset(ofDevice: videoDevice)) {   self.session.sessionPreset = self.getPreferredPreset(ofDevice: videoDevice)
                    }
                    
                    // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                    self.session.removeInput(self.videoInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        
                        self.session.addInput(videoDeviceInput)
                        self.device = videoDevice
                        self.videoInput = videoDeviceInput
                        
                        //When changing from front to back, the session can not set to back device's high preset, after adding the new input with back device, change the preset again
                        self.session.sessionPreset = self.getPreferredPreset(ofDevice: videoDevice)
                    }
                    else {
                        self.session.addInput(self.videoInput);
                    }
                    
                    if let connection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    self.session.commitConfiguration()
                }
                catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }
            
            self.snapButton.isEnabled = true
            self.flipButton.isEnabled = true
            self.dismissButton.isEnabled = true
            self.flashButton.isEnabled = true
            self.flashButton.isHidden = self.videoInput.device.hasFlash ? false : true
        }
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {
        
        do {
            
            if let device = device {
                guard device.hasFlash else { return }
                try device.lockForConfiguration()
                
                if flashMode == AVCaptureFlashMode.off {
                    flashMode = AVCaptureFlashMode.on
                    flashButton.setImage(flashOnImage, for: .normal)
                } else if flashMode == AVCaptureFlashMode.on {
                    flashMode = AVCaptureFlashMode.auto
                    flashButton.setImage(flashAutoImage, for: .normal)
                } else {
                    flashMode = AVCaptureFlashMode.off
                    flashButton.setImage(flashOffImage, for: .normal)
                }
                device.unlockForConfiguration()
            }
        } catch {
            flashButton.setImage(flashOffImage, for: .normal)
            return
        }
    }
    
    @IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        guard isCameraRunning == true else { return }
        
        let devicePoint = videoLayer.captureDevicePointOfInterest(for: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
        showFocusView(at: gestureRecognizer.location(in: buttonViewContainer))
    }
    
    @IBAction func retakePhoto(_ sender: Any) {
        
        tempImageView.image = nil
        tempImageView.isHidden = true
        
        flashButton.isHidden = false
        dismissButton.isHidden = false
        flipButton.isHidden = false
        snapButton.isHidden = false
        cancelButton.isHidden = true
        doneButton.isHidden = true
        isCameraRunning = true
        session.startRunning()
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            PHPhotoLibrary.requestAuthorization({status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        self.delegate?.cameraViewControllerDidAddPhoto(withData: self.photoData)
                        self.dismiss(animated: true, completion: nil)
                        print("*** Authorized")
                    case .denied, .restricted:
                        print("*** Denied")
                    case .notDetermined:
                        print("*** Undetermined")
                    }
                }
                
            })
            
        case .authorized:
            self.delegate?.cameraViewControllerDidAddPhoto(withData: self.photoData)
            self.dismiss(animated: true, completion: nil)
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.albumViewShowPhotoLibraryUnauthorizedAlert()
            }
        }
    }
    
    
    //MARK: - Tool Box Function and Variables
    
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .autoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    private func focus(with focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        DispatchQueue.main.async {
            if let device = self.videoInput.device {
                do {
                    try device.lockForConfiguration()
                    
                    /*
                     Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                     Call set(Focus/Exposure)Mode() to apply the new point of interest.
                     */
                    if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                        device.focusPointOfInterest = devicePoint
                        device.focusMode = focusMode
                    }
                    
                    if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                        device.exposurePointOfInterest = devicePoint
                        device.exposureMode = exposureMode
                    }
                    
                    device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                    device.unlockForConfiguration()
                    
                }
                catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        }
    }
    
    private func showFocusView(at point: CGPoint) {
        
        let focusView = UIView(frame: CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100))
        focusView.alpha = 0.0
        focusView.backgroundColor = UIColor.clear
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 1.5
        focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.buttonViewContainer.addSubview(focusView)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0, options: UIViewAnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                focusView.alpha = 1.0
                focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            focusView.removeFromSuperview()
        })
    }
    
    // Select highest preset resolution
    fileprivate func getPreferredPreset(ofDevice device: AVCaptureDevice) -> String {
        if device.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1920x1080) {
            
            print(AVCaptureSessionPreset1920x1080)
            return AVCaptureSessionPreset1920x1080
        } else if device.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1280x720) {
            
            print(AVCaptureSessionPreset1280x720)
            return AVCaptureSessionPreset1280x720
        } else {
            
            print(AVCaptureSessionPresetPhoto)
            return AVCaptureSessionPresetPhoto
        }
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        }
        else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        guard let photoData = photoData else {
            print("No photo data resource")
            return
        }
        guard let image = UIImage(data: photoData) else {
            print("Error generating image from data")
            return
        }
        
        self.tempImageView.image = image
        self.tempImageView.isHidden = false
        
        isCameraRunning = false
        stopCamera()
        flashButton.isHidden = true
        dismissButton.isHidden = true
        flipButton.isHidden = true
        snapButton.isHidden = true
        cancelButton.isHidden = false
        doneButton.isHidden = false
        
    }
    
    
    func albumViewShowPhotoLibraryUnauthorizedAlert() {
        
        print("Camera roll unauthorized")
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
