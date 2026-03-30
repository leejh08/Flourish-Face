import SwiftUI

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    @State private var particleTimer: Timer?

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .blur(radius: particle.blur)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                if particles.isEmpty {
                    for i in 0..<30 {
                        particles.append(Particle.random(id: i, in: size))
                    }
                }
                startParticleAnimation(in: size)
            }
            .onDisappear {
                particleTimer?.invalidate()
                particleTimer = nil
            }
        }
        .ignoresSafeArea()
    }

    private func startParticleAnimation(in size: CGSize) {
        particleTimer?.invalidate()
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                for i in particles.indices {
                    particles[i].y -= particles[i].speed
                    particles[i].x += sin(Date().timeIntervalSince1970 * particles[i].swaySpeed + particles[i].swayOffset) * 0.3
                    if particles[i].y < -50 {
                        var p = Particle.random(id: i, in: size)
                        p.y = size.height + 50
                        particles[i] = p
                    }
                }
            }
        }
    }
}

struct Particle: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var blur: CGFloat
    var speed: CGFloat
    var swaySpeed: Double
    var swayOffset: Double

    static func random(id: Int, in size: CGSize) -> Particle {
        let isBackground = Bool.random()

        return Particle(
            id: id,
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: -50...size.height + 50),
            size: CGFloat.random(in: 2...6),
            opacity: Double.random(in: 0.1...0.5),
            blur: isBackground ? CGFloat.random(in: 2...4) : 0,
            speed: CGFloat.random(in: 0.2...0.6),
            swaySpeed: Double.random(in: 0.5...1.5),
            swayOffset: Double.random(in: 0...10)
        )
    }
}
