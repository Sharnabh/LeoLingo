import SwiftUI

struct WordCardView: View {
    let word: String
    let accuracy: Double  // This is now the average accuracy
    let attempts: String
    let isSelected: Bool
    
    private let circleColor = Color(hex: "EED362") // #ECCC4399
    
    var body: some View {
        VStack(spacing: 4) {
            // Circular progress indicator
            ZStack {
                Circle()
                    .fill(circleColor)  // Fill the circle with #ECCC4399
                    .frame(width: 100, height: 100)
                    .shadow(
                        color: Color.black.opacity(0.50),
                        radius: 3,
                        x: 1,
                        y: 3
                    )
                
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 5)
                    .frame(width: 100, height: 100)
                Circle()
                    .trim(from: 0, to: accuracy/100)
                    .stroke(
                        accuracy >= 70 ? Color.green : Color.red,
                        lineWidth: 5
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                DonutTextView(value: word, size: 80)
                    .foregroundColor(Color(red: 135/255, green: 89/255, blue: 65/255))
            }
            
            HStack(spacing: 4) {
                Text("Accuracy")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 83/255, green: 88/255, blue: 95/255))
                Text("\(String(format: "%.1f", accuracy))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 83/255, green: 88/255, blue: 95/255))
            }
            
            HStack(spacing: 4) {
                Text("Attempts")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 83/255, green: 88/255, blue: 95/255))
                
                Text("\(attempts)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 83/255, green: 88/255, blue: 95/255))
            }.frame(alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(isSelected ? Color(hex: "FCF2C0") : Color.white)
                .frame(width: 160, height: 155)
                .shadow(
                    color: Color.black.opacity(0.26),
                    radius: 5,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
}

struct DonutTextView: View {
    let value: String
    let size: CGFloat
    
    var body: some View {
        Text(value)
            .font(.system(size: 24, weight: .semibold))
            .minimumScaleFactor(0.1)  // Allow text to shrink down to 10% of original size
            .lineLimit(1)
            .frame(width: size * 0.7)  // Constrain width to 70% of donut size
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        WordCardView(
            word: "Example",
            accuracy: 85,
            attempts: "3",
            isSelected: true
        )
        .padding()
    }
}
