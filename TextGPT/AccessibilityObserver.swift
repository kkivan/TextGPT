//
//  AccessibilityObserver.swift
//  TextGPT
//
//  Created by Ivan Kvyatkovskiy on 24/03/2023.
//

import Foundation
import AppKit
import ApplicationServices

import AXSwift

let privateKey = "PUT YOUR KEY HERE"

import OpenAISwift

@objc class AccessibilityObserver: NSObject {

    private var focusedUIElement: UIElement!

    var observer: Observer!
    var uiApp: Application!

    let recognizer = Recongnizer()

    let openAI = OpenAISwift(authToken: privateKey)

    func start() {
        setupActiveApplicationObserver()
    }

    func callChatGPT() {
        openAI.sendCompletion(with: "Hello how are you") { result in // Result<OpenAI, OpenAIError>
            switch result {
                case .success(let success):
                    print(success.choices.first?.text ?? "")
                case .failure(let failure):
                    print(failure.localizedDescription)
            }
        }
    }

    func setupActiveApplicationObserver() {
        // Register for notifications when the active application changes
        let workspaceNotificationCenter = NSWorkspace.shared.notificationCenter
        workspaceNotificationCenter.addObserver(self, selector: #selector(activeApplicationDidChange(notification:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    var currentText: String = ""
    @objc private func activeApplicationDidChange(notification: Notification) {
        // Get Active Application
        if let application = NSWorkspace.shared.frontmostApplication {
            NSLog("localizedName: \(String(describing: application.localizedName)), processIdentifier: \(application.processIdentifier)")

            uiApp = Application.allForBundleID(application.bundleIdentifier!).first!

            self.observer = uiApp.createObserver { observer, element, notification in
                switch notification {
                    case .focusedUIElementChanged:
                        self.focusedUIElement = element
                        self.currentText = (try? self.focusedUIElement.attribute(.value) as String?) ?? ""
                    case .valueChanged:
                        let text: String? = try? element.attribute(.value)
                        guard text != self.currentText else {
                            print("ignoring input")
                            return
                        }
                        if let request = text.flatMap(self.recognizer.recognizeRequest) {
                            print("making request:", request)
                            self.openAI.sendCompletion(with: request.request) { result in
                                switch result {
                                    case .success(let success):
                                        if let choice = success.choices.first?.text {
                                            print("got response:", choice)
                                            let fullText = request.textBefore + choice

                                            do {
                                                try element.setAttribute(.value, value: fullText)
                                            } catch {
                                                print("set", error)
                                            }
                                            self.currentText = fullText
                                        }
                                    case .failure(let failure):
                                        print(failure.localizedDescription)
                                }
                            }
                        }
                        print("text:", text)
                    default: break
                }
            }

            do {
                focusedUIElement = try uiApp.attribute(.focusedUIElement)
                let text: String? = try focusedUIElement?.attribute(.value)
                print("text:", text)
            } catch {
                print(error)
            }

            do {
                if let focusedUIElement {
                    try observer.addNotification(.focusedUIElementChanged, forElement: uiApp!)
                    try observer.addNotification(.valueChanged, forElement: focusedUIElement)
                }
            } catch {
                print(error)
            }

        }
    }
}
