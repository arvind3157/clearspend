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
    let suggestedCategory: String?
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
            let suggestedCategory = extractCategory(from: text)

            completion(
                OCRResult(
                    fullText: text,
                    amount: amount,
                    date: date,
                    merchant: merchant,
                    suggestedCategory: suggestedCategory
                )
            )
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }

    // MARK: - Enhanced Extraction Methods

    private static func extractAmount(from text: String) -> Double? {
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Priority patterns for finding total amount
        let totalKeywords = ["total", "subtotal", "amount", "sum", "pay", "due", "balance"]
        let currencySymbols = ["$", "₹", "€", "£", "¥"]
        
        var bestAmount: Double?
        var highestPriority = -1
        
        for (index, line) in lines.enumerated() {
            let lowercaseLine = line.lowercased()
            
            // Check if line contains total keywords (higher priority)
            let linePriority = totalKeywords.contains { keyword in
                lowercaseLine.contains(keyword)
            } ? 2 : 1
            
            // Extract amounts from this line
            let amounts = extractAmountsFromLine(line)
            
            for amount in amounts {
                if linePriority > highestPriority || (linePriority == highestPriority && bestAmount == nil) {
                    bestAmount = amount
                    highestPriority = linePriority
                }
            }
        }
        
        return bestAmount
    }
    
    private static func extractAmountsFromLine(_ line: String) -> [Double] {
        var amounts: [Double] = []
        
        // Pattern for currency amounts
        let patterns = [
            #"[\$₹€£¥]\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)"#, // $1,234.56
            #"(\d+(?:,\d{3})*(?:\.\d{1,2})?)\s*[\$₹€£¥]"#, // 1,234.56$
            #"(\d+(?:,\d{3})*(?:\.\d{1,2})?)"# // 1,234.56
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let matches = regex.matches(in: line, range: NSRange(line.startIndex..., in: line))
                
                for match in matches {
                    // Get the first capture group (the amount without currency symbol)
                    let range = match.range(at: 1)
                    if range.location != NSNotFound,
                       let amountRange = Range(range, in: line) {
                        let amountString = String(line[amountRange]).replacingOccurrences(of: ",", with: "")
                        if let amount = Double(amountString) {
                            amounts.append(amount)
                        }
                    }
                }
            }
        }
        
        return amounts
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
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Skip lines with amounts, dates, or common receipt headers
        let skipPatterns = [
            #"^\d+/\d+/\d+"#, // dates
            #"^\$?\d+\.\d{2}"#, // amounts
            #"^(total|subtotal|tax|cash|credit|debit)"#, // receipt terms
            #"^(qty|item|price|amount)"# // table headers
        ]
        
        for line in lines {
            if line.count < 3 { continue }
            
            let shouldSkip = skipPatterns.contains { pattern in
                line.lowercased().range(of: pattern, options: .regularExpression) != nil
            }
            
            if !shouldSkip {
                return line
            }
        }
        
        return lines.first { $0.count > 3 }
    }
    
    private static func extractCategory(from text: String) -> String? {
        let lowercaseText = text.lowercased()
        
        // Category keyword mapping
        let categoryKeywords: [String: String] = [
            // Food & Dining
            "restaurant": "Food & Dining",
            "food": "Food & Dining",
            "dining": "Food & Dining",
            "cafe": "Food & Dining",
            "coffee": "Food & Dining",
            "pizza": "Food & Dining",
            "burger": "Food & Dining",
            "meal": "Food & Dining",
            "breakfast": "Food & Dining",
            "lunch": "Food & Dining",
            "dinner": "Food & Dining",
            
            // Transportation
            "uber": "Transportation",
            "lyft": "Transportation",
            "taxi": "Transportation",
            "cab": "Transportation",
            "gas": "Transportation",
            "petrol": "Transportation",
            "fuel": "Transportation",
            "parking": "Transportation",
            "metro": "Transportation",
            "bus": "Transportation",
            "train": "Transportation",
            "subway": "Transportation",
            "airport": "Transportation",
            
            // Shopping
            "amazon": "Shopping",
            "walmart": "Shopping",
            "target": "Shopping",
            "store": "Shopping",
            "shop": "Shopping",
            "mall": "Shopping",
            "retail": "Shopping",
            "clothing": "Shopping",
            "shoes": "Shopping",
            "electronics": "Shopping",
            
            // Entertainment
            "movie": "Entertainment",
            "cinema": "Entertainment",
            "theater": "Entertainment",
            "concert": "Entertainment",
            "netflix": "Entertainment",
            "spotify": "Entertainment",
            "game": "Entertainment",
            
            // Healthcare
            "pharmacy": "Healthcare",
            "medical": "Healthcare",
            "doctor": "Healthcare",
            "hospital": "Healthcare",
            "clinic": "Healthcare",
            "medicine": "Healthcare",
            
            // Utilities
            "electric": "Utilities",
            "water": "Utilities",
            "gas bill": "Utilities",
            "internet": "Utilities",
            "phone": "Utilities",
            "mobile": "Utilities",
            
            // Education
            "book": "Education",
            "course": "Education",
            "tuition": "Education",
            "school": "Education",
            "university": "Education",
            
            // Travel
            "hotel": "Travel",
            "flight": "Travel",
            "airline": "Travel",
            "booking": "Travel",
            "reservation": "Travel"
        ]
        
        // Find matching category
        for (keyword, category) in categoryKeywords {
            if lowercaseText.contains(keyword) {
                return category
            }
        }
        
        return nil
    }
}
