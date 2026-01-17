//
//  SmartRenamer.swift
//  SmartScreenshotApp
//
//  Created by timbo on 1/15/26.
//

import Foundation
import Vision
import CoreImage
import FoundationModels

private enum Config {
    nonisolated static let filenamePromptTemplate = """
        [Task] Generate a concise, snake_case filename.
        [Context] %@
        [Rules] Max 5 words. Snake_case. No extension. Output ONLY the filename.
        """
    
    nonisolated static let recognitionLanguages = ["en-US"]
}

actor SmartRenamer {
    
    private let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
    
    func generateSmartName(for url: URL) async throws -> String {
        
        guard model.isAvailable else {
            throw NSError(domain: "SmartRenamer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model unavailable"])
        }
        
        let analysis = await extractVisualContext(from: url)
        
        let prompt = await String(format: Config.filenamePromptTemplate, analysis)
        
        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)
        
        let cleanName = response.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "`", with: "")
        
        return cleanName.isEmpty ? "screenshot_\(Int.random(in: 1000...9999))" : cleanName
    }
    
    private func extractVisualContext(from url: URL) async -> String {
        
        guard let image = CIImage(contentsOf: url) else { return "Unknown Image" }
        
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = false
        textRequest.recognitionLanguages = await Config.recognitionLanguages
        
        let classifyRequest = VNClassifyImageRequest()
        
        do {
            let handler = VNImageRequestHandler(ciImage: image)
            try handler.perform([textRequest, classifyRequest])
            
            let text = textRequest.results?
                .prefix(4)
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ") ?? ""
            
            let category = classifyRequest.results?.first?.identifier ?? "General"
            
            return "Detected Objects: \(category). Visible Text: \"\(text)\""
        } catch {
            return "Analysis Failed"
        }
    }
}
