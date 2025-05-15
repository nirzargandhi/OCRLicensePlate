//
//  HomeVC.swift
//  OCRLicensePlate
//
//  Created by Nirzar Gandhi on 25/04/25.
//

import UIKit
import AVFoundation
import Vision

class HomeVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var scanPlateLbl: UILabel!
    @IBOutlet weak var scanPlateBtn: UIButton!
    
    
    // MARK: - Properties
    fileprivate var captureSession: AVCaptureSession!
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate let licensePlateRegexs = [
        /* Constants.LicensePlate.standardRegex,
         Constants.LicensePlate.temporaryRegex,
         Constants.LicensePlate.militaryRegex,
         Constants.LicensePlate.diplomaticRegex,
         Constants.LicensePlate.vintageRegex,
         Constants.LicensePlate.bhSeriesRegex,
         Constants.LicensePlate.firstNumberRegex */
        Constants.LicensePlate.indianPlatePattern
    ]
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        
        self.setControlsProperty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    fileprivate func setControlsProperty() {
        
        self.view.backgroundColor = .white
        self.view.isOpaque = false
        
        // Camera Container
        self.cameraContainer.backgroundColor = .black
        self.cameraContainer.addRadiusWithBorder(radius: 10.0)
        self.cameraContainer.clipsToBounds = true
        
        // Scan Plate Label
        self.scanPlateLbl.backgroundColor = .clear
        self.scanPlateLbl.textColor = .black
        self.scanPlateLbl.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        self.scanPlateLbl.numberOfLines = 0
        self.scanPlateLbl.textAlignment = .left
        self.scanPlateLbl.text = "Scanning..."
        
        // Scan Plate Buttton
        self.scanPlateBtn.setBackgroundColor(color: .black, forState: .normal)
        self.scanPlateBtn.setTitleColor(.white, for: .normal)
        self.scanPlateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        self.scanPlateBtn.titleLabel?.lineBreakMode = .byClipping
        self.scanPlateBtn.layer.masksToBounds = true
        self.scanPlateBtn.addRadiusWithBorder(radius: 10.0)
        self.scanPlateBtn.showsTouchWhenHighlighted = false
        self.scanPlateBtn.adjustsImageWhenHighlighted = false
        self.scanPlateBtn.adjustsImageWhenDisabled = false
        self.scanPlateBtn.setTitle("Scan Plate", for: .normal)
    }
}


// MARK: - Call Back
extension HomeVC {
    
    fileprivate func requestCameraPermission() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            self.startCameraSession()
            
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { granted in
                
                DispatchQueue.main.async {
                    
                    if granted {
                        self.startCameraSession()
                    } else {
                        self.permissionDeniedAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            self.permissionDeniedAlert()
            
        @unknown default:
            print("Unknown camera authorization status.")
        }
    }
    
    fileprivate func permissionDeniedAlert() {
        
        let alertController = UIAlertController(title: "Camera Permission Denied",
                                                message: "Go to Settings > Privacy > Camera to allow access to your camera.",
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { _ in
            
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(settingsAction)
        alertController.addAction(okayAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func startCameraSession() {
        
        if self.captureSession != nil && self.captureSession.isRunning {
            
            self.previewLayer.removeFromSuperlayer()
            self.captureSession.stopRunning()
        }
        
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              self.captureSession.canAddInput(videoInput) else { return }
        
        self.captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.captureSession.addOutput(videoOutput)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        self.previewLayer.frame = self.cameraContainer.bounds
        self.view.setNeedsLayout()
        
        self.previewLayer.videoGravity = .resizeAspectFill
        self.cameraContainer.layer.addSublayer(self.previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    fileprivate func isValidIndianNumberPlate(_ plate: String) -> Bool {
        
        for pattern in self.licensePlateRegexs {
            
            if plate.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func scannedLicensePlate(licensePlate: String) {
        
        if !licensePlate.isEmpty {
            self.scanPlateLbl.text = "Number Plate Detected: \(licensePlate)"
        } else {
            self.scanPlateLbl.text = "No result found"
        }
    }
    
    fileprivate func clearCaptureSession() {
        
        self.previewLayer.removeFromSuperlayer()
        self.captureSession?.stopRunning()
        self.captureSession = nil
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBuffer Delegate
extension HomeVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        let request = VNRecognizeTextRequest { (request, error) in
            
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
            
            var allRecognizedText = ""
            
            for observation in observations {
                
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                
                allRecognizedText += topCandidate.string + "\n"  // Collect with newlines
                
                let mergedNumberPlate = allRecognizedText
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .uppercased()
                
                let isValidNumberPlate = self.isValidIndianNumberPlate(mergedNumberPlate)
                
                if isValidNumberPlate {
                    
                    print("Number Plate :\(mergedNumberPlate)")
                    
                    DispatchQueue.main.async {
                        self.scannedLicensePlate(licensePlate: mergedNumberPlate)
                        self.clearCaptureSession()
                    }
                    
                    break
                }
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        try? requestHandler.perform([request])
    }
}


// MARK: - Button Touch & Action
extension HomeVC {
    
    @IBAction func scanPlateBtnTouch(_ sender: Any) {
        
        self.scanPlateLbl.text = "Scanning..."
        self.requestCameraPermission()
    }
}
