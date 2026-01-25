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
}
