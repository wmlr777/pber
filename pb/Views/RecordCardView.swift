import SwiftUI

struct RecordCardView: View {
    let record: Record
    
    var body: some View {
        HStack(spacing: 0) {
            // Left color block
            Text(record.distanceStr)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
                .padding(.trailing, 30) // Extra padding for the skew
                .frame(maxHeight: .infinity, alignment: .leading)
                .background(
                    RightSkewedShape(offset: 20)
                        .fill(Color(hex: record.colorHex))
                )
                .zIndex(1) // Ensure it draws over the right side if needed, or right side underlaps
            
            // Right info block
            ZStack {
                Color.clear
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        let h = record.timeInSeconds / 3600
                        let m = (record.timeInSeconds % 3600) / 60
                        let s = record.timeInSeconds % 60
                        
                        TimeBox(val: h == 0 ? "--" : String(format: "%02d", h))
                        Text(":")
                        TimeBox(val: m == 0 && h == 0 ? "--" : String(format: "%02d", m))
                        Text(":")
                        TimeBox(val: s == 0 && m == 0 && h == 0 ? "--" : String(format: "%02d", s))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Text(record.formattedPace)
                            .foregroundColor(Color(hex: record.colorHex))
                            .font(.caption)
                            .fontWeight(.bold)
                        Spacer()
                        
                        if let date = record.date {
                            let df = DateFormatter()
                            let _ = df.dateFormat = "yyyy.MM.dd"
                            Text(df.string(from: date))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        } else {
                            Text("YY.MM.DD")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 5)
                }
                .padding(.vertical, 10)
            }
        }
        .background(Color(hex: "DCDCDC"))
        .cornerRadius(8)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct TimeBox: View {
    let val: String
    var body: some View {
        Text(val)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: 30, height: 30)
            .background(RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.3)))
    }
}
