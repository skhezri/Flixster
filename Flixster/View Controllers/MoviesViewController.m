//
//  MoviesViewController.m
//  Flixster
//
//  Created by Sophia Khezri on 6/27/18.
//  Copyright © 2018 Sophia Khezri. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MovieCollectionCell.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property ( nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *filteredMovies;
@end


@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.searchBar.delegate=self;
   
   
    [self fetchMovies];
  
    self.refreshControl= [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
   
}

-(void)fetchMovies{
     [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Movie Error"
                                                                    message:@"The internet connection appears to be offline"
                                                             preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction * acceptNetworkFailure= [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler: ^ (UIAlertAction* _Nonnull action){
                
            }];
            [alert addAction:acceptNetworkFailure];
            [self presentViewController: alert animated: YES completion:^{
            }];
            
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies= dataDictionary[@"results"];
             self.filteredMovies=self.movies;
            for(NSDictionary *movie in self.movies){
                NSLog(@"%@" ,movie[@"title"]);
            }
            
            [self.tableView reloadData];
             [self.activityIndicator stopAnimating];
            // TODO: Get the array of movies
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
        }
        [self.refreshControl endRefreshing];
        
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieCell *cell= [tableView dequeueReusableCellWithIdentifier: @"MovieCell" forIndexPath:indexPath];
    
    
    
    NSDictionary * movie=self.filteredMovies[indexPath.row];
    cell.titleLabel.text= movie[@"title"];
    cell.textLab.text=movie[@"overview"];
    
    NSString *baseURLString=@"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString=movie[@"poster_path"];
    NSString *fullPosterURLString= [baseURLString stringByAppendingString:posterURLString];
    NSURL * posterURL = [NSURL URLWithString:fullPosterURLString];
    NSURLRequest * request =[NSURLRequest requestWithURL: posterURL];
    __weak MovieCell *weakCell = cell;
    
    [cell.imageLab setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
        if (imageResponse) {
            NSLog(@"Image was NOT cached, fade in image");
            weakCell.imageLab.alpha = 0;
            weakCell.imageLab.image = image;
            [UIView animateWithDuration:2 animations:^{
                weakCell.imageLab.alpha = 1.0;
    

                
            }];
        } else {
                NSLog(@"Image was cached so just update the image");
                weakCell.imageLab.image = image;
        }
    }
      failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
    
    }];
    return cell;
}

-(void) searchBar:(UISearchBar *) searchBar textDidChange: (NSString *) searchText{
    if(searchText.length!= 0){
        NSPredicate * predicate= [NSPredicate predicateWithBlock: ^BOOL(NSDictionary *movies  , NSDictionary *bindings){
            return[movies[@"title"] containsString: searchText];
        }];
            self.filteredMovies=[self.movies filteredArrayUsingPredicate:predicate];
        } else{
                self.filteredMovies=self.movies;
            }
            [self.tableView reloadData];
    }
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell * tappedCell= sender;
    NSIndexPath * indexPath=[self.tableView indexPathForCell:tappedCell];
    NSDictionary * movie= self.movies[indexPath.row];
    DetailsViewController * detailsViewControl=[segue destinationViewController];
    detailsViewControl.movie=movie;
}





@end
