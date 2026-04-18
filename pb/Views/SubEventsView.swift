import SwiftUI

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
                VStack(spacing: 24) {
                    if let event = currentBigEvent {
                        let addedEvents = event.subEvents.filter { $0.isAdded }
                        let unaddedEvents = event.subEvents.filter { !$0.isAdded }
                        
                        if !unaddedEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("未添加")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(unaddedEvents) { smallEvent in
                                    eventRow(for: smallEvent, in: event.name)
                                }
                            }
                        }
                        
                        if !addedEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("已添加")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(addedEvents) { smallEvent in
                                    eventRow(for: smallEvent, in: event.name)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(false)
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
    
    @ViewBuilder
    private func eventRow(for smallEvent: SmallEvent, in eventName: String) -> some View {
        let isSelected = smallEvent.isAdded
        
        HStack {
            Text(smallEvent.name)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Button(action: {
                let success = dataManager.toggleAddedStatus(for: eventName, smallEventName: smallEvent.name)
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
