//
//  FiltersViewController.m
//  Yelp
//
//  Created by Jim Challenger on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "SegmentedCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, SegmentedCellDelegate>

@property (nonatomic, readonly) NSDictionary  *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic, strong) NSMutableSet *selectedSorts;
@property BOOL showDeals;
@property BOOL selectedShowDeals;
@property double selectedDistance;

- (void)initCategories;
- (void)initSorts;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
        self.selectedSorts = [NSMutableSet set];
        [self initSorts];
        self.showDeals = false;
        self.selectedShowDeals = false;
        self.selectedDistance = 482.803;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SegmentedCell" bundle:nil] forCellReuseIdentifier:@"SegmentedCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    cell.delegate = self;
    
    // Other
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentedCell"];
        cell.delegate = self;
        return cell;
    }
    // Deals
    if (indexPath.section == 0) {
        cell.titleLabel.text = @"Offering a deal";
        cell.on = self.selectedShowDeals;
    }
    // Sorts
    if (indexPath.section == 2) {
        NSInteger row = indexPath.row;
        cell.titleLabel.text = self.sorts[row][@"name"];
        cell.on = [self.selectedSorts containsObject:self.sorts[row]];
    }
    // Categories
    if (indexPath.section == 3) {
        NSInteger row = indexPath.row;
        cell.titleLabel.text = self.categories[row][@"name"];
        cell.on = [self.selectedCategories containsObject:self.categories[row]];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
            break;
        case 1:
            return @"Distance";
            break;
        case 2:
            return @"Sort by";
            break;
        default:
            return @"Category";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 3;
            break;
        default:
            return self.categories.count;
            break;
    }
}

#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // Deals
    if (indexPath.section == 0) {
        if (value) {
            self.selectedShowDeals = true;
        } else {
            self.selectedShowDeals = false;
        }
    }
    // Sorts
    else if (indexPath.section == 2) {
        NSInteger row = indexPath.row;
        if (value) {
            [self.selectedSorts addObject:self.sorts[row]];
        } else {
            [self.selectedSorts removeObject:self.sorts[row]];
        }
    }
    // Categories
    else if (indexPath.section == 3) {
        NSInteger row = indexPath.row;
        if (value) {
            [self.selectedCategories addObject:self.categories[row]];
        } else {
            [self.selectedCategories removeObject:self.categories[row]];
        }
    }
   
}

- (void)segmentedCell:(SegmentedCell *)cell didUpdateValue:(double)value {
    self.selectedDistance = value;
}

#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    //Deals
    if (self.selectedShowDeals) {
        [filters setValue:[NSNumber numberWithBool:self.selectedShowDeals] forKey:@"deals_filter"];
    }
    // Sorts
    if (self.selectedSorts.count > 0) {
        NSMutableArray *sortValues = [NSMutableArray array];
        for (NSDictionary *sort in self.selectedSorts) {
            [sortValues addObject:sort[@"code"]];
        }
        
        id sortValue = sortValues.lastObject;
        [filters setValue:sortValue forKey:@"sort"];
    }
    // Categories
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    [filters setValue:[NSNumber numberWithDouble:self.selectedDistance] forKey:@"radius_filter"];
    
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
//    NSLog(@"FILTERS: %@", self.filters);
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)initSorts {
    self.sorts =
    @[
      @{@"name": @"Best Matched", @"code": @0},
      @{@"name": @"Distance", @"code": @1},
      @{@"name": @"Highest Rated", @"code": @2}
      ];
}

- (void)initCategories {
    self.categories =
    @[@{@"name": @"Afghan", @"code": @"afghani"},
      @{@"name": @"African", @"code": @"african"},
      @{@"name": @"American, New", @"code": @"newamerican"},
      @{@"name": @"American, Traditional", @"code": @"tradamerican"},
      @{@"name": @"Arabian", @"code": @"arabian"},
      @{@"name": @"Argentine", @"code": @"argentine"},
      @{@"name": @"Armenian", @"code": @"armenian"},
      @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
      @{@"name": @"Asturian", @"code": @"asturian"},
      @{@"name": @"Australian", @"code": @"australian"},
      @{@"name": @"Austrian", @"code": @"austrian"},
      @{@"name": @"Baguettes", @"code": @"baguettes"},
      @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
      @{@"name": @"Barbeque", @"code": @"bbq"},
      @{@"name": @"Basque", @"code": @"basque"},
      @{@"name": @"Bavarian", @"code": @"bavarian"},
      @{@"name": @"Beer Garden", @"code": @"beergarden"},
      @{@"name": @"Beer Hall", @"code": @"beerhall"},
      @{@"name": @"Beisl", @"code": @"beisl"},
      @{@"name": @"Belgian", @"code": @"belgian"},
      @{@"name": @"Bistros", @"code": @"bistros"},
      @{@"name": @"Black Sea", @"code": @"blacksea"},
      @{@"name": @"Brasseries", @"code": @"brasseries"},
      @{@"name": @"Brazilian", @"code": @"brazilian"},
      @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
      @{@"name": @"British", @"code": @"british"},
      @{@"name": @"Buffets", @"code": @"buffets"},
      @{@"name": @"Bulgarian", @"code": @"bulgarian"},
      @{@"name": @"Burgers", @"code": @"burgers"},
      @{@"name": @"Burmese", @"code": @"burmese"},
      @{@"name": @"Cafes", @"code": @"cafes"},
      @{@"name": @"Cafeteria", @"code": @"cafeteria"},
      @{@"name": @"Cajun/Creole", @"code": @"cajun"},
      @{@"name": @"Cambodian", @"code": @"cambodian"},
      @{@"name": @"Canadian", @"code": @"New)"},
      @{@"name": @"Canteen", @"code": @"canteen"},
      @{@"name": @"Caribbean", @"code": @"caribbean"},
      @{@"name": @"Catalan", @"code": @"catalan"},
      @{@"name": @"Chech", @"code": @"chech"},
      @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
      @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
      @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
      @{@"name": @"Chilean", @"code": @"chilean"},
      @{@"name": @"Chinese", @"code": @"chinese"},
      @{@"name": @"Comfort Food", @"code": @"comfortfood"},
      @{@"name": @"Corsican", @"code": @"corsican"},
      @{@"name": @"Creperies", @"code": @"creperies"},
      @{@"name": @"Cuban", @"code": @"cuban"},
      @{@"name": @"Curry Sausage", @"code": @"currysausage"},
      @{@"name": @"Cypriot", @"code": @"cypriot"},
      @{@"name": @"Czech", @"code": @"czech"},
      @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
      @{@"name": @"Danish", @"code": @"danish"},
      @{@"name": @"Delis", @"code": @"delis"},
      @{@"name": @"Diners", @"code": @"diners"},
      @{@"name": @"Dumplings", @"code": @"dumplings"},
      @{@"name": @"Eastern European", @"code": @"eastern_european"},
      @{@"name": @"Ethiopian", @"code": @"ethiopian"},
      @{@"name": @"Fast Food", @"code": @"hotdogs"},
      @{@"name": @"Filipino", @"code": @"filipino"},
      @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
      @{@"name": @"Fondue", @"code": @"fondue"},
      @{@"name": @"Food Court", @"code": @"food_court"},
      @{@"name": @"Food Stands", @"code": @"foodstands"},
      @{@"name": @"French", @"code": @"french"},
      @{@"name": @"French Southwest", @"code": @"sud_ouest"},
      @{@"name": @"Galician", @"code": @"galician"},
      @{@"name": @"Gastropubs", @"code": @"gastropubs"},
      @{@"name": @"Georgian", @"code": @"georgian"},
      @{@"name": @"German", @"code": @"german"},
      @{@"name": @"Giblets", @"code": @"giblets"},
      @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
      @{@"name": @"Greek", @"code": @"greek"},
      @{@"name": @"Halal", @"code": @"halal"},
      @{@"name": @"Hawaiian", @"code": @"hawaiian"},
      @{@"name": @"Heuriger", @"code": @"heuriger"},
      @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
      @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
      @{@"name": @"Hot Dogs", @"code": @"hotdog"},
      @{@"name": @"Hot Pot", @"code": @"hotpot"},
      @{@"name": @"Hungarian", @"code": @"hungarian"},
      @{@"name": @"Iberian", @"code": @"iberian"},
      @{@"name": @"Indian", @"code": @"indpak"},
      @{@"name": @"Indonesian", @"code": @"indonesian"},
      @{@"name": @"International", @"code": @"international"},
      @{@"name": @"Irish", @"code": @"irish"},
      @{@"name": @"Island Pub", @"code": @"island_pub"},
      @{@"name": @"Israeli", @"code": @"israeli"},
      @{@"name": @"Italian", @"code": @"italian"},
      @{@"name": @"Japanese", @"code": @"japanese"},
      @{@"name": @"Jewish", @"code": @"jewish"},
      @{@"name": @"Kebab", @"code": @"kebab"},
      @{@"name": @"Korean", @"code": @"korean"},
      @{@"name": @"Kosher", @"code": @"kosher"},
      @{@"name": @"Kurdish", @"code": @"kurdish"},
      @{@"name": @"Laos", @"code": @"laos"},
      @{@"name": @"Laotian", @"code": @"laotian"},
      @{@"name": @"Latin American", @"code": @"latin"},
      @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
      @{@"name": @"Lyonnais", @"code": @"lyonnais"},
      @{@"name": @"Malaysian", @"code": @"malaysian"},
      @{@"name": @"Meatballs", @"code": @"meatballs"},
      @{@"name": @"Mediterranean", @"code": @"mediterranean"},
      @{@"name": @"Mexican", @"code": @"mexican"},
      @{@"name": @"Middle Eastern", @"code": @"mideastern"},
      @{@"name": @"Milk Bars", @"code": @"milkbars"},
      @{@"name": @"Modern Australian", @"code": @"modern_australian"},
      @{@"name": @"Modern European", @"code": @"modern_european"},
      @{@"name": @"Mongolian", @"code": @"mongolian"},
      @{@"name": @"Moroccan", @"code": @"moroccan"},
      @{@"name": @"New Zealand", @"code": @"newzealand"},
      @{@"name": @"Night Food", @"code": @"nightfood"},
      @{@"name": @"Norcinerie", @"code": @"norcinerie"},
      @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
      @{@"name": @"Oriental", @"code": @"oriental"},
      @{@"name": @"Pakistani", @"code": @"pakistani"},
      @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
      @{@"name": @"Parma", @"code": @"parma"},
      @{@"name": @"Persian/Iranian", @"code": @"persian"},
      @{@"name": @"Peruvian", @"code": @"peruvian"},
      @{@"name": @"Pita", @"code": @"pita"},
      @{@"name": @"Pizza", @"code": @"pizza"},
      @{@"name": @"Polish", @"code": @"polish"},
      @{@"name": @"Portuguese", @"code": @"portuguese"},
      @{@"name": @"Potatoes", @"code": @"potatoes"},
      @{@"name": @"Poutineries", @"code": @"poutineries"},
      @{@"name": @"Pub Food", @"code": @"pubfood"},
      @{@"name": @"Rice", @"code": @"riceshop"},
      @{@"name": @"Romanian", @"code": @"romanian"},
      @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
      @{@"name": @"Rumanian", @"code": @"rumanian"},
      @{@"name": @"Russian", @"code": @"russian"},
      @{@"name": @"Salad", @"code": @"salad"},
      @{@"name": @"Sandwiches", @"code": @"sandwiches"},
      @{@"name": @"Scandinavian", @"code": @"scandinavian"},
      @{@"name": @"Scottish", @"code": @"scottish"},
      @{@"name": @"Seafood", @"code": @"seafood"},
      @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
      @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
      @{@"name": @"Singaporean", @"code": @"singaporean"},
      @{@"name": @"Slovakian", @"code": @"slovakian"},
      @{@"name": @"Soul Food", @"code": @"soulfood"},
      @{@"name": @"Soup", @"code": @"soup"},
      @{@"name": @"Southern", @"code": @"southern"},
      @{@"name": @"Spanish", @"code": @"spanish"},
      @{@"name": @"Steakhouses", @"code": @"steak"},
      @{@"name": @"Sushi Bars", @"code": @"sushi"},
      @{@"name": @"Swabian", @"code": @"swabian"},
      @{@"name": @"Swedish", @"code": @"swedish"},
      @{@"name": @"Swiss Food", @"code": @"swissfood"},
      @{@"name": @"Tabernas", @"code": @"tabernas"},
      @{@"name": @"Taiwanese", @"code": @"taiwanese"},
      @{@"name": @"Tapas Bars", @"code": @"tapas"},
      @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
      @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
      @{@"name": @"Thai", @"code": @"thai"},
      @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
      @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
      @{@"name": @"Trattorie", @"code": @"trattorie"},
      @{@"name": @"Turkish", @"code": @"turkish"},
      @{@"name": @"Ukrainian", @"code": @"ukrainian"},
      @{@"name": @"Uzbek", @"code": @"uzbek"},
      @{@"name": @"Vegan", @"code": @"vegan"},
      @{@"name": @"Vegetarian", @"code": @"vegetarian"},
      @{@"name": @"Venison", @"code": @"venison"},
      @{@"name": @"Vietnamese", @"code": @"vietnamese"},
      @{@"name": @"Wok", @"code": @"wok"},
      @{@"name": @"Wraps", @"code": @"wraps"},
      @{@"name": @"Yugoslav", @"code": @"yugoslav"}];
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
