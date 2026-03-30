import SwiftUI

struct SetPickerSheet: View {
    @Binding var selectedSets: Int
    let onStart: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Number of Sets")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Hold each expression for 4 seconds")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .padding(.top, 24)
            .padding(.bottom, 24)

            HStack(spacing: 32) {
                Button {
                    if selectedSets > 1 { selectedSets -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(selectedSets > 1 ? .primary : .tertiary)
                        .frame(width: 52, height: 52)
                        .background(
                            Circle()
                                .fill(Color(.systemGray5))
                        )
                }
                .accessibilityLabel("Decrease sets")
                .disabled(selectedSets <= 1)

                Text("\(selectedSets)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .frame(minWidth: 60)
                    .accessibilityLabel("\(selectedSets) sets")

                Button {
                    if selectedSets < 10 { selectedSets += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(selectedSets < 10 ? .primary : .tertiary)
                        .frame(width: 52, height: 52)
                        .background(
                            Circle()
                                .fill(Color(.systemGray5))
                        )
                }
                .accessibilityLabel("Increase sets")
                .disabled(selectedSets >= 10)
            }
            .padding(.bottom, 32)

            Button {
                onStart()
            } label: {
                Text("Start")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.primaryGreen)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(.clear)
    }
}

#Preview {
    SetPickerSheet(selectedSets: .constant(3), onStart: {})
}
