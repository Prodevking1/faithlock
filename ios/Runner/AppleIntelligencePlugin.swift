import Flutter
import Foundation

/// Flutter plugin for Apple Intelligence meditation validation
class AppleIntelligencePlugin: NSObject, FlutterPlugin {
    private var validator: Any? // Type-erased to avoid compile errors on older iOS

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.faithlock/apple_intelligence",
            binaryMessenger: registrar.messenger()
        )
        let instance = AppleIntelligencePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    override init() {
        super.init()
        if #available(iOS 18.2, *) {
            validator = AppleIntelligenceValidator()
        }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAvailable":
            handleIsAvailable(result: result)

        case "validateMeditation":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "Invalid arguments",
                    details: nil
                ))
                return
            }
            handleValidateMeditation(args: args, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleIsAvailable(result: @escaping FlutterResult) {
        if #available(iOS 18.2, *) {
            result(AppleIntelligenceValidator.isAvailable)
        } else {
            result(false)
        }
    }

    private func handleValidateMeditation(
        args: [String: Any],
        result: @escaping FlutterResult
    ) {
        guard #available(iOS 18.2, *),
              let validator = validator as? AppleIntelligenceValidator else {
            result(FlutterError(
                code: "NOT_AVAILABLE",
                message: "Apple Intelligence not available on this device",
                details: nil
            ))
            return
        }

        guard let verseText = args["verseText"] as? String,
              let verseReference = args["verseReference"] as? String,
              let userResponse = args["userResponse"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Missing required arguments",
                details: nil
            ))
            return
        }

        let userGoals = args["userGoals"] as? String
        let userStruggles = args["userStruggles"] as? String

        Task {
            do {
                let validation = try await validator.validate(
                    verseText: verseText,
                    verseReference: verseReference,
                    userResponse: userResponse,
                    userGoals: userGoals,
                    userStruggles: userStruggles
                )

                let resultDict: [String: Any] = [
                    "isValid": validation.isValid,
                    "feedback": validation.feedback,
                    "score": validation.score
                ]

                DispatchQueue.main.async {
                    result(resultDict)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "VALIDATION_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            }
        }
    }
}
