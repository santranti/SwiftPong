//
//  AppDelegate.swift
//  Pong
//
//  Created by Federico Calabró on 17/10/23.
//


import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let mainWindow = NSApplication.shared.mainWindow {
            mainWindow.acceptsMouseMovedEvents = true
        }

    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}
