import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var dataManager = DataManager()
    let bgColor = Color(hex: "070303")
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $selectedTab) {
                    TimeRecordsView()
                        .tag(0)
                    SportsGalleryView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .environmentObject(dataManager)
                
                // Custom Bottom Tab Bar
                VStack(spacing: 0) {
                    // Horizontal Divider
                    Rectangle()
                        .fill(Color(hex: "333333")) // Dark gray divider
                        .frame(height: 1.5)
                    
                    ZStack {
                        HStack(spacing: 0) {
                            Spacer()
                            
                            Circle()
                                .fill(selectedTab == 0 ? Color.white : Color.black)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 0
                                    }
                                }
                            
                            Spacer()
                            
                            Circle()
                                .fill(selectedTab == 1 ? Color.white : Color.black)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 1
                                    }
                                }
                            
                            Spacer()
                        }
                        
                        // Vertical Divider
                        Rectangle()
                            .fill(Color(hex: "333333")) // Dark gray divider
                            .frame(width: 1.5, height: 24)
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 15)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
