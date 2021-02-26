//
//  ViewController.swift
//  WhatDidISay
//
//  Created by Amresh Kumar on 25/02/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var speakButton: UIButton!
        
    private var listener: WDISListener?
    private var speaker: WDISSpeaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listener = WDISListener(delegate: self)
        speaker = WDISSpeaker()
        
        listener?.requestPermissions()
    }
    
    @IBAction func speakButtonPressed(_ sender: AnyObject) {
        if let listener = listener, listener.isListening {
            listener.stopListening()
            speakButton.setTitle("Stopped listening.", for: .normal)
        } else {
            listener?.listen()
            speakButton.setTitle("Listening", for: .normal)
        }
    }
}

extension ViewController: WDISListenerDelegate {
    func didHear(sentence: String) {
        speaker?.speak(sentence: sentence)
    }
}
