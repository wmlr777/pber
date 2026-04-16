import SwiftUI

// MARK: - Second View
struct SportsGalleryView: View {
    @EnvironmentObject var dataManager: DataManager
    let bgColor = Color(hex: "070303")
    
    // 定义网格布局，一行 3 个灵活宽度的列
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        NavigationStack {
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

// MARK: - Sub Events View
struct SubEventsView: View {
    let bigEvent: BigEvent
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAlert = false
    
    let bgColor = Color(hex: "070303")
    
    // 获取当前 DataManager 中最新的 BigEvent 状态
    private var currentBigEvent: BigEvent? {
        dataManager.bigEvents.first(where: { $0.id == bigEvent.id })
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if let event = currentBigEvent {
                        ForEach(event.subEvents) { smallEvent in
                            let isSelected = smallEvent.isAdded
                            
                            HStack {
                                Text(smallEvent.name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .medium))
                                
                                Spacer()
                                
                                Button(action: {
                                    let success = dataManager.toggleAddedStatus(for: event.name, smallEventName: smallEvent.name)
                                    if !success && !isSelected {
                                        // 添加失败，说明达到上限
                                        showingAlert = true
                                    }
                                }) {
                                    Image(systemName: isSelected ? "minus" : "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                        .frame(width: 32, height: 32)
                                        .background(isSelected ? Color.red : Color.green)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(bigEvent.name + "项目")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("已达上限"),
                message: Text("TimeRecordsView 最多只能显示 10 个项目。"),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}

#Preview {
    SportsGalleryView()
        .environmentObject(DataManager())
}
