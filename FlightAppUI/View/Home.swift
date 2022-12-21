//
//  Home.swift
//  FlightAppUI
//
//  Created by Seungchul Ha on 2022/12/20.
//

import SwiftUI

struct Home: View {
    
    // MARK: View Bounds
    var size: CGSize
    var safeArea: EdgeInsets
    
    // MARK: Gesture Properties
    @State var offsetY: CGFloat = 0
    @State var currentCardIndex: CGFloat = 0
    
    // MARK: Animator State Object
    @StateObject var animator: Animator = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
                .overlay(alignment: .bottomTrailing, content: {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background {
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.35), radius: 5, x: 5, y: 5)
                        }
                }
                .offset(x: -15, y: 15)
                .offset(x: animator.startAnimation ? 80 : 0)
            })
                .zIndex(1)
            PaymentCardsView()
                .zIndex(0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(content: {
            ZStack {
                if animator.showLoadingView {
                    BackgroundView()
                        .transition(.scale)
                }
            }
        })
        .overlayPreferenceValue(RectKey.self, { value in
            if let anchor = value["PLANEBOUNDS"] {
                GeometryReader { proxy in
                    // MARK: Extracting Rect From Anchor Using GeometryReader
                    /// Why GeometryReader?
                    /// GeometryReader can be used to extract CGRect from the Anchor.
                    let rect = proxy[anchor]
                    let planeRect = animator.initialPlanePosition
                    Image("Airplane")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: planeRect.width, height: planeRect.height)
                        .offset(x: planeRect.minX, y: planeRect.minY)
                        /// Moving Plane a bit dow to look like its center when the 3D Animation is Happening
                        .offset(y: animator.startAnimation ? 50 : 0)
                        .onAppear {
                            animator.initialPlanePosition = rect
                        }
                }
            }
        })
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
    }
    
    // MARK: Top Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width * 0.4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                FlightDetailsView(place: "Los Angeles", code: "LAS", timing: "23 Nov, 03:30")
                
                VStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                    
                    Text("5h 15m")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                
                FlightDetailsView(alignment: .trailing, place: "New York", code: "NYC", timing: "23 Nov, 07:15")
            }
            .padding(.top, 20)
            
            // MARK: Airplane Image View
            Image("Airplane")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)
                /// Hiding the Original On
                .opacity(0)
                .anchorPreference(key: RectKey.self, value: .bounds, transform: { anchor in
                    return ["PLANEBOUNDS": anchor]
                })
                .padding(.bottom, -5)
            
        }
        .padding(15)
        .padding(.top, safeArea.top / 5)
        .background {
            Rectangle()
                .fill(.linearGradient(colors: [
                    Color("BlueBottom"),
                    Color("BlueBottom"),
                    Color("BlueTop"),
                ], startPoint: .top, endPoint: .bottom))
        }
        // MARK: Applying 3D Rotation : Header Will Disappeared
        .rotation3DEffect(.init(degrees: animator.startAnimation ? 90 : 0), axis: (x: 1, y: 0, z: 0), anchor: .init(x: 0.5, y: 0.8))
        .offset(y: animator.startAnimation ? -100 : 0)
    }
    
    // MARK: Credit Card View
    func PaymentCardsView() -> some View {
        VStack {
            Text("SELECT PAYMENT METHOD")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.vertical)
            
            GeometryReader { _ in
                VStack(spacing: 0) {
                    ForEach(sampleCards.indices, id: \.self) { index in
                        CardView(index: index)
                    }
                }
                .padding(.horizontal, 30)
                .offset(y: offsetY)
                .offset(y: currentCardIndex * -200.0)
                
                // MARK: Gradient View
                Rectangle()
                    .fill(.linearGradient(colors: [
                        .clear,
                        .clear,
                        .clear,
                        .clear,
                        .white.opacity(0.3),
                        .white.opacity(0.7),
                        .white
                    ], startPoint: .top, endPoint: .bottom))
                    // Why? .allowsHitTesting(false)
                    // Since the rectangle is an overlay view, it will prevent all interactions with the view below, so activating this modifier will entirely disable the rectangle's interaction
                    .allowsHitTesting(false)
                
                // MARK: Purchase Button
                Button(action: buyTicket){
                    Text("Confirm $1,536.00")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background {
                            Capsule()
                                .fill(Color("BlueTop").gradient)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, safeArea.bottom == 0 ? 15 : safeArea.bottom)
            }
            .coordinateSpace(name: "SCROLL")
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged({ value in
                    
                    // Decreasing Speed
                    offsetY = value.translation.height * 0.3
                })
                .onEnded({ value in
                    let translation = value.translation.height
                    withAnimation(.easeInOut) {
                        
                        // MARK: Increasing/Decreasing Index Based on Condition
                        // 100 -> Since Card Height = 200
                        if translation > 0 && translation > 100 && currentCardIndex > 0 {
                            currentCardIndex -= 1
                        }
                        
                        if translation < 0 && -translation > 100 && currentCardIndex < CGFloat(sampleCards.count - 1) {
                            currentCardIndex += 1
                        }
                        
                        offsetY = .zero
                    }
                })
        )
        .background {
            Color.white
                .ignoresSafeArea()
        }
        /// Applying 3D Rotation: Card Section
        .rotation3DEffect(.init(degrees: animator.startAnimation ? -90: 0), axis: (x: 1, y: 0, z: 0), anchor: .init(x: 0.5, y: 0.25))
        .offset(y: animator.startAnimation ? 100 : 0)
        
    }
    
    func buyTicket() {
        
        /// Animating Content
        withAnimation(.easeInOut(duration: 0.85)) {
            animator.startAnimation = true
        }
        
        /// Showing Loading View After Some time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animator.showLoadingView = true
        }
    }
    
    // MARK: Card View
    @ViewBuilder
    func CardView(index: Int) -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / size.height
            let constrainedProgress = progress > 1 ? 1 : progress < 0 ? 0 : progress
            
            Image(sampleCards[index].cardImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                // MARK: Shadow
                .shadow(color: .black.opacity(0.14), radius: 8, x: 6, y: 6)
                // MARK: Stacked Card Animation
                .rotation3DEffect(.init(degrees: constrainedProgress * 40.0), axis: (x: 1, y: 0, z: 0), anchor: .bottom )
                .padding(.top, progress * -160)
                // Moving Current Card to the Top
                .offset(y: progress < 0 ? progress * 250 : 0)
            
        }
        .frame(height: 200)
        .zIndex(Double(sampleCards.count - index))
        .onTapGesture {
            print(index)
        }
    }
    
    // MARK: Background Loading View with Ring Animations
    @ViewBuilder
    func BackgroundView() -> some View {
        VStack {
            /// Payment Status
            VStack(spacing: 0) {
                ForEach(PaymentStatus.allCases, id: \.rawValue) { status in
                    Text(status.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(height: 30)
                }
            }
            .offset(y: animator.currentPaymentStatus == .started ? -30 : animator.currentPaymentStatus == .finished ? -60 : 0)
            .frame(height: 30, alignment: .top)
            .clipped()
            .zIndex(1)
            
            ZStack {
                
                /// Ring 1
                Circle()
                    .fill(Color("BG"))
                    .shadow(color: .white.opacity(0.45), radius: 5, x: 5, y: 5)
                    .shadow(color: .white.opacity(0.45), radius: 5, x: -5, y: -5)
                    .scaleEffect(animator.ringAnimation[0] ? 5 : 1)
                    .opacity(animator.ringAnimation[0] ? 0 : 1)
                
                /// Ring 2
                Circle()
                    .fill(Color("BG"))
                    .shadow(color: .white.opacity(0.45), radius: 5, x: 5, y: 5)
                    .shadow(color: .white.opacity(0.45), radius: 5, x: -5, y: -5)
                    .scaleEffect(animator.ringAnimation[1] ? 5 : 1)
                    .opacity(animator.ringAnimation[1] ? 0 : 1)
                
                Circle()
                    .fill(Color("BG"))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                    .scaleEffect(1.22)
                
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                
                Image(systemName: animator.currentPaymentStatus.symbolImage)
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .frame(width: 80, height: 80)
            .padding(.top, 20)
            .zIndex(0)
        }
        // Using Timer to Stimulate Loading Effect
        .onReceive(Timer.publish(every: 2.3, on: .main, in: .common).autoconnect()) { _ in
            
            withAnimation(.easeInOut(duration: 0.3)) {
                if animator.currentPaymentStatus == .inititated {
                    animator.currentPaymentStatus = .started
                } else {
                    animator.currentPaymentStatus = .finished
                }
            }
        }
        .onAppear(perform: {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                animator.ringAnimation[0] = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    animator.ringAnimation[1] = true
                }
            }
        })
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, size.height * 0.15)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: ObservableObject that holds all animation properties
class Animator: ObservableObject {
    /// Animation Properties
    @Published var startAnimation: Bool = false
    
    /// Initial Plane position
    @Published var initialPlanePosition: CGRect = .zero
    
    @Published var currentPaymentStatus: PaymentStatus = .inititated
    
    /// Ring Status
    @Published var ringAnimation: [Bool] = [false, false]
    
    ///  Loading Status
    @Published var showLoadingView: Bool = false
}

// MARK: Anchor Preference Key
/// Sice the Flight Image rotates when 3D animation on Header is applied,
/// we must first detremine its precise location on the screen in order to add the same image as an overlay.
/// Using AnchorPreference, we can recover its precise location on the screen.
struct RectKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()){$1}
    }
}
