import Foundation

extension Notification.Name {
    static let userSettingsUpdated = Notification.Name("UserSettingsUpdated")
}

struct PublishSettings {
    let allowMicrocuration: Bool
    let allowEcho: Bool
    let allowTimecapsule: Bool
    let angelEnabled: Bool
    let horseTrailEnabled: Bool
    let horseWitnessEnabled: Bool
}

struct PublishPayload {
    let isPublic: Bool
    let includeBottle: Bool
    let settings: PublishSettings
}

struct UserSettingsPayload {
    let allowMicrocuration: Bool
    let allowEcho: Bool
    let allowTimecapsule: Bool
    let allowAngel: Bool
    let horseTrailEnabled: Bool
    let horseWitnessEnabled: Bool
}

struct ExhibitSummary {
    let id: String
    let title: String
    let moodCode: String
    let count: Int
}

enum APIClientError: Error {
    case simulatedFailure
}

struct APIClient {
    func publish(
        payload: PublishPayload,
        simulateFailure: Bool = false,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if simulateFailure {
                completion(.failure(APIClientError.simulatedFailure))
            } else {
                completion(.success(()))
            }
        }
    }

    func saveUserSettings(
        payload: UserSettingsPayload,
        simulateFailure: Bool = false,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if simulateFailure {
                completion(.failure(APIClientError.simulatedFailure))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchUserSettings(completion: @escaping (UserSettingsPayload) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(
                UserSettingsPayload(
                    allowMicrocuration: false,
                    allowEcho: false,
                    allowTimecapsule: true,
                    allowAngel: false,
                    horseTrailEnabled: false,
                    horseWitnessEnabled: false
                )
            )
        }
    }

    func fetchExhibits(completion: @escaping ([ExhibitSummary]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion([
                ExhibitSummary(id: "exhibit_healing", title: "雨天慢下来", moodCode: "healing", count: 8),
                ExhibitSummary(id: "exhibit_light", title: "下班的轻呼吸", moodCode: "light", count: 6),
                ExhibitSummary(id: "exhibit_horse", title: "马年祝福墙", moodCode: "luck", count: 4)
            ])
        }
    }
}
