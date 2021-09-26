import Defaults
import Foundation

final class InstancesModel: ObservableObject {
    @Published var defaultAccount: Instance.Account?

    init() {
        if let id = Defaults[.defaultAccountID] {
            let uuid = UUID(uuidString: id)
            defaultAccount = Defaults[.accounts].first { $0.id == uuid }
        }
    }

    func find(_ id: Instance.ID?) -> Instance? {
        guard id != nil else {
            return nil
        }

        return Defaults[.instances].first { $0.id == id }
    }

    func accounts(_ id: Instance.ID?) -> [Instance.Account] {
        Defaults[.accounts].filter { $0.instanceID == id }
    }

    func add(name: String, url: String) -> Instance {
        let instance = Instance(name: name, url: url)
        Defaults[.instances].append(instance)

        return instance
    }

    func remove(_ instance: Instance) {
        let accounts = accounts(instance.id)
        if let index = Defaults[.instances].firstIndex(where: { $0.id == instance.id }) {
            Defaults[.instances].remove(at: index)
            accounts.forEach { removeAccount($0) }
        }
    }

    func addAccount(instance: Instance, name: String, sid: String) -> Instance.Account {
        let account = Instance.Account(instanceID: instance.id, name: name, url: instance.url, sid: sid)
        Defaults[.accounts].append(account)

        return account
    }

    func removeAccount(_ account: Instance.Account) {
        if let accountIndex = Defaults[.accounts].firstIndex(where: { $0.id == account.id }) {
            Defaults[.accounts].remove(at: accountIndex)
        }
    }

    func resetDefaultAccount() {
        setDefaultAccount(nil)
    }

    func setDefaultAccount(_ account: Instance.Account?) {
        Defaults[.defaultAccountID] = account?.id.uuidString
        defaultAccount = account
    }
}
