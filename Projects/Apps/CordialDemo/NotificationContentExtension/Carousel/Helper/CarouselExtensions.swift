//
//  CarouselExtensions.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 21.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import UIKit
import os.log

extension UIImageView {
    public func asyncImage(url: URL) {
        self.image = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                os_log("%{public}@", error.localizedDescription)
                return
            }
            
            if let responseData = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: responseData)
                }
            } else {
                os_log("Image is absent by the URL")
            }
        }.resume()
    }
}
