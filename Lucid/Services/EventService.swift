// EventService.swift
// Based on: https://www.woodys-findings.com/posts/programmatically-logout-a-user-in-swift/

import Carbon
import Foundation
import IOKit.pwr_mgt

enum EventService {}

// MARK: - Logic

extension EventService {
    static func send(event eventType: AppleEventType) throws {
        // target the login window process for the event
        var loginWindowSerialNumber = ProcessSerialNumber(
            highLongOfPSN: 0,
            lowLongOfPSN: UInt32(kSystemProcess)
        )

        var targetDesc = AEAddressDesc()
        var error = OSErr()

        error = AECreateDesc(
            keyProcessSerialNumber,
            &loginWindowSerialNumber,
            MemoryLayout<ProcessSerialNumber>.size,
            &targetDesc
        )

        if error != noErr {
            throw EventError(
                errorDescription: "Unable to create the description of the app. Status: \(error)"
            )
        }

        // create the Apple event
        var event = AppleEvent()
        error = AECreateAppleEvent(
            kCoreEventClass,
            eventType.eventId,
            &targetDesc,
            AEReturnID(kAutoGenerateReturnID),
            AETransactionID(kAnyTransactionID),
            &event
        )

        AEDisposeDesc(&targetDesc)

        if error != noErr {
            throw EventError(
                errorDescription: "Unable to create an Apple Event for the app description. Status:  \(error)"
            )
        }

        // send the event
        var reply = AppleEvent()
        let status = AESendMessage(
            &event,
            &reply,
            AESendMode(kAENoReply),
            1000
        )

        if status != noErr {
            throw EventError(
                errorDescription: "Error while sending the event \(eventType). Status: \(status)"
            )
        }

        AEDisposeDesc(&event)
        AEDisposeDesc(&reply)
    }

    static func Sleep() {
        // Put displays to sleep using IOKit
        _ = IOPMAssertionDeclareUserActivity(
            "Locking screen" as CFString,
            kIOPMUserActiveLocal,
            nil
        )

        // Sleep the displays
        _ = IOPMSleepSystem(IOPMFindPowerManagement(kIOMasterPortDefault))
    }
}

// MARK: - Models

extension EventService {
    enum AppleEventType {
        case shutdownComputer
        case restartComputer
        case putComputerToSleep
        case logoutUser

        var eventId: OSType {
            switch self {
            case .shutdownComputer: return kAEShutDown
            case .restartComputer: return kAERestart
            case .putComputerToSleep: return kAESleep
            case .logoutUser: return kAEReallyLogOut
            }
        }
    }

    struct EventError: LocalizedError {
        var errorDescription: String?
    }
}
