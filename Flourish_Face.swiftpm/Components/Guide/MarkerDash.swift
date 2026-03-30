import SwiftUI

struct MarkerDash: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color.opacity(0.5))
            .frame(width: 20, height: 2)
    }
}
