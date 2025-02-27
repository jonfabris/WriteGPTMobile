//
//  ContentView.swift
//  WriteGPT
//
//  Created by Jon Fabris on 8/12/24.
//

import Foundation
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
  
    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 20)
                if(viewModel.selectedMode != .images) {
                    sampleView
                }
                Text("Prompt - prompt sent to chatGpt")
                TextEditor(text: $viewModel.promptText)
                    .disabled(viewModel.selectedMode != .freeform && viewModel.selectedMode != .images)
                    .frame(minHeight: 80)
                    .padding(0)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1))
            }
            Spacer().frame(width: 16)
            HStack {
                Button("Generate >") {
                    viewModel.generate()
                }
                SpinnerView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
            Spacer().frame(width: 4)
            HStack {
                Spacer()
                Text("Results")
                    .frame(minHeight: 80, maxHeight: 400)
                Spacer()
                Button(action: viewModel.clearResults) {
                    Image(systemName: "eraser")
                }
                .scaleEffect(0.8, anchor: .center)
            }
            .frame(height: 16)
            resultsView
        
            HStack {
                Text("Select Mode")
                Picker("", selection: $viewModel.selectedMode) {
                    ForEach(Mode.allCases) { option in
                        Text(option.rawValue)
                    }
                }
            }
            
            Spacer().frame(height: 16)
            
            switch viewModel.selectedMode {
            case .freeform:
                freeformView
            case .selections:
                selectionsView
            case .tasks:
                tasksView
            case .images:
                extrasView
            }
        }
        .padding(.all, 20)
        .navigationTitle("WriteGPT")
    }
    
    var sampleView: some View {
        VStack {
            Spacer().frame(height: 20)
            Text("Sample - enter the text to refine/evaluate")
            TextEditor(text: $viewModel.sourceText)
                .navigationTitle("WriteGPT")
                .padding(0)
                .frame(minHeight: 80)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1))
            Spacer().frame(height: 8)
        }
    }
    
    var resultsView: some View {
        Group {
            if viewModel.selectedMode == .images {
                if viewModel.generatedText.contains("http"),
                   let url = URL(string: viewModel.generatedText) {
                    TextEditor(text: $viewModel.generatedText)
                    ImageView(url: url)
                }
            }
            TextEditor(text: $viewModel.generatedText)
                .navigationTitle("WriteGPT")
                .padding(0)
                .frame(minHeight: 80, maxHeight: 400)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1))
            Spacer().frame(height: 16)
        }
    }
    
    var selectionsView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Writer")
                Picker("Writer", selection: $viewModel.selectedWriter) {
                    ForEach(viewModel.writers, id: \.self) { item in
                        Text(item)
                    }
                }
            }

            HStack {
                Text("Style")
                Picker("Style", selection: $viewModel.selectedStyle) {
                    ForEach(viewModel.styles, id: \.self) { item in
                        Text(item)
                    }
                }
            }

            VStack {
                ForEach($viewModel.selectedQualities) { $item in
                    Toggle(item.id, isOn: $item.selected)
                        .onChange(of: item.selected) {
                            print("toggled to \(item.selected)")
                        }
                }
            }
        }
        .padding()
        .border(.gray)
    }
    @State private var showingPicker = false
    var tasksView: some View {
        VStack(spacing: 10) {
            Picker("", selection: $viewModel.selectedTask) {
                ForEach(viewModel.specificTasks) { option in
                    Text(option.id).tag(option)
                }
            }
            .onChange(of: viewModel.selectedTask) { oldValue, newValue in
                viewModel.promptText = newValue.description
            }
        }
        .padding()
        .border(.gray)
    }
    
    var freeformView: some View {
        VStack {
            Text("Type prompt in the prompt field. Use [] to indicate where the sample text should be inserted.")
        }
        .padding()
        .border(.gray)
    }
    
    var extrasView: some View {
        VStack {
            Text("Type prompt in the prompt field to generate an image.")
        }
        .padding()
        .border(.gray)
    }

    func ImageView(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                SpinnerView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Text("Error loading image")
                    .foregroundColor(.red)
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            @unknown default:
                Text("Unknown state")
            }
        }
    }

}

#Preview {
    MainView(viewModel: MainViewModel())
}

struct SpinnerView: View {
  var body: some View {
    ProgressView()
      .progressViewStyle(CircularProgressViewStyle(tint: .blue))
      .scaleEffect(0.5, anchor: .center)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          // Simulates a delay in content loading
          // Perform transition to the next view here
        }
      }
  }
}



