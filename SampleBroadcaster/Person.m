//
//  Person.m
//  person mcb
//
//  Created by Christopher Noonan on 28/01/2014.
//  Copyright (c) 2014 Christopher Noonan. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize name,address,phone,image;



-(Person *) initWithName: (NSString *) _name
             andAddress : (NSString *) _address
               andPhone :(NSString *) _phone    
                andImage: (NSString *) _image

{
    self =[super init];
    self.name= _name;
    self.address= _address;
    self.phone= _phone;
    self.image= _image;
    
    return self;
}

@end
