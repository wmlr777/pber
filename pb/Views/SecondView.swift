import SwiftUI

// MARK: - Second View
struct SecondView: View {
    let bgColor = Color(hex: "070303")
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            Text("第二页")
                .foregroundColor(.white)
                .font(.title)
        }
    }
}

#Preview {
    SecondView()
}
