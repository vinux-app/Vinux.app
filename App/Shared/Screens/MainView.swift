//
//  MainView.swift
//  Universal App
//
//  Created by Can Balkaya on 12/11/20.
//

import SwiftUI

struct MainView: View {
    
    @State var needs_setup = false;
    @State var keypair: Keypair? = nil;
    
    // MARK: - Properties
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    #endif
    
    // MARK: - UI Elements
    @ViewBuilder
    var body: some View {
        Group {
            if let kp = keypair, !needs_setup {
                // Text("Sidebar")
                // Text("Group Content")
                ContentView(keypair: kp)
                   // .frame(minWidth: 600, minHeight: 600)

            } else {
                SetupView()
                    .onReceive(handle_notify(.login)) { notif in
                        needs_setup = false
                        keypair = get_saved_keypair()
                    }
            }
        }
        .onReceive(handle_notify(.logout)) { _ in
            keypair = nil
        }
        .onAppear {
            keypair = get_saved_keypair()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

func needs_setup() -> Keypair? {
    return get_saved_keypair()
}
    
