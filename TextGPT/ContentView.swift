//
//  ContentView.swift
//  TextGPT
//
//  Created by Ivan Kvyatkovskiy on 24/03/2023.
//

import SwiftUI

struct ContentView: View {

    let observer = AccessibilityObserver()

    @State var text: String = "abc"

    var body: some View {
        VStack {
            Button("Open AccessabilityConfig") {
                 NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            TextField("text", text: $text)

        }
        .onAppear {
            let trusted = AXIsProcessTrusted()
            print("trusted:", trusted)
            observer.start()

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
