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
        
        TabView(selection: $router.tab) {
            
            NavigationStack(path: $router.pathDestination.feed){
                FeedView(currentUser: userManager.user)
            }
            .tag(Tab.feed)
            
            NavigationStack(path: $router.pathDestination.search){
                Text("Search")
            }
            .tag(Tab.search)
            
            NavigationStack(path: $router.pathDestination.notification){
                Text("Notification")
            }
            .tag(Tab.notification)
            
            NavigationStack(path: $router.pathDestination.profile){
                CurrentUserProfileView(userManager: userManager)
            }
            .tag(Tab.profile)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            tabView
        }
        .notifyPopup(popup: $router.popup)
        .withFullScreenRouter(fullScreen: $router.fullScreen)
        .overlay {
            storyView
        }
    }
}

struct TabViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        TabViewContainer()
            .environmentObject(MainRouter())
    }
}

extension TabViewContainer{
    
    
    @ViewBuilder
    private var tabView: some View{
        if !router.hiddenTabView{
            HStack{
                ForEach(Tab.allCases, id: \.self){ tab in
                    tabItem(tab)
                }
            }
            .padding([.bottom, .top], 10)
            .background(Color.black)
        }
    }
    
    private func tabItem(_ tab: Tab) -> some View{
        Group{
            if tab == .create{
                Button {
                    router.setFullScreen(.createNewPost(userManager.user))
                } label: {
                    Image(tab.image)
                        .padding(12)
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
    
    @ViewBuilder
    var storyView: some View{
        if router.storyRouter.show{
            StoryView(close: $router.storyRouter.show, stories: router.storyRouter.stories)
                .transition(.move(edge: .bottom))
        }
    }
}



