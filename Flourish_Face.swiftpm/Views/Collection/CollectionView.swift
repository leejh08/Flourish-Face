import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query(sort: \Flower.earnedDate, order: .reverse) private var flowers: [Flower]
    @State private var selectedFlower: Flower?
    @AppStorage(AppStorageKeys.selectedDifficulty) private var selectedDifficulty: String = Difficulty.basic.rawValue
    var newlyAddedFlowerType: Binding<FlowerType?> = .constant(nil)

    private var requiredExerciseCount: Int {
        let difficulty = Difficulty(rawValue: selectedDifficulty) ?? .basic
        return FaceExercise.exercises(for: difficulty).count
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private var groupedFlowers: [(flower: Flower, count: Int)] {
        let groups = Dictionary(grouping: flowers, by: { $0.type })
        return groups.map { (type, flowers) in
            let sorted = flowers.sorted(by: { $0.earnedDate > $1.earnedDate })
            return (flower: sorted[0], count: flowers.count)
        }.sorted(by: { $0.flower.earnedDate > $1.flower.earnedDate })
    }

    private var headerSubtitle: String {
        if flowers.isEmpty {
            return String(localized: "Your first flower is waiting")
        }

        return String.localizedStringWithFormat(
            String(localized: "%lld flowers collected"),
            flowers.count
        )
    }

    private var emptyStateDescription: String {
        String.localizedStringWithFormat(
            String(localized: "Complete all %lld exercises daily\nto earn flowers"),
            requiredExerciseCount
        )
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.bgPrimary, Color.bgSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Collection")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(headerSubtitle)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                if flowers.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "leaf")
                            .font(.system(size: 55))
                            .foregroundStyle(Color.primaryGreen)

                        Text("No flowers yet")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(emptyStateDescription)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(groupedFlowers, id: \.flower.type) { item in
                                let isNew = item.flower.type == newlyAddedFlowerType.wrappedValue
                                FlowerCard(
                                    flower: item.flower,
                                    count: item.count,
                                    isNew: isNew
                                )
                                .zIndex(isNew ? 1 : 0)
                                .onTapGesture {
                                    selectedFlower = item.flower
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .sheet(item: $selectedFlower) {
            flower in FlowerDetailView(flower: flower)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.bgPrimary)
        }
        .onChange(of: newlyAddedFlowerType.wrappedValue) { _, newValue in
            guard newValue != nil else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + Delay.uiTransition) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Delay.flowerHighlightDuration) {
                newlyAddedFlowerType.wrappedValue = nil
            }
        }
    }
}
