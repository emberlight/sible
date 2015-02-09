//
//  ArrayQueue.m
//  emberlight-sdk
//
//

#import "ArrayQueue.h"

@interface ArrayQueue ()

@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation ArrayQueue

- (id) init {
    self = [super init];
    
    if (self) {
        self.items = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSArray *) allItems {
    return [NSArray arrayWithArray:self.items];
}

- (id) dequeue {
    id headObject = nil;
    if (self.items.count > 0) {
        headObject = [self.items objectAtIndex:0];
        [self.items removeObjectAtIndex:0];
    }
    
    return headObject;
}

- (void) enqueue:(id)anObject {
    [self.items addObject:anObject];
}

- (void) deleteItem:(id)obj {
    [self.items removeObject:obj];
}

@end
