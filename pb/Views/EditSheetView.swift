import SwiftUI

struct EditSheetView: View {
    let record: Record
    @Binding var selectedRecord: Record?
    let onSave: (Record) -> Void
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    var currentPace: String {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        if totalSeconds == 0 || record.distance == 0 {
            return "--"
        }
        let paceInSeconds = Double(totalSeconds) / record.distance
        let m = Int(paceInSeconds) / 60
        let s = Int(paceInSeconds) % 60
        return "\(m)' \(String(format: "%02d", s))\"/km"
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TARGET PACE:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(currentPace)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
                
                let df = DateFormatter()
                let _ = df.dateFormat = "yy-MM-dd"
                Button(action: { showDatePicker.toggle() }) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("SET TIME:")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text(df.string(from: selectedDate))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding()
            
            if showDatePicker {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            
            HStack {
                Picker("HOURS", selection: $hours) {
                    ForEach(0..<100) { i in Text("\(String(format: "%02d", i))").tag(i) }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("MINUTES", selection: $minutes) {
                    ForEach(0..<60) { i in Text("\(String(format: "%02d", i))").tag(i) }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("SECONDS", selection: $seconds) {
                    ForEach(0..<60) { i in Text("\(String(format: "%02d", i))").tag(i) }
                }.pickerStyle(WheelPickerStyle())
            }
            
            HStack {
                Button("Cancel") {
                    withAnimation(.spring()) {
                        selectedRecord = nil
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "E0E0E0"))
                .foregroundColor(.black)
                .cornerRadius(25)
                
                Button("Save Time") {
                    var updatedRecord = record
                    updatedRecord.timeInSeconds = hours * 3600 + minutes * 60 + seconds
                    updatedRecord.date = selectedDate
                    onSave(updatedRecord)
                    withAnimation(.spring()) {
                        selectedRecord = nil
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "1F2B49"))
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .padding()
        }
        .onAppear {
            hours = record.timeInSeconds / 3600
            minutes = (record.timeInSeconds % 3600) / 60
            seconds = record.timeInSeconds % 60
            if let d = record.date {
                selectedDate = d
            } else {
                selectedDate = Date()
            }
        }
    }
}
