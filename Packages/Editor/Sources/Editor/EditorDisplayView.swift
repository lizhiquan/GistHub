//
//  EditorDisplayView.swift
//  GistHub
//
//  Created by Khoa Le on 14/12/2022.
//

import SwiftUI
import Models
import DesignSystem
import Environment
import Markdown

public struct EditorDisplayView: View {
    @EnvironmentObject var userStore: UserStore
    @State var content: String = ""
    @State var fileName: String = ""
    let gist: Gist
    let language: File.Language
    let completion: () -> Void

    @State private var showEditorInEditMode = false
    @State private var showCodeSettings = false
    @State private var showConfirmDialog = false
    @State private var showSuccessToast = false
    @State private var showErrorToast = false
    @State private var error = ""

    @StateObject private var viewModel = EditorViewModel()
    @Environment(\.dismiss) private var dismiss

    public init(
        content: String,
        fileName: String,
        gist: Gist,
        language: File.Language,
        completion: @escaping () -> Void
    ) {
        _content = State(initialValue: content)
        _fileName = State(initialValue: fileName)
        self.gist = gist
        self.language = language
        self.completion = completion
    }

    public var body: some View {
        buildBodyView()
            .navigationTitle(fileName)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    makeBackButtonItem()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if gist.owner?.id == userStore.user.id {
                            Button {
                                showEditorInEditMode.toggle()
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }

                        Button {
                            showCodeSettings.toggle()
                        } label: {
                            Label("View Code Options", systemImage: "gear")
                        }

                        if gist.owner?.id == userStore.user.id {
                            Divider()
                            Button(role: .destructive) {
                                showConfirmDialog.toggle()
                            } label: {
                                Label("Delete File", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18))
                    }
                    .sheet(isPresented: $showEditorInEditMode) {
                        NavigationView {
                            EditorView(
                                style: .update,
                                fileName: fileName,
                                content: content,
                                language: language,
                                gist: gist
                            ) {
                                completion()
                            }
                        }
                    }
                    .sheet(isPresented: $showCodeSettings) {
                        NavigationView {
                            EditorCodeSettingsView()
                        }
                    }
                    .confirmationDialog(
                        "Are you sure you want to delete this file?",
                        isPresented: $showConfirmDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Delete File", role: .destructive) {
                            Task {
                                do {
                                    try await viewModel.deleteGist(gistID: gist.id, fileName: fileName) {
                                        showSuccessToast.toggle()
                                    }
                                } catch let updateError {
                                    error = updateError.localizedDescription
                                    showErrorToast.toggle()
                                }
                            }
                        }
                    }
                }
            }
            .toastSuccess(isPresenting: $showSuccessToast, title: "Deleted File") {
                self.completion()
                dismiss()
            }
            .toastError(isPresenting: $showErrorToast, error: error)
    }

    func buildBodyView() -> some View {
        Group {
            if language == .markdown {
                MarkdownUI(markdown: content)
            } else {
                EditorViewRepresentable(content: $content, language: language, isEditable: false)
            }
        }
    }

    private func makeBackButtonItem() -> some View {
        Button(action: { dismiss() }, label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18))
                .foregroundColor(Colors.accent.color)
        })
    }
}