import SwiftUI

@main
struct Lucid: App {
    @StateObject private var menuBarModel = MenuBarModel()
    var body: some Scene {
        MainScene()

        MenuBarExtra(menuBarModel.countdown) {
            MenuBarView()
                .environmentObject(menuBarModel)
                .background(.clear)
        }
        .menuBarExtraStyle(.window)
    }
}
