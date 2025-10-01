import Foundation
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isSettingsWindowOpen: Bool = false

    private init() {}
}
