//
//  WDISSpeaker.swift
//  WhatDidISay
//
//  Created by Amresh Kumar on 26/02/21.
//

import Foundation
import AVFoundation

class WDISSpeaker {
    
    private let language: String
    
    private var speechSynthesizer: AVSpeechSynthesizer {
        let _synth = AVSpeechSynthesizer()
        _synth.pauseSpeaking(at: .word)
        return _synth
    }
    
    // TODO: Voices can be made available all the time
    private var voice: AVSpeechSynthesisVoice? {
        let voice = AVSpeechSynthesisVoice(language: language)
        return voice
    }
    
    init(language: String = "hi") {
        self.language = language
    }
    
    func speak(sentence: String) {
        let utterance = AVSpeechUtterance(string: sentence)
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1
        utterance.postUtteranceDelay = 0.5
        utterance.volume = 0.8
        utterance.voice = voice
        
        speechSynthesizer.speak(utterance)
    }

}
