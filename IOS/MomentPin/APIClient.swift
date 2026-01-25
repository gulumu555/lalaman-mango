import Foundation

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

struct APIClient {
    func publish(payload: PublishPayload, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion(.success(()))
        }
    }
}
