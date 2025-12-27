//
//  ContentView.swift
//  SpeakDaily
//
//  Created by 王震 on 2025/12/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootTabView()
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            PracticeView()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("练习")
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("历史")
                }
            SummaryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("总结")
                }
            MeView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
        }
        .tint(.blue)
    }
}

struct PracticeView: View {
    var body: some View {
        PracticeScreen()
    }
}

struct HistoryView: View {
    var body: some View {
        HistoryScreen()
    }
}

struct SummaryView: View {
    var body: some View {
        SummaryScreen()
    }
}

struct MeView: View {
    var body: some View {
        MeScreen()
    }
}

#Preview {
    RootTabView()
}
