//
//  OuterSpaceTableViewController.m
//  Out of this World
//
//  Created by Martin on 2016/03/27.
//  Copyright © 2016 Martin. All rights reserved.
//

#import "OuterSpaceTableViewController.h"
#import "AstronomicalData.h"
#import "SpaceObject.h"
#import "SpaceImageViewController.h"
#import "SpaceDataViewController.h"

@interface OuterSpaceTableViewController ()

@end

@implementation OuterSpaceTableViewController
#define ADDED_SPACE_OBJECTS_KEY @"Added Space Objects"

#pragma mark - lazy init
-(NSMutableArray *)planets{
    if(!_planets){
        _planets = [[NSMutableArray alloc] init];
    }
    return _planets;
}

-(NSMutableArray *)addedSpaceObjects{
    if(!_addedSpaceObjects){
        _addedSpaceObjects = [[NSMutableArray alloc] init];
    }
    return _addedSpaceObjects;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.planets = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *planetData in [AstronomicalData allKnownPlanets]){
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", planetData[PLANET_NAME]];
        UIImage *image = [UIImage imageNamed:imageName];
        
        SpaceObject *object = [[SpaceObject alloc] initWithData:planetData andImage:image];
        
        [self.planets addObject:object];
    }
    
    NSArray *mySavedPlanets =[[NSUserDefaults standardUserDefaults] arrayForKey:ADDED_SPACE_OBJECTS_KEY];
    
    for(NSDictionary *dictionary in mySavedPlanets){
        SpaceObject *savedSpaceObject = [self spaceObjectForDictionary:dictionary];
        [[self addedSpaceObjects] addObject:savedSpaceObject];//Save the objects to the array of objects
    }
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //Right before transitioning
    NSLog(@"%@", sender); //The cell clicked is the sender
    
    //Check that the sender is a UITableViewCell (introspection)
    if([sender isKindOfClass:[UITableViewCell class]]){
        //Test to make sure that the view controller we're going to
        //is in fct the SpaceImageViewController
        if([segue.destinationViewController isKindOfClass:[SpaceImageViewController class]]){
            //The next controller
            SpaceImageViewController *destinationViewController = segue.destinationViewController;
            
            //Get the index of the selected cell
            NSIndexPath *index = [self.tableView indexPathForCell:sender];
            SpaceObject *selectedObject = self.planets[index.row];
            
            destinationViewController.spaceObject = selectedObject;
        }
    }
    
    //Check for the accessory button tapped
    if([sender isKindOfClass:[NSIndexPath class]]){
        if([segue.destinationViewController isKindOfClass:[SpaceDataViewController class]]){
            SpaceDataViewController *destinationViewController = segue.destinationViewController;
            NSIndexPath *path = sender;
            SpaceObject *selectedObject = self.planets[path.row];
            
            destinationViewController.spaceObject = selectedObject;
        }
    }
    
    //Check for the add item
    if([segue .destinationViewController isKindOfClass:[AddSpaceObjectViewController class]]){
        
        //set delegate property of the addViewController
        AddSpaceObjectViewController *addSpaceObjectViewController = segue.destinationViewController;
        
        //setting this view controller as the delegate for addspaceobjectvc
        addSpaceObjectViewController.delegate = self;
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.addedSpaceObjects count] ){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1){
        return [self.addedSpaceObjects count];
    }
    return [self.planets count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //Configure the cell here
    
    if(indexPath.section == 1){
        //use new sapce object to customise the cell
        SpaceObject *planet = [self.addedSpaceObjects objectAtIndex:indexPath.row];
        cell.textLabel.text = planet.name;
        cell.detailTextLabel.text = planet.nickname;
        
        
    }else{
        //Load data from plant objects
        SpaceObject *planet = self.planets[indexPath.row];
        
        cell.textLabel.text = planet.name;
        cell.detailTextLabel.text = planet.nickname;
        cell.imageView.image = planet.image;
    }
    
    //Set look and feel
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.9];
    
    return cell;
}


#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"PushToSpaceData" sender:indexPath];
}


#pragma mark - AddSpaceObjectViewController Delegate
//these methods are called from the add space object file
-(void)didCancel{
    NSLog(@"didCancel");
    //dismiss the addSpace object page
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addSpaceObject:(SpaceObject *)spaceObject{
    //Lazy instantiation, if the array is empty, make a new one
    if(!self.addedSpaceObjects){
        self.addedSpaceObjects = [[NSMutableArray alloc]init];
    }
    
    [self.addedSpaceObjects addObject:spaceObject];
    
    NSLog(@"addSpaceObjhect");
    
    
    //Persist the space object in NSUserDefaults
    NSMutableArray *propertiesOfSpaceObjects = [[[NSUserDefaults standardUserDefaults] arrayForKey:ADDED_SPACE_OBJECTS_KEY]mutableCopy];
    
    if(!propertiesOfSpaceObjects){//Check if it's empty. lazy init
        propertiesOfSpaceObjects = [[NSMutableArray alloc] init];
    }
    //Add the saved object to array and save
    [propertiesOfSpaceObjects addObject:[self spaceObjectAsPropertyList:spaceObject]];
    
    [[NSUserDefaults standardUserDefaults] setObject:propertiesOfSpaceObjects forKey:ADDED_SPACE_OBJECTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Helper methods

-(NSDictionary *)spaceObjectAsPropertyList:(SpaceObject *)spaceObject{
    NSData *imageData = UIImagePNGRepresentation(spaceObject.image);
    
    NSDictionary *dict = @{PLANET_NAME : spaceObject.name,
                           PLANET_GRAVITY: @(spaceObject.gravitationalForce),
                           PLANET_DIAMETER:@(spaceObject.diameter),
                           PLANET_YEAR_LENGTH: @(spaceObject.yearLength),
                           PLANET_DAY_LENGTH: @(spaceObject.dayLength),
                           PLANET_TEMPERATURE:@(spaceObject.templ),
                           PLANET_NUMBER_OF_MOONS:@(spaceObject.numberOfMoons),
                           
                           PLANET_NICKNAME:spaceObject.nickname,
                           PLANET_INTERESTING_FACT: spaceObject.interestingFact,
                           PLANET_IMAGE:imageData};
    
    //All properties can be converted properly but for the image
    //An image should not be saved in NSUserPreferences since it's large
    //Save image to NSData
    
    
    return dict;
}

-(SpaceObject *)spaceObjectForDictionary:(NSDictionary *)dictionary{
    //Extract the image as well
    
    //Conver data object to image
    NSData *imageData = dictionary[PLANET_IMAGE];
    UIImage *image = [UIImage imageWithData:imageData];
    
    SpaceObject *object = [[SpaceObject alloc] initWithData:dictionary andImage:image];
    
    return object;
}
@end
