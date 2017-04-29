//
//  MasterViewController+UIViewControllerPreview.swift
//  highkara
//
//  Created by Marko Wallin on 7.2.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit

extension MasterViewController: UIViewControllerPreviewingDelegate {
    // MARK: UIViewControllerPreviewingDelegate
    
    /// Create a previewing view controller to be shown at "Peek".
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
                  let cell = tableView.cellForRow(at: indexPath) else { return nil }
		
        // Create a detail view controller and set its properties.
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return nil }
		
		let selectedCategory = self.categories[indexPath.row]
		detailViewController.navigationItemTitle = selectedCategory.title
		detailViewController.highFiSection = selectedCategory.htmlFilename
		
        /*
            Set the height of the preview by setting the preferred content size of the detail view controller.
            Width should be zero, because it's not used in portrait.
        */
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        
        // Set the source rect to the cell frame, so surrounding elements are blurred.
		previewingContext.sourceRect = cell.frame
		
        return detailViewController
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        show(viewControllerToCommit, sender: self)
    }
}
