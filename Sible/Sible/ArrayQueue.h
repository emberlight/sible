//
//  ArrayQueue.h
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayQueue : NSObject

- (NSArray *) allItems;
- (id) dequeue;
- (void) enqueue:(id)obj;
- (void) deleteItem: (id) obj;

@end
