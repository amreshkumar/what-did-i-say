//
//  ViewController.swift
//  WhatDidISay
//
//  Created by Amresh Kumar on 25/02/21.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet private weak var speakButton: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "hi"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            print(authStatus)
        }
    }
    
    @IBAction func speakButtonPressed(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speakButton.setTitle("Listening", for: .normal)
        } else {
            startRecording()
            speakButton.setTitle("Tap to start again", for: .normal)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = false  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.speak(sentence: result?.bestTranscription.formattedString ?? "I got nothing")  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.speakButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speakButton.isEnabled = true
        } else {
            speakButton.isEnabled = false
        }
    }
    
    
    func speak(sentence: String, greetings: Bool = false) {
        
        let words = sentence.split(separator: " ")
        
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: words.joined(separator: " "))
        
        // Configure the utterance.
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1
        utterance.postUtteranceDelay = 0.5
        utterance.volume = 0.8
        
        let voice = AVSpeechSynthesisVoice(language: "hi")
        
        // Assign the voice to the utterance.
        utterance.voice = voice
        
        // Create a speech synthesizer.
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.pauseSpeaking(at: .immediate)
        
        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
}

