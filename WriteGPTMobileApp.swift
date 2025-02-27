//
//  WriteGPTMobileApp.swift
//  WriteGPTMobile
//
//  Created by Jon Fabris on 2/25/25.
//

import SwiftUI

@main
struct WriteGPTMobileApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewModel())
        }
    }
}
