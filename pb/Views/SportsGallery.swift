import SwiftUI

// MARK: - Second View
struct SecondView: View {
    let bgColor = Color(hex: "070303")
    
    // 10 个体育项目及其对应的 SF Symbols 矢量图形
    let sports: [(name: String, icon: String)] = [
        ("跑步", "figure.run"),
        ("游泳", "figure.pool.swim"),
        ("篮球", "basketball"),
        ("足球", "soccerball"),
        ("羽毛球", "figure.badminton"),
        ("网球", "figure.tennis"),
        ("排球", "volleyball"),
        ("乒乓球", "figure.table.tennis"),
        ("自行车", "bicycle"),
        ("滑雪", "figure.skiing.downhill")
    ]
    
    // 定义网格布局，一行 3 个灵活宽度的列
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<sports.count, id: \.self) { index in
                        ZStack {
                            // 使用 clear 颜色的矩形来撑满当前网格列的最大宽度
                            Rectangle()
                                .fill(Color.clear)
                                .aspectRatio(1, contentMode: .fit)
                            
                            VStack(spacing: 8) {
                                // 使用矢量图形(SF Symbols)替代文字
                                Image(systemName: sports[index].icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                
                                Text(sports[index].name)
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
                .padding()
            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    SecondView()
}
