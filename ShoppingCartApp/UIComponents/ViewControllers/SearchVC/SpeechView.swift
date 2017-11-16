//
//  SpeechView.swift
//  SpeechRecognizationDemo
//
//  Created by Vikash Kumar on 28/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import UIKit
import Speech

//MARK: - SpeechView
class SpeechView: UIView {
    @IBOutlet var circleView: UIView!
    @IBOutlet var lblStatus: UILabel!
    
    //Instace Variables
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "en_IN"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognizationTask:SFSpeechRecognitionTask?
    
    fileprivate var isRecording = false {
        didSet {
            setRecordingOnOFFStateUI()
        }
    }
    
    //GradientLayer for changing state of start button.
    var circleGredientLayer = CAGradientLayer()
    
    //Gredient colors sets.
    let speakingONColors = [UIColor(red: 229.0/255.0, green: 105.0/255.0, blue: 190.0/255.0, alpha: 1).cgColor,
                            UIColor(red: 224.0/255.0, green: 118.0/255.0, blue: 146.0/255.0, alpha: 1).cgColor]
    let speakingOFFColors = [UIColor.groupTableViewBackground.cgColor, UIColor.lightGray.cgColor]
    
    //Blocks for result and Error.
    var resultBlock: (String)->() = {_ in}
    var errorBlock: (Error)->() = {_ in}
    
    enum SpeechError: Error {
        case RecognizerNotAvailable
    }
    
    //AwakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        
    }
    
    //IBActions
    @IBAction func start_btnClicked(_ sender: Any?) {
        if isRecording {
            cancelRecording()
        } else {
            recognizeSpeech()
        }
        
    }
}

private typealias PrivateFunctions = SpeechView

//MARK:- Private functions
fileprivate extension PrivateFunctions {
    ///func for start speech recognization task.
    func recognizeSpeech() {
        guard let node = audioEngine.inputNode else {return}
        let recodingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recodingFormat) { (buffer, time) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
            errorBlock(error)
            return
        }
        
        guard let recognizer = SFSpeechRecognizer() else {
            //self.showAlert(message: "Speech Recognizer not available.")
            errorBlock(SpeechError.RecognizerNotAvailable)
            return
        }
        if !recognizer.isAvailable {
            errorBlock(SpeechError.RecognizerNotAvailable)
        }
        
        
        recognizationTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [unowned self](result, error) in
            if let result = result {
                let resultStr = result.bestTranscription.formattedString
                self.lblStatus.text = "Speaking..."
                self.resultBlock(resultStr)
            }
            if let error = error {
                self.isRecording = false
                self.cancelRecording()
                print(error.localizedDescription)
            }
        })
        isRecording = !isRecording

    }
    
    ///Cancel speech recording. It will stop the audioEngine and remove inputNode from audioEngine and cancel recognization Task.
    func cancelRecording() {
        audioEngine.stop()
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognizationTask?.cancel()
        isRecording = !isRecording

    }
    
    //Set Initial UI
    func setUI() {
        self.drawShadow(0.6, offSet: CGSize(width: 0, height: 0 ))
        circleGredientLayer = circleView.addGradient(with: speakingOFFColors)
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.clipsToBounds = true
    }
    
    //Set UI while changing recording state.
    func setRecordingOnOFFStateUI() {
        if isRecording {
            circleGredientLayer.colors = speakingONColors
            lblStatus.text = "Say Something..."
            
        } else {
            circleGredientLayer.colors = speakingOFFColors
            lblStatus.text = "Tapp on Mic"
        }
    }
    
    
}

//MARK: Public Functions
extension SpeechView {
    ///Request for Speech Authorization. Take the permission from users for using speech recognization.
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recognizeSpeech()
                case .denied: break
                //self.lblResult.text = "User denied access to speech recognition"
                case .restricted: break
                //self.lblResult.text = "Speech recognition restricted on this device"
                case .notDetermined: break
                    //self.lblResult.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
}

extension UIView {
    func addGradient(with colors:[CGColor])-> CAGradientLayer {
        let grLayer = CAGradientLayer()
        grLayer.frame = self.bounds
        grLayer.colors = colors
        self.layer.addSublayer(grLayer)
        return grLayer
    }
}
