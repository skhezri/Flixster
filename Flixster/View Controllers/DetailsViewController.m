//
//  DetailsViewController.m
//  Flixster
//
//  Created by Sophia Khezri on 6/28/18.
//  Copyright © 2018 Sophia Khezri. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *baseURLString=@"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString=self.movie[@"poster_path"];
    NSString *fullPosterURLString= [baseURLString stringByAppendingString:posterURLString];
    
    NSURL * posterURL = [NSURL URLWithString:fullPosterURLString];
    [self.posterView setImageWithURL:posterURL];
    
                         

    NSString *backgroundURLString=self.movie[@"backdrop_path"];
    NSString *fullBackgroundURLString= [baseURLString stringByAppendingString: backgroundURLString];
    NSURL * backgroundURL = [NSURL URLWithString:fullBackgroundURLString];
    [self.backgroundView setImageWithURL: backgroundURL];
    
    self.titleLabel.text=self.movie[@"title"];
    self.synopsisLabel.text=self.movie[@"overview"];
    
    [self.titleLabel sizeToFit];
     [self.synopsisLabel sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
