import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var model: CategoriesViewModel
    var body: some View {
        NavigationStack {
            List {
                Section("Статьи") {
                    ForEach(model.filteredCategories) { category in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.backgroundGreen)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 22)
                                Text("\(category.emoji)")
                                    .font(.system(size: 11.5))
                            }
                            Text(category.name)
                        }
                    }
                }
            }
            .navigationTitle("Мои статьи")
            .task {
                await model.allCategories()
            }
        }
        .searchable(text: $model.searchText)
    }
}

#Preview {
    CategoriesView()
}
