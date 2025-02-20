// :replace-start: {
//   "terms": {
//     "SwiftUI_": "",
//     "flexibleSyncApp": "app",
//     "thisFlexibleSyncApp": "app",
//     "FlexibleSyncLoginView": "LoginView"
//   }
// }
import RealmSwift
import SwiftUI

let thisApp: RealmSwift.App? = RealmSwift.App(id: YOUR_APP_SERVICES_APP_ID_HERE)
let thisFlexibleSyncApp: RealmSwift.App? = RealmSwift.App(id: "swift-flexible-vkljj")

// :snippet-start: partition-based-sync-content-view
/// This view observes the Realm app object.
/// Either direct the user to login, or open a realm
/// with a logged-in user.
struct PartitionBasedSyncContentView: View {
    // Observe the Realm app object in order to react to login state changes.
    @ObservedObject var thisApp: RealmSwift.App

    var body: some View {
        if let user = thisApp.currentUser {
            // :snippet-start: partition-value-environment-object
            // If there is a logged in user, pass the user ID as the
            // partitionValue to the view that opens a realm.
            OpenPartitionBasedSyncRealmView().environment(\.partitionValue, user.id)
            // :snippet-end:
        } else {
            // If there is no user logged in, show the login view.
            LoginView()
        }
    }
}
// :snippet-end:

// :snippet-start: flexible-sync-content-view
/// This view observes the Realm app object.
/// Either direct the user to login, or open a realm
/// with a logged-in user.
struct FlexibleSyncContentView: View {
    // Observe the Realm app object in order to react to login state changes.
    @ObservedObject var flexibleSyncApp: RealmSwift.App

    var body: some View {
        if let user = flexibleSyncApp.currentUser {
            // :snippet-start: flexible-sync-config
            // Create a `flexibleSyncConfiguration` with `initialSubscriptions`.
            // We'll inject this configuration as an environment value to use when opening the realm
            // in the next view, and the realm will open with these initial subscriptions.
            let config = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
                let peopleSubscriptionExists = subs.first(named: "people")
                let dogSubscriptionExists = subs.first(named: "dogs")
                // Check whether the subscription already exists. Adding it more
                // than once causes an error.
                if (peopleSubscriptionExists != nil) && (dogSubscriptionExists != nil) {
                    // Existing subscriptions found - do nothing
                    return
                } else {
                    // Add queries for any objects you want to use in the app
                    // Linked objects do not automatically get queried, so you
                    // must explicitly query for all linked objects you want to include.
                    subs.append(QuerySubscription<SwiftUI_Person>(name: "people"))
                    subs.append(QuerySubscription<SwiftUI_Dog>(name: "dogs"))
                }
            })
            // :snippet-end:
            // :snippet-start: inject-flex-sync-config-as-environment-object
            OpenFlexibleSyncRealmView()
                .environment(\.realmConfiguration, config)
            // :snippet-end:
        } else {
            // If there is no user logged in, show the login view.
            FlexibleSyncLoginView()
        }
    }
}
// :snippet-end:

// MARK: Authentication Views
// :snippet-start: login-view
/// Represents the login screen. We will have a button to log in anonymously.
struct LoginView: View {
    // Hold an error if one occurs so we can display it.
    @State var error: Error?
    
    // Keep track of whether login is in progress.
    @State var isLoggingIn = false

    var body: some View {
        VStack {
            if isLoggingIn {
                ProgressView()
            }
            if let error = error {
                Text("Error: \(error.localizedDescription)")
            }
            Button("Log in anonymously") {
                // Button pressed, so log in
                isLoggingIn = true
                thisApp!.login(credentials: .anonymous) { result in
                    isLoggingIn = false
                    if case let .failure(error) = result {
                        print("Failed to log in: \(error.localizedDescription)")
                        // Set error to observed property so it can be displayed
                        self.error = error
                        return
                    }
                    // Other views are observing the app and will detect
                    // that the currentUser has changed. Nothing more to do here.
                    print("Logged in")
                }
            }.disabled(isLoggingIn)
        }
    }
}
// :snippet-end:

struct FlexibleSyncLoginView: View {
    // Hold an error if one occurs so we can display it.
    @State var error: Error?
    
    // Keep track of whether login is in progress.
    @State var isLoggingIn = false

    var body: some View {
        VStack {
            if isLoggingIn {
                ProgressView()
            }
            if let error = error {
                Text("Error: \(error.localizedDescription)")
            }
            Button("Log in anonymously") {
                // Button pressed, so log in
                isLoggingIn = true
                thisFlexibleSyncApp!.login(credentials: .anonymous) { result in
                    isLoggingIn = false
                    if case let .failure(error) = result {
                        print("Failed to log in: \(error.localizedDescription)")
                        // Set error to observed property so it can be displayed
                        self.error = error
                        return
                    }
                    // Other views are observing the app and will detect
                    // that the currentUser has changed. Nothing more to do here.
                    print("Logged in")
                }
            }.disabled(isLoggingIn)
        }
    }
}

// :snippet-start: logout-button
/// A button that handles logout requests.
struct LogoutButton: View {
    @State var isLoggingOut = false

    var body: some View {
        Button("Log Out") {
            guard let user = thisApp!.currentUser else {
                return
            }
            isLoggingOut = true
            user.logOut() { error in
                isLoggingOut = false
                // Other views are observing the app and will detect
                // that the currentUser has changed. Nothing more to do here.
                print("Logged out")
            }
        }.disabled(thisApp!.currentUser == nil || isLoggingOut)
    }
}
// :snippet-end:
// :replace-end:
