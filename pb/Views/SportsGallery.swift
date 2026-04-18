import SwiftUI

// MARK: - Second View
struct SportsGalleryView: View {
    @EnvironmentObject var dataManager: DataManager
    let bgColor = Color(hex: "070303")
    
    // 定义网格布局，一行 3 个灵活宽度的列
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(dataManager.bigEvents) { bigEvent in
                        if bigEvent.subEvents.isEmpty {
                            sportCell(for: bigEvent)
                        } else {
                            NavigationLink(destination: SubEventsView(bigEvent: bigEvent)) {
                                sportCell(for: bigEvent)
                            }
                        }
                    }
                }
                .padding()
            }
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    func sportCell(for event: BigEvent) -> some View {
        ZStack {
            // 使用 clear 颜色的矩形来撑满当前网格列的最大宽度
            Rectangle()
                .fill(Color.clear)
                .aspectRatio(1, contentMode: .fit)
            
            VStack(spacing: 8) {
                // 使用矢量图形(SF Symbols)替代文字
                Image(systemName: event.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                
                Text(event.name)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        // 添加 2px 的白色边框
        .overlay(
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
        )
    }
}

#Preview {
    SportsGalleryView()
        .environmentObject(DataManager())
}
