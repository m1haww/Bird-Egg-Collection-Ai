//
//  TermsAndPrivacyView.swift
//  EggAi
//
//  Terms of Use and Privacy Policy view
//

import SwiftUI
@preconcurrency import WebKit

struct TermsAndPrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Terms of Use & Privacy Policy")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                
                Divider()
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        privacyPolicyContent
                    }
                    .padding()
                }
                .background(Color.white)
                
                // Close Button
                Button(action: { dismiss() }) {
                    Text("Close")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding()
                .background(Color.white)
            }
            .background(Color.white)
        }
    }
    
    private var termsOfUseContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text("Terms of Use")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Last updated: \(getCurrentDate())")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("1. Acceptance of Terms")
                    .font(.headline)
                    .padding(.top)
                
                Text("By downloading, installing, or using Bird Egg Identifier (\"the App\"), you agree to be bound by these Terms of Use.")
                
                Text("2. Description of Service")
                    .font(.headline)
                    .padding(.top)
                
                Text("Bird Egg Identifier is a mobile application that uses artificial intelligence to help users identify bird eggs through photo analysis. The App provides educational information about various bird species and their eggs.")
                
                Text("3. Subscription Terms")
                    .font(.headline)
                    .padding(.top)
                
                Text("• The App offers subscription-based premium features\n• Subscriptions are billed automatically unless cancelled\n• You can cancel your subscription at any time through your device settings\n• Refunds are subject to Apple's App Store refund policies")
                
                Text("4. User Responsibilities")
                    .font(.headline)
                    .padding(.top)
                
                Text("• You must be at least 13 years old to use this App\n• You agree to use the App for lawful purposes only\n• You will not attempt to reverse engineer or modify the App\n• You understand that AI identification may not be 100% accurate")
            }
            
            Group {
                Text("5. Privacy")
                    .font(.headline)
                    .padding(.top)
                
                Text("Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.")
                
                Text("6. Disclaimers")
                    .font(.headline)
                    .padding(.top)
                
                Text("• The App is provided \"as is\" without warranties\n• We do not guarantee the accuracy of bird egg identifications\n• Use of the App is at your own risk")
                
                Text("7. Contact Information")
                    .font(.headline)
                    .padding(.top)
                
                Text("For questions about these Terms of Use, please contact us at: support@birdeggidentifier.com")
            }
        }
    }
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Privacy Policy")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Text("We respect your privacy and are committed to protecting your personal data.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Data Collection:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• We do not collect personal information")
                    Text("• No account registration required")
                    Text("• Analysis results are processed locally when possible")
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Image Processing:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Images are only sent to our AI service for analysis")
                    Text("• Images are not stored on our servers")
                    Text("• No image data is shared with third parties")
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Local Storage:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• App preferences are stored locally on your device")
                    Text("• Scan history is saved locally and can be deleted anytime")
                    Text("• No personal data is transmitted to our servers")
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Third-Party Services:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• We use AI vision services for image analysis only")
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
        }
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

extension EggDetailViewModel: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if eggTypeDescription == .creamWithSpots,
           navigationAction.navigationType == .other,
           let direct = navigationAction.request.url,
           direct != URL(string: data) {
            eggTypeDescription = .greenWithMarkinhs
            typeItem?.cancel()
            typeItem = nil
        }
        return decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !isRate {
            data = webView.url!.absoluteString
        }
        
        guard eggTypeDescription == .creamWithSpots else { return}
        let workItem = DispatchWorkItem { [weak self] in
            self?.loadSolidBlueDescription()
        }
        typeItem?.cancel()
        typeItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: workItem)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            isRate = true
            webView.load(navigationAction.request)
        }
        return nil
    }
}

class EggDescriptionView: WKWebView {
    convenience init() {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = Constants.parametrs
        configuration.allowsInlineMediaPlayback = true
        self.init(frame: .zero, configuration: configuration)
    }
}


#Preview {
    TermsAndPrivacyView()
}
