import SwiftUI
import Combine

struct DashboardView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var vm = DashboardViewModel()
    @State private var selectedRecord: Record?
    @State private var showAddSheet = false
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Color(hex: "070303").ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Image(systemName: "figure.run")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Circle().fill(Color.white))
                    
                    Text("KEEP RUNNING")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    Spacer()
                }
                .padding()
                
                Divider().background(Color.gray)
                
                List {
                    ForEach(vm.records) { record in
                        ZStack {
                            if selectedRecord?.id != record.id {
                                RecordCardView(record: record)
                                    .matchedGeometryEffect(id: record.id, in: animation)
                            } else {
                                RecordCardView(record: record)
                                    .hidden()
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    vm.deleteRecord(record)
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedRecord = record
                            }
                        }
                    }
                    .onMove(perform: vm.moveRecord)
                }
                .listStyle(PlainListStyle())
            }
            
            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color(hex: "E98A8E")))
                            .shadow(radius: 4)
                    }
                    .padding(20)
                }
            }
            
            // Dimming layer
            if selectedRecord != nil {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedRecord = nil
                        }
                    }
                    .zIndex(1)
            }
            
            // Centered card
            if let record = selectedRecord {
                VStack {
                    Spacer()
                    RecordCardView(record: record)
                        .matchedGeometryEffect(id: record.id, in: animation)
                        .scaleEffect(1.05)
                        .shadow(color: Color.white.opacity(0.8), radius: 10)
                        .padding(.horizontal, 16)
                    Spacer()
                    Spacer().frame(height: 350)
                }
                .zIndex(2)
                
                // Custom Bottom Sheet
                VStack {
                    Spacer()
                    if let currentRecord = vm.records.first(where: { $0.id == record.id }) {
                        EditSheetView(record: currentRecord, selectedRecord: $selectedRecord, onSave: vm.updateRecord)
                            .padding(.bottom, 30)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .offset(y: 30)
                            .environment(\.colorScheme, .light)
                    }
                }
                .zIndex(3)
                .transition(.move(edge: .bottom))
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddDistanceSheet(vm: vm, isPresented: $showAddSheet)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                vm.refreshWidgetOnBackground()
            }
        }
    }
}

#Preview {
    DashboardView()
}
