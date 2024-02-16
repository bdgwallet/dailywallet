//
//  QRScanner.swift
//  dailywallet
//
//  Created by Daniel Nordh on 19/01/2024.
//  Based on: https://www.appcoda.com/swiftui-qr-code-scanner-app/
//

import SwiftUI
import Foundation
import AVFoundation

struct ScannerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var scanResult: String
    
    let targetSide = UIScreen.main.bounds.width * 0.8
    
    var body: some View {
        ZStack(alignment: .bottom) {
            QRScanner(result: $scanResult)
            VStack{
                HStack{
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(24)
                    }
                }
                Spacer()
                RoundedRectangle(cornerRadius: 30)
                    .fill(.black.opacity(0.1))
                    .stroke(.white, lineWidth: 4)
                    .frame(width: targetSide, height: targetSide)
                Spacer()
            }
        }
        
    }
    
    struct QRScanner: UIViewControllerRepresentable {
        
        @Binding var result: String
        
        func makeUIViewController(context: Context) -> QRScannerController {
            let controller = QRScannerController()
            controller.delegate = context.coordinator
            
            return controller
        }
        
        func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator($result)
        }
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        
        @Binding var scanResult: String
        
        init(_ scanResult: Binding<String>) {
            self._scanResult = scanResult
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects.count == 0 {
                scanResult = "No QR code detected"
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObject.ObjectType.qr,
               let result = metadataObj.stringValue {
                
                scanResult = result
                print(scanResult)
                
            }
        }
    }
    
    class QRScannerController: UIViewController {
        var captureSession = AVCaptureSession()
        var videoPreviewLayer: AVCaptureVideoPreviewLayer?
        var qrCodeFrameView: UIView?
        
        var delegate: AVCaptureMetadataOutputObjectsDelegate?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Get the back-facing camera for capturing videos
            guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Failed to get the camera device")
                return
            }
            
            let videoInput: AVCaptureDeviceInput
            
            do {
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                videoInput = try AVCaptureDeviceInput(device: captureDevice)
                
            } catch {
                // If any error occurs, simply print it out and don't continue any more.
                print(error)
                return
            }
            
            // Set the input device on the capture session.
            captureSession.addInput(videoInput)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [ .qr ]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            
        }
        
    }
}
