//
//  HeaderTableViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 22/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class HeaderTableViewController: UITableViewController {

}

// UIScrollViewDelegate
extension HeaderTableViewController {
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if shouldUpdateHeaderPositionForScrollView(scrollView) && decelerate == false {
            pinTableViewToHeader()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if shouldUpdateHeaderPositionForScrollView(scrollView) {
            pinTableViewToHeader()
        }
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if shouldUpdateHeaderPositionForScrollView(scrollView) {
            let currentYPosition = tableView.contentOffset.y + tableView.contentInset.top
            let targetYPosition = targetContentOffset.memory.y + tableView.contentInset.top
            let headerHeight = CGRectGetHeight(tableView.tableHeaderView!.bounds)
            if currentYPosition > headerHeight && targetYPosition < headerHeight {
                targetContentOffset.memory.y = headerHeight - tableView.contentInset.top
            }
        }
    }
    
    private func pinTableViewToHeader() {
        var contentOffset = tableView.contentOffset
        let scrollPosition = contentOffset.y + tableView.contentInset.top
        let headerHeight = CGRectGetHeight(tableView.tableHeaderView!.bounds)
        if scrollPosition < headerHeight / 2 {
            contentOffset.y = 0
        }
        else if scrollPosition < headerHeight {
            contentOffset.y = headerHeight
        }
        else {
            return ;
        }
        contentOffset.y -= tableView.contentInset.top
        tableView.setContentOffset(contentOffset, animated: true)
    }
    
    private func shouldUpdateHeaderPositionForScrollView(scrollView: UIScrollView) -> Bool {
        return scrollView === tableView && tableView.tableHeaderView != nil
    }
}
