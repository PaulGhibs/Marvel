//
//  Home.swift
//  Marvel
//
//  Created by Paul Ghibeaux on 30/04/2021.
//

import SwiftUI

struct Home: View {
    init() {
           //Use this if NavigationBarTitle is with Large Font
           UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Avengero Disassembled", size: 20)!]

          
          
       }
    @StateObject var homeData = HomeViewModel()
    var body: some View {

        TabView{
            // characters view
            
            CharactersView().tabItem { Image(systemName: "person.3.fill")
                Text("Characters")
            }
            
            
            // setting environment object
            // so that we can access data on character view
            .environmentObject(homeData)
            ComicsView().tabItem {
                Image(systemName: "books.vertical.fill")

                Text("Comics")
                
            }
            .environmentObject(homeData)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
