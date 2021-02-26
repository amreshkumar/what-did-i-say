//
//  WDISListener.swift
//  WhatDidISay
//
//  Created by Amresh Kumar on 26/02/21.
//

import Foundation
import Speech

protocol WDISListenerDelegate: class {
    func didHear(sentence: String)
}

class WDISListener {
    
    private var speechRecognizer: SFSpeechRecognizer
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private weak var delegate: WDISListenerDelegate?
    
    var isListening: Bool {
        return audioEngine.isRunning
    }
    
    init(language: String = "hi", delegate: WDISListenerDelegate) {
        self.delegate = delegate
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))!
    }
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            print(authStatus)
        }
    }
    
    func listen() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = false
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil, let sentence = result?.bestTranscription.formattedString {
                self.delegate?.didHear(sentence: sentence)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
   
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

extension SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
}
