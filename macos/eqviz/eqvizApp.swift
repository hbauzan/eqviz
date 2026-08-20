import SwiftUI

@main
struct EqvizApp: App {
    var body: some Scene {
        Window("eqviz", id: "main") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 240)
        .windowResizability(.contentMinSize)
    }
}
