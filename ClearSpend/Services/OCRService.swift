//
//  OCRService.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import Vision
import UIKit

struct OCRResult {
    let fullText: String
    let amount: Double?
    let date: Date?
    let merchant: String?
}

final class OCRService {

    static func recognizeText(
        from image: UIImage,
        completion: @escaping (OCRResult) -> Void
    ) {
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []

            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            let amount = extractAmount(from: text)
            let date = extractDate(from: text)
            let merchant = extractMerchant(from: text)

            completion(
                OCRResult(
                    fullText: text,
                    amount: amount,
                    date: date,
                    merchant: merchant
                )
            )
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }

    // MARK: - Heuristics (Static Helpers)

    private static func extractAmount(from text: String) -> Double? {
        let pattern = #"(\d+(\.\d{1,2})?)"#
        let regex = try? NSRegularExpression(pattern: pattern)

        let matches = regex?.matches(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ) ?? []

        return matches
            .compactMap {
                Double((text as NSString).substring(with: $0.range))
            }
            .max()
    }

    private static func extractDate(from text: String) -> Date? {
        let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.date.rawValue
        )

        let match = detector?.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        )

        return match?.date
    }

    private static func extractMerchant(from text: String) -> String? {
        text
            .components(separatedBy: .newlines)
            .first { $0.count > 3 }
    }
}
