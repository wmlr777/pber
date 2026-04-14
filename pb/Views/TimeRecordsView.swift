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

// MARK: - Distance Time Row
struct DistanceTimeRow: View {
    let distance: String
    let distanceColor: Color
    let boxWidth: CGFloat
    @ObservedObject var storageManager: TimeStorageManager
    
    @State private var hourStr: String = ""
    @State private var minStr: String = ""
    @State private var secStr: String = ""
    
    enum Field {
        case hour, min, sec
    }
    @FocusState private var focusedField: Field?
    var isSelected: Bool { focusedField != nil }
    
    let textBoxColor = Color(hex: "F7F6E5")
    let textColor = Color.black
    
    var body: some View {
        HStack(spacing: 10) {
            // Left Distance Box
            Text(distance)
                .font(.system(size: 14, weight: .bold))
                .italic()
                .foregroundColor(.black)
                .frame(width: boxWidth, height: 36)
                .background(
                    SkewedRectangle(offset: isSelected ? 0 : 4)
                        .fill(distanceColor)
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
                timeField(text: $hourStr, field: .hour)
                Text(":")
                    .foregroundColor(textColor)
                    .font(.system(size: 16, weight: .bold))
                timeField(text: $minStr, field: .min)
                Text(":")
                    .foregroundColor(textColor)
                    .font(.system(size: 16, weight: .bold))
                timeField(text: $secStr, field: .sec)
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
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            if focusedField == nil {
                focusedField = .hour
            }
        }
        .onAppear {
            if let t = storageManager.savedTimes[distance] {
                hourStr = String(format: "%02d", t.hour)
                minStr = String(format: "%02d", t.minute)
                secStr = String(format: "%02d", t.second)
            }
        }
        .onChange(of: hourStr) { _ in save() }
        .onChange(of: minStr) { _ in save() }
        .onChange(of: secStr) { _ in save() }
    }
    
    private func timeField(text: Binding<String>, field: Field) -> some View {
        TextField("--", text: text)
            .focused($focusedField, equals: field)
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .frame(width: 32)
    }
    
    private func save() {
        if hourStr.isEmpty && minStr.isEmpty && secStr.isEmpty {
            storageManager.removeTime(for: distance)
        } else {
            let h = Int(hourStr) ?? 0
            let m = Int(minStr) ?? 0
            let s = Int(secStr) ?? 0
            storageManager.saveTime(for: distance, hour: h, minute: m, second: s)
        }
    }
}

// MARK: - Time Records View
struct TimeRecordsView: View {
    @StateObject private var storageManager = TimeStorageManager()
    
    // Colors
    let bgColor = Color(hex: "070303")
    let circleColor = Color(hex: "FFF6F6")
    
    let distances: [(String, Color, CGFloat)] = [
        ("1k", Color(hex: "A0D585"), 40),
        ("5k", Color(hex: "F9F6C4"), 50),
        ("10k", Color(hex: "FE9EC7"), 60),
        ("21.0975k", Color(hex: "AACDDC"), 70),
        ("42.195k", Color(hex: "81A6C6"), 80)
    ]
    
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
                    .padding(.top, 20)
                
                // 5 Distance Rows
                VStack(spacing: 16) {
                    ForEach(distances, id: \.0) { item in
                        DistanceTimeRow(
                            distance: item.0,
                            distanceColor: item.1,
                            boxWidth: item.2,
                            storageManager: storageManager
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        // Dismiss keyboard when tapping background
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    TimeRecordsView()
}
