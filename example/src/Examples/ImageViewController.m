#import <IndoorAtlas/IALocationManager.h>
#import <IndoorAtlas/IAResourceManager.h>
#import "ImageViewController.h"
#import "../ApiKeys.h"

@interface ImageViewController () <IALocationManagerDelegate>
@property (nonatomic, strong) IAFloorPlan *floorPlan;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *circle;
@property (nonatomic, strong) IALocationManager *manager;
@property (nonatomic, strong) IAResourceManager *resourceManager;
@end

@implementation ImageViewController

#pragma mark IALocationManager delegate methods

/**
 * Handle location changes
 */
- (void)indoorLocationManager:(IALocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    IALocation* loc = [locations lastObject];

    __weak typeof(self) weakSelf = self;
    if (self.floorPlan != nil) {
        // The accuracy of coordinate position depends on the placement of floor plan image.
        CGPoint point = [self.floorPlan coordinateToPoint:loc.location.coordinate];
        NSLog(@"position changed to pixel point: %fx%f", point.x, point.y);
        [UIView animateWithDuration:(self.circle.hidden ? 0.0f : 0.35f) animations:^{
            weakSelf.circle.center = point;
        }];
    }

    self.circle.hidden = NO;
}

- (void)indoorLocationManager:(IALocationManager *)manager didEnterRegion:(IARegion *)region
{
    [self fetchFloorplanWithId:region.identifier];
}

#pragma mark IndoorAtlas API Usage

/**
 * Fetch floor plan and image with ID
 * These methods are just wrappers around server requests.
 * You will need api key and secret to fetch resources.
 */
- (void)fetchFloorplanWithId:(NSString*)floorplanId
{
    __weak typeof(self) weakSelf = self;
    [self.resourceManager fetchFloorPlanWithId:floorplanId andCompletion:^(IAFloorPlan *floorplan, NSError *error) {
       if (error) {
           NSLog(@"Error during floorplan fetch: %@", error);
           return;
       }

       NSLog(@"fetched floorplan with id: %@", floorplanId);

       [self.resourceManager fetchFloorPlanImageWithUrl:floorplan.imageUrl andCompletion:^(NSData *data, NSError *error) {
           if (error) {
               NSLog(@"Error during floorplan image fetch: %@", error);
               return;
           }

           UIImage *image = [UIImage imageWithData:data];

           float scale = fmin(1.0, fmin(weakSelf.view.bounds.size.width / floorplan.width,
                                        weakSelf.view.bounds.size.height / floorplan.height));

           CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);

           weakSelf.imageView.transform = CGAffineTransformIdentity;
           weakSelf.imageView.image = image;
           weakSelf.imageView.frame = CGRectMake(0, 0, floorplan.width, floorplan.height);
           weakSelf.imageView.transform = t;
           weakSelf.imageView.center = weakSelf.view.center;

           // 1 meters in pixels
           float size = floorplan.meterToPixelConversion;
           weakSelf.circle.transform = CGAffineTransformMakeScale(size, size);
       }];

       weakSelf.floorPlan = floorplan;
   }];
}

/**
 * Authenticate to IndoorAtlas services
 */
- (void)authenticateAndFetchFloorplan
{
    // Create IALocationManager and point delegate to receiver
    self.manager = [IALocationManager new];
    self.manager.delegate = self;

    // Set IndoorAtlas API key and secret
    [self.manager setApiKey:kAPIKey andSecret:kAPISecret];

    // Optionally set initial location
    IALocation *location = [IALocation locationWithFloorPlanId:kFloorplanId];
    self.manager.location = location;

    // Create floor plan manager
    self.resourceManager = [IAResourceManager resourceManagerWithLocationManager:self.manager];

    // Request location updates
    [self.manager startUpdatingLocation];
}

#pragma mark ImageViewContoller boilerplate

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];

    self.circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.circle.backgroundColor = [UIColor colorWithRed:0 green:0.647 blue:0.961 alpha:1.0];
    self.circle.hidden = YES;
    [self.imageView addSubview:self.circle];

    [self authenticateAndFetchFloorplan];
}

@end

/* vim: set ts=8 sw=4 tw=0 ft=objc :*/
