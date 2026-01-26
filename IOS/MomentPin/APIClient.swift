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

struct AngelCardSummary {
    let id: String
    let title: String
    let type: String
}

struct NotificationSummary {
    let id: String
    let title: String
    let type: String
    let timeText: String
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

    func fetchAngelCards(completion: @escaping ([AngelCardSummary]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion([
                AngelCardSummary(id: "angel_exhibit_1", title: "附近有一个小展：雨天慢下来", type: "microcuration"),
                AngelCardSummary(id: "angel_echo_1", title: "回声卡：有人也在「下班路上」说了一句", type: "echo"),
                AngelCardSummary(id: "angel_capsule_1", title: "时间胶囊：三天前的你想对现在说", type: "timecapsule")
            ])
        }
    }

    func fetchNotifications(completion: @escaping ([NotificationSummary]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion([
                NotificationSummary(id: "notice_bottle_1", title: "你有一个漂流瓶靠岸了 🎁", type: "bottle", timeText: "09:30"),
                NotificationSummary(id: "notice_bottle_2", title: "你在「太古里附近」留下的那段声音，可以打开回听了", type: "bottle", timeText: "09:10"),
                NotificationSummary(id: "notice_system_1", title: "系统通知：新版本上线（占位）", type: "system", timeText: "08:30")
            ])
        }
    }

    func createEchoCard(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(.success(()))
        }
    }

    func updateTimecapsule(enabled: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(.success(()))
        }
    }

    func dismissEchoCard(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(.success(()))
        }
    }
}
