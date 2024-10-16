import SwiftUI
import WebKit
import AVKit // Importing AVKit for video playback

@main
struct HoursOfPraiseApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView() // Launch the Splash Screen
        }
    }
}

// MARK: - SplashScreen for when the app is first loaded to be present
struct SplashScreenView: View {
    @State private var isActive = false // State variable to track if the splash screen is active
    @State private var logoOpacity = 0.0 // Opacity for the logo animation
    @State private var pulse = false // State variable for pulsing effect on the logo

    var body: some View {
        VStack {
            // Transition to the main page after the splash screen
            if isActive {
                MainPageView()
                    .transition(.move(edge: .leading)) // Transition effect
            } else {
                // Logo display with animation
                Image("hop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .opacity(logoOpacity) // Controlled by opacity
                    .scaleEffect(pulse ? 1.05 : 1.0) // Pulsing effect
                    .onAppear {
                        // Logo fade-in animation
                        withAnimation(.easeIn(duration: 2)) {
                            logoOpacity = 1.0
                        }
                        // Pulsing animation
                        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(2)) {
                            pulse = true
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea()) // Background color
        .onAppear {
            // Delay to switch to the main page
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

// Main view of the app with tab navigation
struct MainPageView: View {
    @State private var selectedTab = 0 // State variable to track the selected tab
    @State private var isShowingBarcodeScanner = false // State variable for barcode scanner visibility
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill") // Icon for Home tab
                    Text("Home") // Text for Home tab
                }
                .tag(0)
            
            ArchiveView()
                .tabItem {
                    Image(systemName: "archivebox.fill") // Icon for Archive tab
                    Text("Archive") // Text for Archive tab
                }
                .tag(1)
            
            DonateView()
                .tabItem {
                    Image(systemName: "heart.fill") // Icon for Donate tab
                    Text("Donate") // Text for Donate tab
                }
                .tag(2)
            
            // Barcode scanner view
            BarcodeScannerView(isShowing: $isShowingBarcodeScanner)
                .tabItem {
                    Image(systemName: "barcode.viewfinder") // Icon for Scan Ticket tab
                    Text("Scan Ticket") // Text for Scan Ticket tab
                }
                .tag(3)
        }
        .sheet(isPresented: $isShowingBarcodeScanner) {
            // Present the barcode scanner view
            BarcodeScannerView(isShowing: $isShowingBarcodeScanner)
        }
    }
}

// Custom color extension for gold
extension Color {
    static let gold = Color(red: 212/255, green: 175/255, blue: 55/255) // Gold color definition
}

// View for the home screen of the application
struct HomeView: View {
    @State private var player: AVPlayer?     // Define primary and secondary colors for the app
    let primaryColor = Color("Gold") // Gold color from asset catalog
    let secondaryColor = Color("DarkBlue") // Dark blue color from asset catalog
    
    @State private var timeRemaining: TimeInterval = 0 // State variable for remaining time until the event
    // Target date for the event
    let targetDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 18))!

    // Function to update the time remaining until the target date
    func updateTimeRemaining() {
        let now = Date() // Get current date and time
        timeRemaining = targetDate.timeIntervalSince(now) // Calculate time remaining
    }
    
    // Start the timer that updates the remaining time every second
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining() // Call the function to update time remaining
        }
    }
    
    // Array of Bible verses with explanations
    let bibleVerses = [
        ("John 3:16", "“For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.”", "This verse emphasizes the depth of God's love for humanity and the promise of eternal life through faith in Jesus Christ."),
        ("Psalm 23:1", "“The Lord is my shepherd; I shall not want.”", "This verse highlights the Lord's guidance and provision, ensuring that believers are cared for in all aspects of their lives."),
        ("Philippians 4:13", "“I can do all things through Christ who strengthens me.”", "This verse encourages believers to rely on Christ’s strength to overcome challenges and achieve their goals."),
        ("Isaiah 40:31", "“But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.”", "This verse assures that placing hope in the Lord results in renewed strength and perseverance."),
        ("Matthew 5:14", "“You are the light of the world. A town built on a hill cannot be hidden.”", "This verse calls believers to live in a way that reflects their faith, shining as a beacon to others."),
        ("Romans 8:28", "“And we know that in all things God works for the good of those who love him, who have been called according to his purpose.”", "This verse reassures that God orchestrates all circumstances for the benefit of those who love Him."),
        ("2 Corinthians 5:7", "“For we live by faith, not by sight.”", "This verse emphasizes the importance of trusting God’s plan, even when it’s not visible."),
        ("Hebrews 11:1", "“Now faith is confidence in what we hope for and assurance about what we do not see.”", "This verse defines faith as confident expectation and assurance in God’s promises."),
        ("James 1:5", "“If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault, and it will be given to you.”", "This verse encourages seeking wisdom from God, who is generous in providing it."),
    ]
    
    // Countdown view to display the remaining time until the event
    struct CountdownView: View {
        let eventDate: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 18))!
        
        @State private var timeRemaining: String = "" // State variable to hold the formatted remaining time
        
        var body: some View {
            VStack {
                Text(timeRemaining) // Display the remaining time
                    .font(.headline) // Headline font style
                    .foregroundColor(.gold) // Gold color for the text
                    .padding()
            }
            .onAppear(perform: updateCountdown) // Update countdown when the view appears
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                updateCountdown() // Update countdown every second
            }
        }
        
        // Function to update the countdown display
        private func updateCountdown() {
            let now = Date() // Get the current date
            let remainingTime = eventDate.timeIntervalSince(now) // Calculate remaining time
            
            // If there's remaining time, format it into days, hours, minutes, and seconds
            if remainingTime > 0 {
                let days = Int(remainingTime) / 86400
                let hours = (Int(remainingTime) % 86400) / 3600
                let minutes = (Int(remainingTime) % 3600) / 60
                let seconds = Int(remainingTime) % 60
                
                // Format the time remaining string
                timeRemaining = String(format: "%02d days, %02d hours, %02d minutes, %02d seconds", days, hours, minutes, seconds)
            } else {
                // If the event has started, update the text
                timeRemaining = "Event has started!"
            }
        }
    }
    
    var body: some View {
      
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let firstVerseIndex = dayOfYear % bibleVerses.count
        let secondVerseIndex = (firstVerseIndex + 1) % bibleVerses.count
        let firstVerse = bibleVerses[firstVerseIndex]
        let secondVerse = bibleVerses[secondVerseIndex]

        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Section
                    ZStack(alignment: .bottom) {
                        Image("hero")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()

                        VStack {
                            Text("Welcome to Hours of Praise App!")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(10)

                            NavigationLink(destination: LearnMoreView()) {
                                Text("Learn More")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 20)
                        }
                        .padding()
                    }

                    // Upcoming Events Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gold)

                            Text("Upcoming Events")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding(.bottom, 10)

                        HStack(alignment: .top, spacing: 15) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("A new concert is happening on January 18th, 2025! 🎉")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)

                                Divider().padding(.vertical, 10)

                                CountdownView()
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)

                    // Community Impact Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "globe.americas.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gold)

                            Text("Our Community Impact")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }

                        Text("We are proud to support Richard House Children's Hospice by providing vital resources and donations that directly impact children and families in need.")
                            .font(.body)
                            .foregroundColor(.black)
                            .padding(.bottom, 10)

                        VStack {
                                   // Video player showcasing community impact video
                                   if let player = player {
                                       VideoPlayer(player: player) // AVPlayer for video playback
                                           .frame(height: 200) // Fixed height for the video player
                                           .cornerRadius(10) // Rounded corners for the video player
                                           .shadow(radius: 5) // Shadow effect for depth
                                   } else {
                                       Text("Video is unavailable")
                                           .foregroundColor(.red)
                                   }
                               }
                               .onAppear {
                                   // Initialize the player when the view appears
                                   if let url = Bundle.main.url(forResource: "charity", withExtension: "mov") {
                                       player = AVPlayer(url: url) // Initialize player with the video URL
                                   } else {
                                       print("Error: charity.mov file not found in the bundle.")
                                   }
                               }

                        Text("Your support enables us to continue making a tangible difference in the lives of vulnerable children.")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)

                    // Featured Video Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "video.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gold)

                            Text("This Week's Featured Video")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }

                        WebView(url: URL(string: "https://www.youtube.com/embed/Su6KqAMxTlA")!)
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)

                    // Daily Bible Verses Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "book.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gold)

                            Text("Daily Bible Verses")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }

                        VStack(alignment: .leading, spacing: 15) {
                            ForEach([firstVerse, secondVerse], id: \.0) { verse in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(verse.0)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text(verse.1)
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Text(verse.2)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
        }
    }
}

// MARK: - YouTubeVideo Model
struct YouTubeVideo: Identifiable {
    let id = UUID() // Unique identifier for each video
    let title: String // Title of the YouTube video
    let videoID: String // YouTube video ID for embedding
    let year: String // Year the video was published
}

// MARK: - ArchiveView Structure
struct ArchiveView: View {
    @State private var selectedYear: String = "All"

    let videos = [
        YouTubeVideo(title: "Hours of Praise 2024", videoID: "Su6KqAMxTlA", year: "2024"),
        YouTubeVideo(title: "Hours of Praise 2023", videoID: "fJ0FGclDuM8", year: "2023"),
        YouTubeVideo(title: "Hours of Praise 2022", videoID: "1JwUyCOh1IM", year: "2022"),
        YouTubeVideo(title: "Hours of Praise 2021", videoID: "cPERdeKRfFI", year: "2021"),
        YouTubeVideo(title: "Hours of Praise 2020", videoID: "BvKpxXxkcG8", year: "2020"),
        YouTubeVideo(title: "Hours of Praise 2019", videoID: "ZGe9_Rr-lwk", year: "2019"),
        YouTubeVideo(title: "Hours of Praise 2018", videoID: "1oBzy3K7mtI", year: "2018")
    ]

    var filteredVideos: [YouTubeVideo] {
        if selectedYear == "All" {
            return videos
        } else {
            return videos.filter { $0.year == selectedYear }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Text("Welcome to the Archive TV! 🎬")
                        .foregroundColor(.gold)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    Spacer()
                }

                Text("Here, you can catch up on all the Hours of Praise live videos & key clips from past years, all in one place.")
                    .font(.body)
                    .padding(.horizontal)

                Picker("Select Year", selection: $selectedYear) {
                    Text("All").tag("All")
                    ForEach(Array(Set(videos.map { $0.year })).sorted(by: >), id: \.self) { year in
                        Text(year).tag(year)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                ForEach(filteredVideos) { video in
                    VStack(alignment: .leading) {
                        Text("\(video.title) - \(video.year)")
                            .font(.headline)
                            .padding(.bottom, 5)

                        ZStack {
                            YouTubeVideoView(videoID: video.videoID)
                                .frame(height: 200)
                                .cornerRadius(12)
                                .shadow(radius: 4)

                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .opacity(0.7)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Archive")
    }
}

// MARK: - YouTubeVideoView Structure
struct YouTubeVideoView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: "https://www.youtube.com/embed/\(videoID)") {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

// MARK: - DonateView Page Structure
struct DonateView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Support Hours of Praise")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gold)
                    .padding(.top, 20)

                Text("Become a Partner")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.bottom, 5)

                Text("Your donations support our Christian concerts and community outreach programs.")
                    .font(.body)
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.leading)

                DonationSection(title: "One-Off Donation", description: "Make a one-time contribution to help us organize our upcoming 'Hours of Praise' concert.", imageName: "oneoff")

                DonationSection(title: "Monthly Subscription Donation", description: "Become a long-term partner by subscribing to a monthly donation plan.", imageName: "subscription")

                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 5)
            .navigationTitle("Donate")
        }
        .padding()
    }
}

// Custom View for Donation Section
struct DonationSection: View {
    var title: String
    var description: String
    var imageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gold)

            Text(description)
                .font(.body)
                .padding(.bottom, 5)
                .multilineTextAlignment(.leading)

            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
        .padding(.bottom, 20)
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// MARK: - BarcodeScannerView
struct BarcodeScannerView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Your Tickets for Event Access")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            Text("Tickets for our concert on January 18th, 2025, will be available soon on Eventbrite.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Once tickets are released, you will be able to scan your tickets for seamless access to the event.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                isShowing = false
            }) {
                Text("Close")
                    .fontWeight(.semibold)
                    .foregroundColor(.gold)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Ticket Access")
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - WebView
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

// MARK: - LearnMoreView
struct LearnMoreView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image("hop")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal)

                Text("About Hours of Praise")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .foregroundColor(.primary)

                Text("""
                    Hours of Praise is a unique Christian worship experience that unites believers from diverse backgrounds. This annual event celebrates the goodness and faithfulness of God through heartfelt worship, dynamic praise, and uplifting music.
                    """)
                    .font(.body)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)

                Divider().padding(.horizontal)

                Text("What to Expect")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .foregroundColor(.primary)

                Text("""
                    The event fosters a powerful atmosphere of worship, allowing attendees to connect with God, find encouragement, and be inspired. Featuring performances from talented gospel artists, the event promises uplifting messages, contemporary Christian music, and moments of deep reflection.
                    """)
                    .font(.body)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)

                Divider().padding(.horizontal)

                Text("Upcoming Concert Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .foregroundColor(.primary)

                Text("""
                    Join us on January 18th, 2025, for an incredible worship and praise experience.
                    """)
                    .font(.body)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)

                Divider().padding(.horizontal)

                Text("Join Us")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .foregroundColor(.primary)

                Text("""
                    Hours of Praise offers a unique opportunity to immerse yourself in worship, connect with others, and experience the transformative power of music and praise.
                    """)
                    .font(.body)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Learn More")
    }
}

