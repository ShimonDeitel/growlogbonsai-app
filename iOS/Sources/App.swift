import SwiftUI

@main
struct GrowlogbonsaiApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.dark)
        }
    }
}
