//
//  Speak.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 30/01/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import Foundation
import AVFoundation

class Speaking {
    private let synthesier = AVSpeechSynthesizer()
    var textToSpeach: String {
        didSet {
            if textToSpeach == "" {   stopSpeaking()     }
            else {   startSpeaking()       }
        }
    }
    var languageId: String  {
        get {
         return Setup.languageId
        }
    }
    init() {
        self.textToSpeach = ""
    }
    func startSpeaking() {
        let utterance = AVSpeechUtterance(string: textToSpeach) //contentToSpeac[selectedLanguage]
        utterance.voice = AVSpeechSynthesisVoice(language: languageId) // pl "en-GB" "en-US"
        synthesier.speak(utterance)
    }
    func stopSpeaking() {
        synthesier.stopSpeaking(at: .word)
    }
    func pauseSpeaking() {
       synthesier.pauseSpeaking(at: AVSpeechBoundary.immediate)
    }
    func continueSpeaking() {
        synthesier.continueSpeaking()
    }
    func printLanguageSpeakerName() {
        print("AVSpeechSynthesisVoice")
        for rek in AVSpeechSynthesisVoice.speechVoices() {
           print("\n\(rek)")
        }
    }
}
