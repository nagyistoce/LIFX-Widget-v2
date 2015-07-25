//
//  ScenesTableViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 25/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class ScenesTableViewController: HeaderTableViewController {
    
    private var scenes: [SceneModelWrapper] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

// Configuration methods
extension ScenesTableViewController {
    
    func configureWithScenes(scenes: [LIFXScene]) {
        self.scenes = scenes.map { SceneModelWrapper(scene: $0) }
        selectIndexPathForSavedScenes()
    }
    
    private func selectIndexPathForSavedScenes() {
        let savedScenes = SettingsPersistanceManager.sharedPersistanceManager.scenes
        for (index, scene) in enumerate(scenes) {
            if let matchingTarget = savedScenes.filter({ $0.scene == scene.scene }).first {
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: .None)
            }
        }
    }
    
}

// UITableViewDataSource, UITableViewDelegate
extension ScenesTableViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SceneTableViewCell") as! SceneTableViewCell
        cell.configureWithScene(scenes[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var savedScenes = SettingsPersistanceManager.sharedPersistanceManager.scenes
        savedScenes.append(scenes[indexPath.row])
        SettingsPersistanceManager.sharedPersistanceManager.scenes = savedScenes
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let scene = scenes[indexPath.row]
        var savedScenes = SettingsPersistanceManager.sharedPersistanceManager.scenes
        
        if let matchingScene = savedScenes.filter({ $0.scene == scene.scene }).first {
            savedScenes.removeAtIndex(find(savedScenes, matchingScene)!)
            SettingsPersistanceManager.sharedPersistanceManager.scenes = savedScenes
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}