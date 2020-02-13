//
//  ListenSpeech.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 31/01/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import Foundation
import Speech
protocol ListenSpeechDelegate {
    func updateListenSpeechInterface(forRedyToRecord isReady: Bool)
}
class ListenSpeech {
    struct Memo {
        let memoTitle: String
        let memoDate: Date
        let memoText: String
    }
    var delegate: ListenSpeechDelegate?
    var memoData: [Memo] = [Memo]()
    //var isEnabled = true
    var isRecordEnabled = true
    var recordedMessage: String = ""

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private lazy var speechRecognizer: SFSpeechRecognizer? = nil
    var languageId: String  {
        get {    return Setup.languageId        }
    }
    var isEmpty : Bool {
        get {    return recordedMessage.count > 0   }
    }
    private lazy  var audioEngine: AVAudioEngine = {
           let audioEngine = AVAudioEngine()
           return audioEngine
       }()
    init() {
        self.requestAuth()
        memoData = []
    }
    private func setupSpeechRecognizer() ->  SFSpeechRecognizer? {
        if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: languageId)) {    return recognizer   }
        else {   return nil    }
    }
    private func requestAuth() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in   DispatchQueue.main.async {
                switch authStatus {
                    case .authorized:
                        print("authorized")
                    case .denied, .notDetermined, .restricted:
                         print("denied, notDetermined, restricted")
                    default :
                        print("EROR Listen speach")
                }
            }
        }
    }
     func didTapRecordButton() {
        self.speechRecognizer = setupSpeechRecognizer()
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            self.startRecording()
        }
        delegate?.updateListenSpeechInterface(forRedyToRecord: isRecordEnabled)
        isRecordEnabled.toggle()
    }
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)
            self.memoData.append(Memo(memoTitle: "Nowe nagranie", memoDate: Date(), memoText: self.recordedMessage))
        }
        self.speechRecognizer = nil
    }
    func startRecording() {
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        self.recordedMessage = ""
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        }catch {
            print(error)
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()             //   Unable to create a speech audio buffer
        guard let recognitionRequest = self.recognitionRequest else {    fatalError("Niemożliwe utworzenie bufora dźwięku")      }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if let result = result {
                let sentence = result.bestTranscription.formattedString
                self.recordedMessage = sentence
                isFinal = result.isFinal
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isRecordEnabled = true
            }
        })
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in   self.recognitionRequest?.append(buffer)  }
        audioEngine.prepare()
        do {    try audioEngine.start()   }
        catch {   print(error)     }
    }
// end start
}
