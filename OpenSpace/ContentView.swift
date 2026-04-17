//
//  ContentView.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 16/04/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]

  var body: some View {
    NavigationViewWrapper {
      List {
        ForEach(items) { item in
          NavigationLink {
            Text(
              "Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))"
            )
            .foregroundStyle(ThemeColor.textPrimary)
          } label: {
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
              .foregroundStyle(ThemeColor.textPrimary)
          }
          .listRowBackground(ThemeColor.surface)
        }
        .onDelete(perform: deleteItems)
      }
      .scrollContentBackground(.hidden)
      .background(ThemeColor.backgroundPrimary)
      #if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      #endif
      .toolbar {
        #if os(iOS)
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
              .tint(ThemeColor.accent)
          }
        #endif
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
              .foregroundStyle(ThemeColor.accent)
          }
        }
      }
      .navigationTitle("OpenSpace")
      .foregroundStyle(ThemeColor.textPrimary)
    }
  }

  private func addItem() {
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

private struct NavigationViewWrapper<Content: View>: View {
  let content: () -> Content

  var body: some View {
    #if os(macOS)
      NavigationSplitView {
        content()
      } detail: {
        Text("Select an item")
          .foregroundStyle(ThemeColor.textSecondary)
      }
    #else
      content()
    #endif
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
    .openSpaceTheme()
}