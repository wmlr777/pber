import SwiftUI

// MARK: - Distance Time Row
struct DistanceTimeRow: View {
    let distance: String
    let distanceColor: Color
    @ObservedObject var storageManager: TimeStorageManager
    
    @State private var hourStr: String = ""
    @State private var minStr: String = ""
    @State private var secStr: String = ""
    
    let textBoxColor = Color(hex: "F7F6E5")
    let textColor = Color.black
    
    var body: some View {
        HStack {
            // Left Distance Box
            Text(distance)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 80, height: 36)
                .background(distanceColor)
                .cornerRadius(8)
            
            Spacer()
            
            // Right Editable Time Boxes inside a single long box
            HStack(spacing: 4) {
                timeField(text: $hourStr)
                Text(":")
                    .foregroundColor(textColor)
                    .font(.system(size: 16, weight: .bold))
                timeField(text: $minStr)
                Text(":")
                    .foregroundColor(textColor)
                    .font(.system(size: 16, weight: .bold))
                timeField(text: $secStr)
            }
            .padding(.horizontal, 16)
            .frame(width: 250, height: 36)
            .background(textBoxColor)
            .cornerRadius(8)
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
    
    private func timeField(text: Binding<String>) -> some View {
        TextField("--", text: text)
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
    
    let distances = [
        ("1k", Color(hex: "A0D585")),
        ("5k", Color(hex: "F9F6C4")),
        ("10k", Color(hex: "FE9EC7")),
        ("21.0975k", Color(hex: "AACDDC")),
        ("42.195k", Color(hex: "81A6C6"))
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
