//
//  ContentView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = MainRouter()
    var body: some View {
        Group{
            if router.userSession == nil{
                LoginView()
            }else{
                TabViewContainer()
                    .environmentObject(router)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
