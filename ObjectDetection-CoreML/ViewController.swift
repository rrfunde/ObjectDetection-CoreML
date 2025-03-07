//
//  ViewController.swift
//  SSDMobileNet-CoreML
//
//  Created by GwakDoyoung on 01/02/2019.
//  Copyright © 2019 Ventii. All rights reserved.
//

import UIKit
import Vision
import CoreMedia
import AsyncBluetooth
import BoostBLEKit

class ViewController: UIViewController {

    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var characteristic: Characteristic?
    var peripheral: Peripheral?
    private var deviceUtils: DeviceUtils?
    var currentRotation: RotationDirection = .center
    private var pixelBuffer: CVPixelBuffer?

    // MARK - Core ML model
    // YOLOv3(iOS12+), YOLOv3FP16(iOS12+), YOLOv3Int8LUT(iOS12+)
    // YOLOv3Tiny(iOS12+), YOLOv3TinyFP16(iOS12+), YOLOv3TinyInt8LUT(iOS12+)
    // MobileNetV2_SSDLite(iOS12+), ObjectDetector(iOS12+)
    // yolov5n(iOS13+), yolov5s(iOS13+), yolov5m(iOS13+), yolov5l(iOS13+), yolov5x(iOS13+)
    // yolov5n6(iOS13+), yolov5s6(iOS13+), yolov5m6(iOS13+), yolov5l6(iOS13+), yolov5x6(iOS13+)
    // yolov8n(iOS14+), yolov8s(iOS14+), yolov8m(iOS14+), yolov8l(iOS14+), yolov8x(iOS14+)
    lazy var objectDectectionModel = { return try? yolov8x() }()
    
    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    var isInferencing = false
    
    // MARK: - AV Property
    var videoCapture = VideoCapture()
    let semaphore = DispatchSemaphore(value: 1)
    var lastExecution = Date()
    
    
    // MARK: - TableView Data
    var predictions: [VNRecognizedObjectObservation] = []
    
    // MARK - Performance Measurement Property
    private let 👨‍🔧 = 📏()
    
    let maf1 = MovingAverageFilter()
    let maf2 = MovingAverageFilter()
    let maf3 = MovingAverageFilter()
    
    
    @IBAction func recordingStarted(_ sender: Any) {
        videoCapture._captureState = .start
        currentRotation = .center
        UIApplication.shared.isIdleTimerDisabled = true
        startButton.setTitle("started", for: .normal)
        stopButton.setTitle("stop", for: .normal)
    }
    
    
    @IBAction func recordingStopped(_ sender: Any) {
        videoCapture._captureState = .end
        UIApplication.shared.isIdleTimerDisabled = false
        startButton.setTitle("start", for: .normal)
        stopButton.setTitle("stopped", for: .normal)
    }
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the model
        setUpModel()
        
        // setup camera
        setUpCamera()
        
        // setup delegate for performance measurement
        👨‍🔧.delegate = self
        
        if characteristic != nil && peripheral != nil {
            deviceUtils = DeviceUtils(characteristic: characteristic!, peripheral: peripheral!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        guard let objectDectectionModel = objectDectectionModel else { fatalError("fail to load the model") }
        if let visionModel = try? VNCoreMLModel(for: objectDectectionModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError("fail to create vision model")
        }
    }

    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .iFrame1280x720) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

// MARK: - VideoCaptureDelegate
extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        if !self.isInferencing, let pixelBuffer = pixelBuffer {
            self.isInferencing = true
            
            // start of measure
            self.👨‍🔧.🎬👏()
            
            // predict!
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}

extension ViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        // vision framework configures the input size of image following our model's input configuration automatically
        self.semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
        
        self.pixelBuffer = pixelBuffer
    }
    
    // MARK: - Post-processing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        self.👨‍🔧.🏷(with: "endInference")
        if let predictions = request.results as? [VNRecognizedObjectObservation] {
//            print(predictions.first?.labels.first?.identifier ?? "nil")
//            print(predictions.first?.labels.first?.confidence ?? -1)
            
            let filteredPredictions = filterRecognizedObjects(byLabels: predictions)
            
            self.predictions = filteredPredictions
            
            print("zzzzzzz \(filteredPredictions.map { $0.label })")
            
            if filteredPredictions.count > 0 {
                let centerOfGravity = DistanceUtils.centerOfGravity(playersXAxis: filteredPredictions.map { $0.boundingBox.midX })
                print("xxxxxxxxx \(filteredPredictions.map { $0.label }), \(filteredPredictions.map { $0.boundingBox.midX }),  \(centerOfGravity))")
                
                if centerOfGravity != nil {
                    if videoCapture._captureState == .capturing, let rotationDirection = DistanceUtils.rotationThreeAngelInfo(largestGroupMidX: centerOfGravity!, currentRotation: currentRotation)
                    {
//                        _ = DistanceUtils.rotationInfo(direction: rotationDirection)
                        let nextRotationDirection = DistanceUtils.nextRotationInfo(currentRotation: currentRotation, expectedRotation: rotationDirection)
                        
                        let currentDate = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .medium
                        
                        let currentTime = dateFormatter.string(from: currentDate)
                        
                        print("aaaaaaax \(currentTime), \(currentRotation), \(rotationDirection)")
                        if nextRotationDirection != nil {
                            print("aaaaaaaay \(currentTime), \(currentRotation), \(rotationDirection), \(nextRotationDirection!)")
                            deviceUtils?.rotate(direction: nextRotationDirection!)
                            
                            if self.pixelBuffer != nil, let image = pixelBufferToUIImage(pixelBuffer: pixelBuffer!) {
                                let newImage = drawText(on: image, text: "\(currentRotation), \(rotationDirection), \(nextRotationDirection!)", at: CGPoint(x: 50, y: 50))
                                
                                if let newImage = newImage {
                                    saveImage(image: newImage)
                                }
                            }
                            
                        }
                        currentRotation = rotationDirection
                    
                    }
                }
                
            }
            DispatchQueue.main.async {
                self.boxesView.predictedObjects = filteredPredictions
//                self.labelsTableView.reloadData()

                // end of measure
                self.👨‍🔧.🎬🤚()
                
                self.isInferencing = false
            }
        } else {
            // end of measure
            self.👨‍🔧.🎬🤚()
            
            self.isInferencing = false
        }
        self.semaphore.signal()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") else {
            return UITableViewCell()
        }

        let rectString = predictions[indexPath.row].boundingBox.toString(digit: 2)
        let confidence = predictions[indexPath.row].labels.first?.confidence ?? -1
        let confidenceString = String(format: "%.3f", confidence/*Math.sigmoid(confidence)*/)
        
        cell.textLabel?.text = predictions[indexPath.row].label ?? "N/A"
        cell.detailTextLabel?.text = "\(rectString), \(confidenceString)"
        return cell
    }
}

// MARK: - 📏(Performance Measurement) Delegate
extension ViewController: 📏Delegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        //print(executionTime, fps)
        DispatchQueue.main.async {
            self.maf1.append(element: Int(inferenceTime*1000.0))
            self.maf2.append(element: Int(executionTime*1000.0))
            self.maf3.append(element: fps)
            
            self.inferenceLabel.text = "inference: \(self.maf1.averageValue) ms"
            self.etimeLabel.text = "execution: \(self.maf2.averageValue) ms"
            self.fpsLabel.text = "fps: \(self.maf3.averageValue)"
        }
    }
}

class MovingAverageFilter {
    private var arr: [Int] = []
    private let maxCount = 10
    
    public func append(element: Int) {
        arr.append(element)
        if arr.count > maxCount {
            arr.removeFirst()
        }
    }
    
    public var averageValue: Int {
        guard !arr.isEmpty else { return 0 }
        let sum = arr.reduce(0) { $0 + $1 }
        return Int(Double(sum) / Double(arr.count))
    }
}


extension ViewController {
    func filterRecognizedObjects(byLabels observations: [VNRecognizedObjectObservation]) -> [VNRecognizedObjectObservation] {
        let allowedLabels = ["person"]

        let filteredObservations = observations.filter { observation in
            for labelObservation in observation.labels {
                return allowedLabels.contains(labelObservation.identifier)
            }
            return false
        }
        
        return filteredObservations
    }
    
    func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        ciImage.oriented(.rightMirrored)
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        
        if let cgImage = cgImage {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }

    func saveImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle error
            print("Error saving image: \(error)")
        } else {
            print("Image saved successfully")
        }
    }
    
    func drawText(on image: UIImage, text: String, at point: CGPoint) -> UIImage? {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let backgroundRectColor = UIColor.white
        
        // Set time style
        dateFormatter.timeStyle = .medium

        let currentTime = dateFormatter.string(from: currentDate)
        
        let drawableText = currentTime + text
        let textColor = UIColor.red
        let textFont = UIFont.systemFont(ofSize: 40)
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: textColor
        ]
        
        let textSize = drawableText.size(withAttributes: attrs)
        let backgroundRect = CGRect(x: point.x, y: point.y, width: textSize.width, height: textSize.height)
           
        // Draw white background rectangle
           let context = UIGraphicsGetCurrentContext()
           context?.setFillColor(backgroundRectColor.cgColor)
           context?.fill(backgroundRect)
        
        drawableText.draw(at: point, withAttributes: attrs)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
