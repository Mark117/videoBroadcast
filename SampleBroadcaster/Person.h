//
//  Person.h
//  person mcb
//
//  Created by Christopher Noonan on 28/01/2014.
//  Copyright (c) 2014 Christopher Noonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
{
    NSString * name;
    NSString * address;
    NSString * phone;
    NSString * image;
}
@property (nonatomic,copy)NSString * name;
@property (nonatomic,copy)NSString * address;
@property (nonatomic,copy)NSString * phone;
@property (nonatomic,copy)NSString * image;

-(Person *) initWithName: (NSString *) _name
             andAddress : (NSString *) _address
               andPhone :(NSString *) _phone
                andImage: (NSString *) _image;

@end
