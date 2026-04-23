import SwiftUI

// MARK: - Skewed Rectangle Shape
struct SkewedRectangle: Shape {
    var offset: CGFloat = 4
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: offset, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var hourStr: String
    @Binding var minStr: String
    @Binding var secStr: String
    
    let onSave: () -> Void
    
    @State private var selectedHour: Int = 0
    @State private var selectedMin: Int = 0
    @State private var selectedSec: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Picker("Hours", selection: $selectedHour) {
                        ForEach(0..<100) { i in
                            Text(String(format: "%02d", i)).tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Text(":")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Picker("Minutes", selection: $selectedMin) {
                        ForEach(0..<60) { i in
                            Text(String(format: "%02d", i)).tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Text(":")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Picker("Seconds", selection: $selectedSec) {
                        ForEach(0..<60) { i in
                            Text(String(format: "%02d", i)).tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("选择时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确认") {
                        hourStr = selectedHour == 0 && selectedMin == 0 && selectedSec == 0 ? "" : String(format: "%02d", selectedHour)
                        minStr = selectedHour == 0 && selectedMin == 0 && selectedSec == 0 ? "" : String(format: "%02d", selectedMin)
                        secStr = selectedHour == 0 && selectedMin == 0 && selectedSec == 0 ? "" : String(format: "%02d", selectedSec)
                        onSave()
                        isPresented = false
                    }
                }
            }
            .onAppear {
                selectedHour = Int(hourStr) ?? 0
                selectedMin = Int(minStr) ?? 0
                selectedSec = Int(secStr) ?? 0
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Distance Time Row
struct DistanceTimeRow: View {
    let bigEventName: String
    let smallEvent: SmallEvent
    let boxWidth: CGFloat
    @Binding var swipedRowID: String?
    @ObservedObject var dataManager: DataManager
    
    @State private var hourStr: String = ""
    @State private var minStr: String = ""
    @State private var secStr: String = ""
    
    @State private var isPickerPresented: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    var isSelected: Bool { isPickerPresented }
    
    let textBoxColor = Color(hex: "F7F6E5")
    let textColor = Color.black
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete Background
            if dragOffset < 0 {
                SkewedRectangle(offset: 4)
                    .fill(Color.red)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("删除")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.trailing, 20)
                        }
                    )
                    .onTapGesture {
                        withAnimation {
                            _ = dataManager.toggleAddedStatus(for: bigEventName, smallEventName: smallEvent.name)
                        }
                    }
            }
            
            HStack(spacing: 10) {
                // Left Distance Box
                Text(smallEvent.name)
                    .font(.system(size: 14, weight: .bold))
                    .italic()
                    .foregroundColor(.black)
                    .frame(width: boxWidth, height: 36)
                    .background(
                        SkewedRectangle(offset: isSelected ? 0 : 4)
                            .fill(Color(hex: smallEvent.colorHex))
                            .overlay(
                                Group {
                                    if !isSelected {
                                        SkewedRectangle(offset: 4)
                                            .stroke(Color.white, lineWidth: 2)
                                    }
                                }
                            )
                    )
                
                // Right Editable Time Boxes inside a single long box
                HStack(spacing: 4) {
                    timeText(text: hourStr.isEmpty ? "--" : hourStr)
                    Text(":")
                        .foregroundColor(textColor)
                        .font(.system(size: 16, weight: .bold))
                    timeText(text: minStr.isEmpty ? "--" : minStr)
                    Text(":")
                        .foregroundColor(textColor)
                        .font(.system(size: 16, weight: .bold))
                    timeText(text: secStr.isEmpty ? "--" : secStr)
                }
                .padding(.horizontal, 24)
                // 将内容向右对齐，确保所有行的数字能在垂直方向上对齐
                .frame(maxWidth: .infinity, minHeight: 36, alignment: .trailing)
                .background(
                    SkewedRectangle(offset: isSelected ? 0 : 4)
                        .fill(textBoxColor)
                )
            }
            .overlay(
                Group {
                    if isSelected {
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                    }
                }
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .offset(x: dragOffset)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if swipedRowID != smallEvent.id {
                            swipedRowID = smallEvent.id
                        }
                        
                        let maxDrag: CGFloat = -100
                        if value.translation.width < 0 {
                            if isSwiped {
                                dragOffset = max(maxDrag, -80 + value.translation.width)
                            } else {
                                dragOffset = max(maxDrag, value.translation.width)
                            }
                        } else if value.translation.width > 0 {
                            if isSwiped {
                                dragOffset = -80 + value.translation.width
                                if dragOffset > 0 { dragOffset = 0 }
                            } else {
                                dragOffset = 0
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            if value.translation.width < -50 || dragOffset < -50 {
                                dragOffset = -80
                                isSwiped = true
                            } else {
                                dragOffset = 0
                                isSwiped = false
                                if swipedRowID == smallEvent.id {
                                    swipedRowID = nil
                                }
                            }
                        }
                    }
            )
            .onChange(of: swipedRowID) { newValue in
                if newValue != smallEvent.id {
                    withAnimation {
                        dragOffset = 0
                        isSwiped = false
                    }
                }
            }
            .onTapGesture {
                if isSwiped {
                    withAnimation {
                        dragOffset = 0
                        isSwiped = false
                        if swipedRowID == smallEvent.id {
                            swipedRowID = nil
                        }
                    }
                } else {
                    swipedRowID = nil
                    isPickerPresented = true
                }
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            TimePickerSheet(
                isPresented: $isPickerPresented,
                hourStr: $hourStr,
                minStr: $minStr,
                secStr: $secStr,
                onSave: save
            )
        }
        .onAppear {
            if let t = smallEvent.timeRecord, !t.isEmpty {
                hourStr = String(format: "%02d", t.hour)
                minStr = String(format: "%02d", t.minute)
                secStr = String(format: "%02d", t.second)
            }
        }
    }
    
    private func timeText(text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .frame(width: 32)
    }
    
    private func save() {
        if hourStr.isEmpty && minStr.isEmpty && secStr.isEmpty {
            dataManager.updateTimeRecord(for: bigEventName, smallEventName: smallEvent.name, record: nil)
        } else {
            let h = Int(hourStr) ?? 0
            let m = Int(minStr) ?? 0
            let s = Int(secStr) ?? 0
            let record = TimeRecord(hour: h, minute: m, second: s)
            dataManager.updateTimeRecord(for: bigEventName, smallEventName: smallEvent.name, record: record)
        }
    }
}

// MARK: - Time Records View
struct TimeRecordsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var swipedRowID: String? = nil
    
    // Colors
    let bgColor = Color(hex: "070303")
    let circleColor = Color(hex: "FFF6F6")
    
    // 获取已添加的小项目列表
    private var addedEvents: [(bigEventName: String, smallEvent: SmallEvent)] {
        var results: [(String, SmallEvent)] = []
        for bigEvent in dataManager.bigEvents {
            for smallEvent in bigEvent.subEvents where smallEvent.isAdded && smallEvent.recordFormat == .time_hms {
                results.append((bigEvent.name, smallEvent))
            }
        }
        return results
    }
    
    var body: some View {
        ZStack {
            // Background
            bgColor.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Top Left Circle
                Circle()
                    .fill(circleColor)
                    .frame(width: 40, height: 40)
                    .padding(.leading, 30)
                    .padding(.top, 16)
                
                ScrollView {
                    // Selected Distance Rows
                    VStack(spacing: 16) {
                        let events = addedEvents
                        ForEach(Array(events.enumerated()), id: \.element.smallEvent.id) { index, item in
                            // 根据索引自动计算宽度，第一项为 40，之后每项增加 5
                            let calculatedWidth: CGFloat = 40 + CGFloat(index) * 5
                            
                            DistanceTimeRow(
                                bigEventName: item.bigEventName,
                                smallEvent: item.smallEvent,
                                boxWidth: calculatedWidth,
                                swipedRowID: $swipedRowID,
                                dataManager: dataManager
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        // Dismiss keyboard when tapping background
        .onTapGesture {
            swipedRowID = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    TimeRecordsView()
        .environmentObject(DataManager())
}
