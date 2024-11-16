import SwiftUI
import RickMortySwiftApi

struct CharacterDetailsView: View {
    let character: RMCharacterModel
    @State private var episodeTitles: [String] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: character.image)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(13)
                } placeholder: {
                    ProgressView()
                }

                HStack {
                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(character.gender)
                        .padding(8)
                        .background(GenderUtils.genderBackgroundColor(gender: character.gender))
                        .foregroundColor(GenderUtils.genderTextColor(gender: character.gender))
                        .clipShape(Capsule())
                        .font(.system(size: 14, weight: .medium))

                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(characterProperties, id: \.key) { property in
                        PropertyRow(property: property)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Episodes:")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if isLoading {
                            ProgressView("Loading episodes...")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            if episodeTitles.isEmpty {
                                Text("No episodes found.")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                ForEach(episodeTitles, id: \.self) { title in
                                    Text(title)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(ColorManager.primaryText.opacity(0.5))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .navigationTitle(character.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await loadEpisodeTitles()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }

    private func loadEpisodeTitles() async {
        var titles: [String] = []
        
        for episodeURL in character.episode {
            do {
                let episode = try await RMEpisode(client: RMClient()).getEpisodeByURL(url: episodeURL)
                titles.append(episode.name)
            } catch {
                print("Failed to load episode at \(episodeURL): \(error.localizedDescription)")
            }
        }
        
        episodeTitles = titles
        isLoading = false
    }

    private var characterProperties: [(key: String, value: String)] {
        return [
            ("Species", character.species),
            ("Status", character.status),
            ("Origin", character.origin.name),
            ("Location", character.location.name)
        ]
    }
}

struct PropertyRow: View {
    var property: (key: String, value: String)

    var body: some View {
        HStack {
            Text("\(property.key):")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ColorManager.primaryText)
            Text(property.value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(ColorManager.primaryText.opacity(0.5))
        }
    }
}
