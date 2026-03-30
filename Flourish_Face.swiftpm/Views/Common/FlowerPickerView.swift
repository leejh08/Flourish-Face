import SwiftUI
import SwiftData

struct FlowerPickerView: View {
    let onPick: (FlowerType) -> Void

    @Query private var collectedFlowers: [Flower]
    @State private var options: [FlowerType] = []
    @State private var selectedIndex: Int? = nil
    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(.yellow)
                        .accessibilityHidden(true)

                    Text("Pick Your Flower!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Choose one to add to your collection")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .accessibilityElement(children: .combine)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                HStack(spacing: 16) {
                    ForEach(Array(options.enumerated()), id: \.element) { index, flower in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedIndex = index
                            }
                        } label: {
                            FlowerOptionCard(
                                flower: flower,
                                isSelected: selectedIndex == index
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)

                Spacer()

                Button {
                    if let index = selectedIndex {
                        onPick(options[index])
                    }
                } label: {
                    Text("Collect")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedIndex != nil
                                    ? LinearGradient(colors: [Color.accentPink, Color.accentPurple], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                        )
                }
                .disabled(selectedIndex == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .accessibilityAddTraits(.isModal)
        .onAppear {
            let collectedTypes = Set(collectedFlowers.map { $0.type })
            options = FlowerType.randomSelection(excluding: collectedTypes)
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showContent = true
            }
        }
    }
}
