import SwiftUI
import RickMortySwiftApi


struct CharactersView: View {
    @State private var characters: [RMCharacterModel] = []
    @State private var viewState: ViewState = .loading
    @State private var selectedCharacter: RMCharacterModel?
    @State private var isDetailViewActive = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAFBFC")
                    .ignoresSafeArea(.all)

                Group {
                    switch viewState {
                    case .loading:
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())

                    case .error(let message):
                        Text(message)
                            .foregroundColor(.red)
                            .padding()

                    case .success:
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(characters, id: \.id) { character in
                                    CharacterRow(character: character)
                                        .onTapGesture {
                                            navigateToDetailView(character: character)
                                        }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .refreshable {
                            await fetchCharacters()
                        }
                    }
                }
            }
            .navigationTitle("Characters")
            .task {
                await fetchCharacters()
            }
            .navigationDestination(isPresented: $isDetailViewActive) {
                if let character = selectedCharacter {
                    CharacterDetailsView(character: character)
                }
            }
        }
    }

    @MainActor
    private func fetchCharacters() async {
        let client = RMClient()
        viewState = .loading

        do {
            let apiCharacters: [RMCharacterModel] = try await client.character().getAllCharacters()
            print("Received characters: \(apiCharacters)")
            characters = apiCharacters
            viewState = .success
        } catch {
            print("Error fetching characters: \(error.localizedDescription)")
            viewState = .error(error.localizedDescription)
        }
    }

    private func navigateToDetailView(character: RMCharacterModel) {
        selectedCharacter = character
        isDetailViewActive = true
    }
}

struct CharacterRow: View {
    let character: RMCharacterModel

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 99, height: 99)
                        .cornerRadius(10)
                case .failure:
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 99, height: 99)
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(character.name)
                        .font(.headline)

                    Spacer()

                    Text(character.gender)
                        .padding(8)
                        .background(GenderUtils.genderBackgroundColor(gender: character.gender))
                        .foregroundColor(GenderUtils.genderTextColor(gender: character.gender))
                        .clipShape(Capsule())
                        .font(.system(size: 11, weight: .medium))
                }

                Text(character.species)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(13)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F1F6FB"), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}


#Preview {
    CharactersView()
}
