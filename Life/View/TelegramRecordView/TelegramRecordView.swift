//
//  TelegramRecordView.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/24/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

protocol TelegramRecordViewDelegate {
    func didFinishRecording(url: URL)
}

class TelegramRecordView: UIView,
    AVCaptureAudioDataOutputSampleBufferDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var cameraView: UIView!
    var tempImage: UIImageView?

    var delegate: TelegramRecordViewDelegate?

    private var session: AVCaptureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()

    private var videoDevice: AVCaptureDevice? =
    AVCaptureDevice.default(.builtInWideAngleCamera, for: .video , position: .front)
    private var audioConnection: AVCaptureConnection?
    private var videoConnection: AVCaptureConnection?

    private var assetWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?
    private var videoInput: AVAssetWriterInput?

    private var fileManager: FileManager = FileManager()
    private var recordingURL: URL?

    private var isCameraRecording: Bool = false
    private var isRecordingSessionStarted: Bool = false

    private var recordingQueue = DispatchQueue(label: "recording.queue")
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCaptureDevice: AVCaptureDevice?

    var usingFrontCamera = false



    override func awakeFromNib() {
//        cameraView.layer.cornerRadius = cameraView.bounds.width / 2

    }

    private func setup() {
        cameraView.layer.cornerRadius = 100
        self.session.sessionPreset = AVCaptureSession.Preset.high

        self.recordingURL = URL(fileURLWithPath: "\(NSTemporaryDirectory() as String)/file.mov")
        if self.fileManager.isDeletableFile(atPath: self.recordingURL!.path) {
            _ = try? self.fileManager.removeItem(atPath: self.recordingURL!.path)
        }

        self.assetWriter = try? AVAssetWriter(outputURL: self.recordingURL!,
                                              fileType: AVFileType.mov)

        let audioSettings = [
            AVFormatIDKey : kAudioFormatAppleIMA4,
            AVNumberOfChannelsKey : 1,
            AVSampleRateKey : 16000.0
        ] as [String : Any]

        let videoSettings = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
            AVVideoWidthKey : self.bounds.width,
            AVVideoHeightKey : self.bounds.height
        ] as [String : Any]

        self.videoInput = AVAssetWriterInput(mediaType: AVMediaType.video,
             outputSettings: videoSettings)
        self.audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio,
             outputSettings: audioSettings)

        self.videoInput?.expectsMediaDataInRealTime = true
        self.audioInput?.expectsMediaDataInRealTime = true

        if self.assetWriter!.canAdd(self.videoInput!) {
            self.assetWriter?.add(self.videoInput!)
        }

        if self.assetWriter!.canAdd(self.audioInput!) {
            self.assetWriter?.add(self.audioInput!)
        }

        guard let videoDevice = videoDevice else {
            return
        }
        self.deviceInput = try? AVCaptureDeviceInput(device: videoDevice)

        if let deviceInput = self.deviceInput {
            if self.session.canAddInput(deviceInput) {
                self.session.addInput(deviceInput)
            }
        }


        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer?.cornerRadius = 100
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        let rootLayer = self.layer
        rootLayer.masksToBounds = true
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)

        rootLayer.insertSublayer(self.previewLayer!, at: 0)

        self.session.startRunning()

        DispatchQueue.main.async {
            self.session.beginConfiguration()

            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }

            self.videoConnection = self.videoOutput.connection(with: AVMediaType.video)
            if self.videoConnection?.isVideoStabilizationSupported == true {
                self.videoConnection?.preferredVideoStabilizationMode = .auto
            }
            self.videoConnection?.videoOrientation = .portrait
            self.session.commitConfiguration()

            guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
            if let audioIn = try? AVCaptureDeviceInput(device: audioDevice) {

            if self.session.canAddInput(audioIn) {
                self.session.addInput(audioIn)
            }
            }

            if self.session.canAddOutput(self.audioOutput) {
                self.session.addOutput(self.audioOutput)
            }

            self.audioConnection = self.audioOutput.connection(with: AVMediaType.audio)

        }

//        if self.isCameraRecording {
//            self.stopRecording()
//        } else {
//            self.startRecording()
//        }
//        self.isCameraRecording = !self.isCameraRecording
    }

     func startRecording() {
         self.setup()
         if self.isCameraRecording {
                    self.stopRecording()
        }
        self.isCameraRecording = !self.isCameraRecording
        if self.assetWriter?.startWriting() != true {
            print("error: \(self.assetWriter?.error.debugDescription ?? "")")
        }

        self.videoOutput.setSampleBufferDelegate(self, queue: self.recordingQueue)
        self.audioOutput.setSampleBufferDelegate(self, queue: self.recordingQueue)

         
    }

    func stopRecording() {
        self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
        self.audioOutput.setSampleBufferDelegate(nil, queue: nil)

        self.assetWriter?.finishWriting { [weak self] in
            guard let self = self else { return }
            print("saved")
            if let assetWriter = self.assetWriter {
                self.delegate?.didFinishRecording(url: assetWriter.outputURL)
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
 {

        if !self.isRecordingSessionStarted {
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            self.assetWriter?.startSession(atSourceTime: presentationTime)
            self.isRecordingSessionStarted = true
        }

        let description = CMSampleBufferGetFormatDescription(sampleBuffer)!

        if CMFormatDescriptionGetMediaType(description) == kCMMediaType_Audio {
            if self.audioInput!.isReadyForMoreMediaData {
                print("appendSampleBuffer audio");
                self.audioInput?.append(sampleBuffer)
            }
        } else {
            if self.videoInput!.isReadyForMoreMediaData {
                print("appendSampleBuffer video");
                if !self.videoInput!.append(sampleBuffer) {
                    print("Error writing video buffer");
                }
            }
        }
    }
}
