// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

/// Ask the user for feedback
public struct SendFeedbackView: View {
    let requestId: String?
    let geoLocationStatus: String?
    let initialText: String
    let onDismiss: (() -> Void)?
    let screenshot: UIImage?
    let query: String?
    let debugInfo: String?
    let onFeedbackSend: (FeedbackRequest) -> Void

    /// - Parameters:
    ///   - screenshot: A screenshot image that the user may optionally send along with the text
    ///   - onDismiss: If provided, this will be called when the user wants to dismiss the feedback screen. Useful when presenting from UIKit, where `presentationMode.wrappedValue.dismiss()` has no effect
    ///   - canShareResults: if `true`, display a “Share my query to help improve Neeva” toggle
    ///   - requestId: A request ID to send along with the user-provided feedback
    ///   - geoLocationStatus: passed along to the API
    ///   - initialText: Text to pre-fill the feedback input with. If non-empty, the user can submit feedback without entering any additional text.
    ///   - debugInfo: A String appended to the end of the feedback with any info that could be useful in fixing issues (i.e. TabStats).
    public init(
        screenshot: UIImage?, url: URL?, onDismiss: (() -> Void)? = nil, requestId: String? = nil,
        query: String? = nil, geoLocationStatus: String? = nil, initialText: String = "",
        debugInfo: String? = nil, onFeedbackSend: @escaping (FeedbackRequest) -> Void
    ) {
        self.screenshot = screenshot
        self._url = .init(initialValue: url)
        self.requestId = requestId
        self.geoLocationStatus = geoLocationStatus
        self.onDismiss = onDismiss
        self._feedbackText = .init(initialValue: initialText)
        self.initialText = initialText
        self._editedScreenshot = .init(initialValue: screenshot ?? UIImage())
        self.query = query
        self.debugInfo = debugInfo
        self.onFeedbackSend = onFeedbackSend
    }

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onOpenURL) var onOpenURL

    @State var url: URL?
    @State var email = ""
    @State var feedbackText = ""
    @State var shareURL = true
    @State var isEditingURL = false
    @State var shareScreenshot = true
    @State var screenshotSheet = ModalState()
    @State var editedScreenshot: UIImage
    @State var shareQuery = true
    @State var emailFieldIsFocused = false
    @State var descriptionFieldIsFocused = true

    public var body: some View {
        NavigationView {
            ScrollView {
                GroupedStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Need help or want instant answers to FAQs?")
                                .withFont(.bodyLarge)
                                .foregroundColor(.label)
                            Button(action: {
                                onOpenURL(NeevaConstants.appFAQURL)
                                if let onDismiss = onDismiss {
                                    onDismiss()
                                }
                            }) {
                                Text("Visit our Help Center!").underline()
                                    .withFont(.bodyLarge)
                            }
                        }
                        .font(.body)
                        Spacer()
                    }

                    VStack(spacing: 8) {
                        GroupedCell(alignment: .leading) {
                            ZStack(alignment: .topLeading) {
                                let descriptionInputMode =
                                    descriptionFieldIsFocused || !feedbackText.isEmpty
                                Text("Description")
                                    .withFont(
                                        descriptionInputMode ? .headingXSmall : .bodyLarge
                                    )
                                    .foregroundColor(
                                        descriptionInputMode
                                            ? .secondaryLabel
                                            : Color(UIColor.placeholderText)
                                    )
                                    .padding(.vertical, descriptionInputMode ? 12 : 19.5)
                                    .onTapGesture {
                                        descriptionFieldIsFocused = true
                                    }
                                if descriptionInputMode {
                                    MultilineTextField(
                                        "Please share your questions, issues, or feature requests. Your feedback helps us improve Neeva!",
                                        text: $feedbackText,
                                        focusTextField: true
                                    )
                                    .withFont(unkerned: .bodyLarge)
                                    .padding(.top, 18)
                                    .padding(.leading, -4)
                                    .onTapGesture {
                                        descriptionFieldIsFocused = true
                                    }
                                }
                            }
                            .animation(.default)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.brand.blue, lineWidth: 1)
                                .opacity(descriptionFieldIsFocused ? 1 : 0)
                        )

                        if !NeevaUserInfo.shared.isUserLoggedIn {
                            GroupedCell {
                                ZStack(alignment: .topLeading) {
                                    let emailInputMode = emailFieldIsFocused || !email.isEmpty
                                    if emailInputMode {
                                        Text("Email")
                                            .withFont(.headingXSmall)
                                            .foregroundColor(.secondaryLabel)
                                            .padding(.top, 12)
                                    }
                                    TextField(
                                        emailFieldIsFocused ? "example@neeva.com" : "Email",
                                        text: $email,
                                        onEditingChanged: { editingChanged in
                                            emailFieldIsFocused = editingChanged
                                            descriptionFieldIsFocused = !emailFieldIsFocused
                                        }
                                    )
                                    .withFont(unkerned: .bodyLarge)
                                    .autocapitalization(.none)
                                    .padding(.top, emailInputMode ? 26 : 19.5)
                                    .padding(.bottom, emailInputMode ? 12 : 19.5)
                                }
                                .animation(.default)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.brand.blue, lineWidth: 1)
                                    .opacity(emailFieldIsFocused ? 1 : 0)
                            )
                        }
                    }
                    .padding(.vertical, 12)

                    VStack(spacing: 8) {
                        if let screenshot = screenshot, NeevaFeatureFlags[.feedbackScreenshot] {
                            GroupedCell {
                                Toggle(isOn: $shareScreenshot) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Share Screenshot")
                                            .withFont(.labelLarge)
                                        Button(action: { screenshotSheet.present() }) {
                                            Text("View or edit").withFont(.labelMedium)
                                        }
                                        .disabled(!shareScreenshot)
                                        .buttonStyle(.borderless)
                                    }
                                }
                                .padding(.vertical, 9)
                                .modal(state: $screenshotSheet) {
                                    QuickLookView(image: $editedScreenshot, original: screenshot)
                                }
                                .accessibilityAction(named: "View or Edit Screenshot") {
                                    screenshotSheet.present()
                                }
                            }
                        }

                        if let query = query, requestId != nil,
                            NeevaFeatureFlags[.feedbackQuery]
                        {
                            GroupedCell {
                                Toggle(isOn: $shareQuery) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Share My Search")
                                            .withFont(.labelLarge)
                                        Text("“\(query)”")
                                            .withFont(.labelMedium)
                                            .foregroundColor(.secondaryLabel)
                                            .lineLimit(1)
                                    }
                                }.padding(.vertical, 9)
                            }
                        } else if let url = url {
                            GroupedCell {
                                Toggle(isOn: $shareURL) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Share URL").bold().withFont(.labelLarge)
                                        HStack {
                                            let displayURL: String = {
                                                let display = url.absoluteDisplayString
                                                if display.hasPrefix("https://") {
                                                    return String(
                                                        display[
                                                            display.index(
                                                                display.startIndex,
                                                                offsetBy: "https://".count)...])
                                                }
                                                return display
                                            }()
                                            Text(displayURL)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                            Button(action: { isEditingURL = true }) {
                                                Text("edit").withFont(.labelMedium)
                                            }
                                            .background(
                                                NavigationLink(
                                                    destination: EditURLView(
                                                        $url, isActive: $isEditingURL),
                                                    isActive: $isEditingURL
                                                ) { EmptyView() }
                                                .hidden()
                                            )
                                            .disabled(!shareURL)
                                            .padding(.trailing, 8)
                                        }
                                    }
                                }
                                .padding(.vertical, 9)
                                .accessibilityAction(named: "Edit URL") { isEditingURL = true }
                            }
                        }
                    }
                    Spacer()
                }
            }
            .background(Color.groupedBackground.ignoresSafeArea())
            .applyToggleStyle()
            .navigationTitle("Back")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Support").font(.headline)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        "Cancel", action: onDismiss ?? { presentationMode.wrappedValue.dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send", action: sendFeedbackHandler)
                        .disabled(
                            feedbackText.isEmpty
                                || (!NeevaUserInfo.shared.isUserLoggedIn && email.isEmpty))
                }
            }
        }
        .presentation(isModal: feedbackText != initialText || isEditingURL)
        .navigationViewStyle(.stack)
        .onDisappear(perform: viewDidDisappear)
    }

    struct EditURLView: View {
        init(_ url: Binding<URL?>, isActive: Binding<Bool>) {
            _isActive = isActive
            _url = url
            self._urlString = .init(wrappedValue: url.wrappedValue?.absoluteString ?? "")
        }

        @Binding private var isActive: Bool
        @Binding private var url: URL?
        @State private var urlString: String

        var body: some View {
            GroupedStack {
                GroupedCell {
                    MultilineTextField(
                        "Enter a URL to submit with the feedback",
                        text: $urlString,
                        focusTextField: true,
                        onCommit: { isActive = false },
                        customize: { tf in
                            tf.keyboardType = .URL
                            tf.autocapitalizationType = .none
                            tf.autocorrectionType = .no
                        }
                    )
                    .padding(.vertical, 7)
                    .onChange(of: urlString) { value in
                        self.url = URL(string: urlString)
                    }
                }
                .padding(.vertical, 12)

                Spacer()
            }
            .background(Color.groupedBackground.ignoresSafeArea())
            .navigationTitle("Edit URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isActive = false }
                }
            }
        }
    }

    private func viewDidDisappear() {
        TourManager.shared.notifyCurrentViewClose()
    }

    private var shouldHighlightTextInput: Bool {
        return TourManager.shared.isCurrentStep(with: .promptFeedbackInNeevaMenu)
            || TourManager.shared.isCurrentStep(with: .openFeedbackPanelWithInputFieldHighlight)
    }

    private func sendFeedbackHandler() {
        var feedbackText: String

        if let url = url, shareURL,
            query == nil || requestId == nil || !NeevaFeatureFlags[.feedbackQuery]
        {
            feedbackText = self.feedbackText + "\n\nCurrent URL: \(url.absoluteString)"
        } else {
            feedbackText = self.feedbackText
        }

        if let debugInfo = debugInfo {
            feedbackText += debugInfo
        }

        let shareResults = NeevaFeatureFlags[.feedbackQuery] ? shareQuery && query != nil : false

        onFeedbackSend(
            FeedbackRequest(
                feedback: SendFeedbackMutation(
                    input: .init(
                        feedback: feedbackText,
                        shareResults: shareResults,
                        requestId: (requestId?.isEmpty ?? true) ? nil : requestId,
                        geoLocationStatus: geoLocationStatus,
                        source: NeevaConstants.appGroup.starts(with: "group.xyz")
                            ? .iosWeb3App : .iosApp,
                        screenshot: shareScreenshot && NeevaFeatureFlags[.feedbackScreenshot]
                            ? editedScreenshot.reduceAndConvertToBase64(maxSize: 800) : nil,
                        userProvidedEmail: email.isEmpty ? nil : email
                    )
                )))

        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

extension UIImage {
    // https://stackoverflow.com/a/33675160/5244995
    fileprivate convenience init?(color: UIColor, width: CGFloat, height: CGFloat) {
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    // Reduce size and convert image to base64 string format
    fileprivate func reduceAndConvertToBase64(maxSize: CGFloat) -> String? {
        let resizedImage = self.resize(maxSize)
        let imageData = resizedImage.pngData()
        return imageData?.base64EncodedString()
    }
}

struct SendFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        // iPhone 12 screen size
        SendFeedbackView(
            screenshot: UIImage(color: .systemRed, width: 390, height: 844)!,
            url: nil, requestId: "swiftui-preview", query: "Best Air Purifier",
            onFeedbackSend: { _ in })
        // iPhone 8 screen size
        SendFeedbackView(
            screenshot: UIImage(color: .systemRed, width: 375, height: 667)!,
            url: "https://www.amazon.com/dp/B0863TXG", onFeedbackSend: { _ in })
        SendFeedbackView(
            screenshot: UIImage(color: .systemBlue, width: 390, height: 844)!,
            url: "https://www.amazon.com/dp/B0863TXG",
            initialText: Array(repeating: "Placeholder text for filled form.", count: 5).joined(
                separator: "\n"), onFeedbackSend: { _ in })
    }
}
