//
//  MoviesGridViewController.m
//  Flixster
//
//  Created by Sophia Khezri on 6/28/18.
//  Copyright © 2018 Sophia Khezri. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredMovies;
@property ( nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    self.searchBar.delegate=self;
    
    [self fetchMovies];
    self.refreshControl= [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    UICollectionViewFlowLayout *layout= (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing=1;
    layout.minimumLineSpacing=1;
    CGFloat posterPerLine=3;
    CGFloat itemWidth=(self.collectionView.frame.size.width-layout.minimumInteritemSpacing * (posterPerLine-1))/posterPerLine;
    CGFloat itemHeight=1.7*itemWidth; //random ratio chosen
    layout.itemSize=CGSizeMake(itemWidth, itemHeight);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
    
    
}
-(void)fetchMovies{
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies= dataDictionary[@"results"];
            self.filteredMovies=self.movies;
            [self.collectionView reloadData];
            [self.activityIndicator stopAnimating];
            
            
            
            // TODO: Get the array of movies
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
        }
         [self.refreshControl endRefreshing];
        
    }];
    [task resume];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell * tappedCell= sender;
    NSIndexPath * indexPath=[self.collectionView indexPathForCell:tappedCell];
    NSDictionary * movie= self.movies[indexPath.item];
    DetailsViewController * detailsViewControl=[segue destinationViewController];
    detailsViewControl.movie=movie;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:(@"MovieCollectionCell") forIndexPath:indexPath];
    NSDictionary * movie=self.filteredMovies[indexPath.item];
    NSString *baseURLString=@"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString=movie[@"poster_path"];
    NSString *fullPosterURLString= [baseURLString stringByAppendingString:posterURLString];
    NSURL * posterURL = [NSURL URLWithString:fullPosterURLString];
      NSURLRequest * request =[NSURLRequest requestWithURL: posterURL];
    [cell.posterView setImageWithURL:posterURL];
    
         [cell.posterView setImageWithURLRequest: request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
          
                NSLog(@"Image was NOT cached, fade in image");
                cell.posterView.alpha = 0;
                cell.posterView.image = image;
                [UIView animateWithDuration: .7 animations:^{
                   cell.posterView.alpha = 1.0;
                }];
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
    [self.collectionView reloadData];
}

    



@end
