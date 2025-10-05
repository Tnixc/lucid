import Foundation
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isSettingsWindowFocused: Bool = false
    @Published var isOverlayActive: Bool = false

    private init() {}
}
