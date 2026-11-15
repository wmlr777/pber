import SwiftUI

struct AddDistanceSheet: View {
    @ObservedObject var vm: DashboardViewModel
    @Binding var isPresented: Bool
    @State private var isCustom = false
    @State private var customDistance: Double = 0.0
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("SELECT DISTANCE")
                .font(.headline)
                .padding()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(vm.presetDistances) { preset in
                    Button(action: {
                        if vm.records.contains(where: { $0.distanceStr == preset.distanceStr }) {
                            showAlert = true
                        } else {
                            let newRecord = Record(distance: preset.distance, distanceStr: preset.distanceStr, targetHours: 0, targetMinutes: 0, targetSeconds: 0, date: nil, colorHex: preset.colorHex)
                            vm.addRecord(newRecord)
                            isPresented = false
                        }
                    }) {
                        Text(preset.distanceStr)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: preset.colorHex))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    withAnimation { isCustom.toggle() }
                }) {
                    Text("Custom")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isCustom ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
            }
            .padding()
            
            if isCustom {
                VStack {
                    Text("Custom Distance: \(String(format: "%.1f", customDistance))k")
                    Slider(value: $customDistance, in: 0...50, step: 0.1)
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                Button("CANCEL") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "E98A8E"))
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("SAVE") {
                    if isCustom && customDistance > 0 {
                        if vm.records.contains(where: { $0.distance == customDistance }) {
                            showAlert = true
                        } else {
                            vm.addCustomRecord(distance: customDistance)
                            isPresented = false
                        }
                    } else {
                        isPresented = false
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "8BA68E"))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .presentationDetents([.height(isCustom ? 450 : 350)])
        .alert(isPresented: $showAlert) {
            Alert(title: Text("提示"), message: Text("请勿重复添加"), dismissButton: .default(Text("好的")))
        }
    }
}
