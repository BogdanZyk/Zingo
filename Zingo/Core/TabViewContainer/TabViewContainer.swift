//
//  TabViewContainer.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

struct TabViewContainer: View {
    @StateObject private var userManager = CurrentUserManager()
    @EnvironmentObject var router: MainRouter
    init(){
        UITabBar.appearance().isHidden = true
    }
   
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $router.tab) {
                FeedView(currentUser: userManager.user)
                    .tag(Tab.home)
                Text("Search")
                    .tag(Tab.search)
                Text("Notification")
                    .tag(Tab.notification)
                CurrentUserProfileView(userManager: userManager)
                    .tag(Tab.profile)
            }
            tabView
        }
        .fullScreenCover(item: $router.fullScreen) { type in
            switch type{
            case .createNewPost:
                PostEditorView(currentUser: userManager.user)
            }
        }
        .notifyPopup(popup: $router.popup)
    }
}

struct TabViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        TabViewContainer()
            .environmentObject(MainRouter())
    }
}

extension TabViewContainer{
    
    
    private var tabView: some View{
        HStack{
            ForEach(Tab.allCases, id: \.self){ tab in
                tabItem(tab)
            }
        }
        .padding(.bottom)
        .padding(.top, 10)
        .background(Color.black)
    }
    
    private func tabItem(_ tab: Tab) -> some View{
        Group{
            if tab == .create{
                Button {
                    router.fullScreen = .createNewPost
                } label: {
                    Image(tab.image)
                        .padding()
                        .background(LinearGradient.primaryGradient, in: Circle())
                }
            }else{
                Image(tab.image)
                    .renderingMode(.template)
                    .foregroundColor(tab == router.tab ? .white : .lightGray)
                    .onTapGesture {
                        router.setTab(tab)
                    }
            }
        }
        .hCenter()
    }
}



