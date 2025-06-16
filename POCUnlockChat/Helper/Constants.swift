//
//  Constants.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 15/06/25.
//

import Foundation

enum RecorderState {
    case readyToRecording
    case recording
    case recordingFinished
    case playing
    case paused
    case playbackFinished
}


enum TabType {
    case chats
    case pending
}

enum VoiceRecorderScreen {
    case cards
    case matches
}
