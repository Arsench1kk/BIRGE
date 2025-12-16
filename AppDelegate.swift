//
//  AppDelegate.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        checkCoreDataSetup()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            CoreDataManager.shared.preloadDemoData()
        }
        
        return true
    }
    
    private func checkCoreDataSetup() {
        let context = CoreDataManager.shared.context
        
        // Проверка существования сущностей
        let model = CoreDataManager.shared.persistentContainer.managedObjectModel
        print("=== Core Data Entities ===")
        for entity in model.entities {
            print("Entity: \(entity.name ?? "nil")")
            print("Class: \(entity.managedObjectClassName ?? "nil")")
            print("---")
        }
        
    }
}
