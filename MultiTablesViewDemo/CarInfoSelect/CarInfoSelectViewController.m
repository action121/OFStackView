//
//  CarInfoSelectViewController.m
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/8.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import "CarInfoSelectViewController.h"
#import "OFStackView.h"
#import "UIView+Oxygen.h"
#import "CarInfoSelectTableViewCell.h"
#import "GridItem.h"
#import "TopBrandsTableViewCell.h"
#import "GDIIndexBar.h"
#import "pinyin.h"
#import "NSString+Oxygen.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define tabBarHeight (!self.tabBarController ? 0 : ( self.hidesBottomBarWhenPushed ? 0 : self.tabBarController.tabBar.height))
#define navibarHeight (isIOS_X(7.0)?64:44)
#define isIOS_X(systemVersionfloatArgs) ([UIDevice currentDevice].systemVersion.floatValue >= (systemVersionfloatArgs) ? YES : NO)
#define bodyHeight  (self.view.frame.size.height - navibarHeight - tabBarHeight)

#define MEMU_TABLEVIEW_COUNT    3
#define RECOMMEND_LETTER        @"★"

@interface CarInfoSelectViewController ()<OFStackViewDataSource,OFStackViewDelegate,UITableViewDataSource,UITableViewDelegate,GridItemViewDelegate,GDIIndexBarDelegate>
@property(nonatomic,strong)OFStackView* stackView;
@property(nonatomic,strong)UITableView* tableview1;
@property(nonatomic,strong)UITableView* tableview2;
@property(nonatomic,strong)UITableView* tableview3;

@property (strong, nonatomic) GDIIndexBar *indexBar;

@property (strong, nonatomic) NSMutableArray *brandSectionNames;
@property (strong, nonatomic)NSMutableDictionary* brandDic;
@property (strong, nonatomic) NSMutableArray *recommendBrandArray;

@property (strong, nonatomic) NSMutableArray *modelArray;
@property (strong, nonatomic) NSMutableArray *displacementArray;


@end

@implementation CarInfoSelectViewController
-(NSArray*)array4test{
    NSArray* array =
    @[
      @{@"id":@"4",@"name":@"大众",@"logoPath":@"http://a.hiphotos.baidu.com/zhidao/wh%3D600%2C800/sign=0999c33a612762d0806bacb990dc24c2/43a7d933c895d1430d3e983a71f082025aaf075a.jpg"},
      @{@"id":@"23",@"name":@"现代",@"logoPath":@"http://www.chebz.com/uploads/allimg/141024/1-1410242359540-L.jpg"},
      @{@"id":@"14",@"name":@"马自达",@"logoPath":@"http://static.cpsdna.com/laso/images/vehicle_logo/mazda.png"},
      @{@"id":@"16",@"name":@"雪佛兰",@"logoPath":@"http://img.weixinyidu.com/151205/e0cbe369.jpg_slt2"},
      @{@"id":@"13",@"name":@"别克",@"logoPath":@"http://cdnweb.b5m.com/web/cmsphp/article/201506/39b2b3a9b9bae9922af95b67a528a9e7.jpg"},
      @{@"id":@"2",@"name":@"宝马",@"logoPath":@"http://upload1.techweb.com.cn/s/320/2015/0422/1429686729929.jpg"},
      @{@"id":@"18",@"name":@"丰田",@"logoPath":@"http://www.cldol.com/newbrand/upload/faw-toyota-new-logo_04.jpg"},
      @{@"id":@"10",@"name":@"福特",@"logoPath":@"http://image.bitauto.com/dealer/news/100019194/3e9251c2-52ab-4a90-8ed5-3ac0f75a2d91.jpg"}
      ];
    return array;
}
- (void)createBrandData:(NSArray*)brandArray
{
    self.brandDic = [NSMutableDictionary dictionary];
    self.brandSectionNames = [NSMutableArray array];
    self.recommendBrandArray = [[NSMutableArray alloc] initWithCapacity:0];
    //for debug
    NSArray* array = [self array4test];
    for (int i = 0; i < array.count; i++) {
        GridItem* itemInfo = [[GridItem alloc] init];
        NSDictionary* itemDic = array[i];
        itemInfo.itemDescription = itemDic[@"name"];
        itemInfo.imageUrl = itemDic[@"logoPath"];
        NSString *firstLetter = [self getFirstLetter:itemInfo.itemDescription];
        itemInfo.identification = [NSString stringWithFormat:@"%@-%@",firstLetter,@(i)];
        [_recommendBrandArray addObject:itemInfo];
    }

    
    [brandArray enumerateObjectsUsingBlock:^(GridItem* itemInfo, NSUInteger idx, BOOL *stop) {
        
        NSString *firstLetter = [self getFirstLetter:itemInfo.itemDescription];
        
        NSMutableArray *namesByFirstLetter = [_brandDic objectForKey:firstLetter];
        
        if (!namesByFirstLetter) {
            namesByFirstLetter = [NSMutableArray array];
            [_brandDic setObject:namesByFirstLetter forKey:firstLetter];
            [self.brandSectionNames addObject:firstLetter];
        }
        
        [namesByFirstLetter addObject:itemInfo];
    }];
    
    
    NSArray *nameLists = [_brandDic allValues];
    [nameLists enumerateObjectsUsingBlock:^(NSMutableArray *namesByFirstLetter, NSUInteger idx, BOOL *stop) {
        [namesByFirstLetter sortUsingComparator:^NSComparisonResult(GridItem* item1, GridItem* item2) {
            return [item1.itemDescription compare:item2.itemDescription];
        }];
    }];
    
    
    [self.brandSectionNames sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
        return [name1 compare:name2];
    }];
    if (_recommendBrandArray.count > 0) {
        [self.brandSectionNames insertObject:RECOMMEND_LETTER atIndex:0];
        [self.brandDic setObject:_recommendBrandArray forKey:RECOMMEND_LETTER];
    }
}
-(NSString*)getFirstLetter:(NSString*)fromString{
    if ([NSString isStringEmpty:fromString]) {
        return @"#";
    }
    unichar aChar = [fromString characterAtIndex:0];
    NSString *firstLetter = nil;
    if ((aChar >= 'A' && aChar <= 'Z') ||
        (aChar >= 'a' && aChar <= 'z') ) {
        firstLetter = [[NSString stringWithFormat:@"%c", aChar] uppercaseString];
    }else if (isFirstLetterHANZI(aChar)) {
        unichar pinyinChar = pinyinFirstLetter(aChar);
        firstLetter = [[NSString stringWithFormat:@"%c", pinyinChar] uppercaseString];
    }else{
        firstLetter = @"#";
    }
    
    return firstLetter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (isIOS_X(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect stackViewFrame = self.view.bounds;
    stackViewFrame.size.height = bodyHeight;
    _stackView = [[OFStackView alloc] initWithFrame:stackViewFrame];
    _stackView.dataSource = self;
    _stackView.delegate = self;
    [self.view addSubview:_stackView];
    
    [self getDataWith:0];
    [_stackView reloadData];
   
}
-(UITableView*)tableview1{
    if (!_tableview1) {
        _tableview1 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableview1.dataSource = self;
        _tableview1.delegate = self;
        _tableview1.tableFooterView = [[UIView alloc] init];
    }
    return _tableview1;
}
-(UITableView*)tableview2{
    if (!_tableview2) {
        _tableview2 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableview2.dataSource = self;
        _tableview2.delegate = self;
         _tableview2.tableFooterView = [[UIView alloc] init];
    }
    return _tableview2;
}
-(UITableView*)tableview3{
    if (!_tableview3) {
        _tableview3 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableview3.dataSource = self;
        _tableview3.delegate = self;
         _tableview3.tableFooterView = [[UIView alloc] init];
    }
    return _tableview3;
}
-(void)getDataWith:(NSInteger)index{
    
    //for debug
    if (index == 0) {
        NSArray* array = [self array4test];
        NSMutableArray* brandArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < array.count; i++) {
            GridItem* itemInfo = [[GridItem alloc] init];
            NSDictionary* itemDic = array[i];
            itemInfo.itemDescription = itemDic[@"name"];
            itemInfo.imageUrl = itemDic[@"logoPath"];
            NSString *firstLetter = [self getFirstLetter:itemInfo.itemDescription];
            itemInfo.identification = [NSString stringWithFormat:@"%@-%@",firstLetter,@(i)];
            [brandArray addObject:itemInfo];
        }
        [self createBrandData:brandArray];
        [self.tableview1 reloadData];
        [self.indexBar reload];
    }else if (index == 1) {
        _modelArray = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            GridItem* itemInfo = [[GridItem alloc] init];
            NSString* brandName = self.currentSelectedBrandItem.itemDescription;
            itemInfo.itemDescription = [NSString stringWithFormat:@"%@%@",brandName,@(i)];
            NSString *firstLetter = [self getFirstLetter:itemInfo.itemDescription];
            itemInfo.identification = [NSString stringWithFormat:@"%@-%@",firstLetter,@(i)];
            [_modelArray addObject:itemInfo];
        }
        [self.tableview2 reloadData];
    }else if (index == 2) {
        NSArray* array = @[@"1.8L",@"2.0L"];
        _displacementArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            GridItem* itemInfo = [[GridItem alloc] init];
            itemInfo.itemDescription = array[i];
            NSString *firstLetter = [self getFirstLetter:itemInfo.itemDescription];
            itemInfo.identification = [NSString stringWithFormat:@"%@-%@",firstLetter,@(i)];
            [_displacementArray addObject:itemInfo];
        }
        [self.tableview3 reloadData];
    }
}
-(void)GridItemViewClick:(GridItemView *)itemView{
    NSLog(itemView.itemInfo.itemDescription);
    if (![NSString isStringEmpty:itemView.itemInfo.identification]) {
        NSArray* splitArray = [itemView.itemInfo.identification componentsSeparatedByString:@"-"];
        NSInteger section = [self.brandSectionNames indexOfObject:splitArray[0]] ;
        NSArray* datas = [self.brandDic objectForKey:splitArray[0]];
        for (int i = 0; i < datas.count ; i++) {
            GridItem* itemInfo = datas[i];
            if ([itemInfo.identification isEqualToString:itemView.itemInfo.identification]) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
                [self.tableview1 scrollToRowAtIndexPath:indexPath
                                       atScrollPosition:UITableViewScrollPositionTop
                                               animated:NO];
                __weak typeof(self) weakSelf = self;
                [self.tableview1 selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [_stackView hideStackViewFromIndex:1 animated:NO completion:^{
                    [_stackView showStackViewAtIndex:1 animated:YES completion:^(){
                        [weakSelf getDataWith:1];
                    }];
                }];
                _currentSelectedBrandItem = itemInfo;
                break;
            }
        }
    }
}

#pragma mark - stackView delegate
- (NSInteger)numberOfStackView:(OFStackView *)stackView {
    return MEMU_TABLEVIEW_COUNT;
}
-(CGFloat)stackView:(OFStackView *)stackView viewOffSetAtIndex:(NSInteger)index{
    if (index == 0) {
        return 0;
    }else if(index == 1){
        return 64;
    }else if (index == 2){
        return 170;
    }
    return stackView.width;
}
- (UIView *)stackView:(OFStackView *)stackView customViewAtIndex:(NSInteger)index withContainerView:(UIView*)containerView{
    switch (index) {
        case 0:
            self.tableview1.frame = containerView.bounds;
            if (!self.indexBar) {
                self.indexBar = [[GDIIndexBar alloc] initWithTableView:self.tableview1];
                self.indexBar.delegate = self;
                self.indexBar.textColor = THEME_TINT_COLOR;
                self.indexBar.textSpacing = 5.f;
                self.indexBar.textFont = [UIFont boldSystemFontOfSize:13.5];// [UIFont fontWithName:@"Menlo-Bold" size:13.5f];
                self.indexBar.barBackgroundColor = [UIColor clearColor];
                [containerView addSubview:self.indexBar];
            }

            return self.tableview1;
        case 1:
            self.tableview2.frame = containerView.bounds;
            return self.tableview2;
        case 2:
            self.tableview3.frame = containerView.bounds;
            return self.tableview3;
        default:
            break;
    }
    return nil;
}
-(void)stackView:(OFStackView *)stackView loadDataAtIndex:(NSInteger)index{
    [self getDataWith:index];
}
#pragma mark - tableview delegate
-(NSInteger)indexOfTableView:(UITableView*)tableView{
    NSInteger index = 0;
    if ([tableView isEqual:_tableview1]) {
        index = 0;
    }else if ([tableView isEqual:_tableview2]) {
        index = 1;
    } else if ([tableView isEqual:_tableview3]) {
        index = 2;
    }else{
        index = -1;
    }
    return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger index = [self indexOfTableView:tableView];
    if (index == 0) {
        return self.brandSectionNames.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger index = [self indexOfTableView:tableView];

    if (index == 0) {

        NSInteger sectionIndex = section;
        if (_recommendBrandArray.count > 0
            && section == 0) {
            return 1;
        }
        NSString *letter = [self.brandSectionNames objectAtIndex:sectionIndex];
        NSArray *namesByLetter = [self.brandDic objectForKey:letter];
        
        return namesByLetter.count;
    }

    if ([_stackView viewHiddenAtIndex:index]) {
        return 0;
    }
    if(index == 1){
        return _modelArray.count;
    }else if(index == 2){
        return _displacementArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = [self indexOfTableView:tableView];

    NSString *resuseIdentifier = [NSString stringWithFormat:@"Cell%lu",index];
    if (index == 0
        && indexPath.section == 0
        && _recommendBrandArray.count > 0) {
        resuseIdentifier = @"RecommendCell";
        
        TopBrandsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifier];
        if (!cell) {
            cell = [[TopBrandsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            

            cell.carInfoArray = self.recommendBrandArray;
        }
        return cell;
    }
    
    CarInfoSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifier];
    
    if (!cell) {
        cell = [[CarInfoSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (index == 0) {
        NSInteger sectionIndex = indexPath.section;

        NSString *letter = [self.brandSectionNames objectAtIndex:sectionIndex];
        NSArray *itemArray = [self.brandDic objectForKey:letter];
        GridItem* itemInfo = itemArray[indexPath.row];
        cell.itemInfo = itemInfo;
    }else if(index == 1){
        GridItem* itemInfo = _modelArray[indexPath.row];
        cell.itemInfo = itemInfo;
    }else if (index == 2){
        GridItem* itemInfo =  _displacementArray[indexPath.row];
        cell.itemInfo = itemInfo;
    }

    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     NSInteger index = [self indexOfTableView:tableView];
    if (index == 0 && indexPath.section == 0
        && _recommendBrandArray.count > 0) {
        return 136;
    }
    return 64;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSInteger index = [self indexOfTableView:tableView];
    if (index  == 2) {
        return 0;
    }
    return 30;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
     NSInteger index = [self indexOfTableView:tableView];
    if (index  == 2) {
        return nil;
    }
    NSString* headerViewIdentifier = @"headerViewIdentifier";
    UITableViewHeaderFooterView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewIdentifier];
    UILabel* headerLabel = nil;
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewIdentifier];
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.width, [self tableView:tableView heightForHeaderInSection:section])];
        header.contentView.backgroundColor = [UIColor colorWithRed:0.863 green:0.899 blue:0.916 alpha:1.00];
        headerLabel.font = [UIFont systemFontOfSize:14];
        headerLabel.textColor = THEME_TINT_COLOR;
        headerLabel.tag = 100;
        [header addSubview:headerLabel];
    }
    headerLabel = (UILabel*)[header viewWithTag:100];
   
    if (index == 0) {
        NSInteger sectionIndex = section;
        NSString* letter = [self.brandSectionNames objectAtIndex:sectionIndex];
        if ([letter isEqualToString:RECOMMEND_LETTER]) {
             headerLabel.text = @"热门品牌";
        }else{
            headerLabel.text = letter;
        }

    }else if(index == 1){
        headerLabel.text = _currentSelectedBrandItem.itemDescription;
    }
    
    return header;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger index = [self indexOfTableView:tableView];
    if (index == 0) {
        NSInteger sectionIndex = indexPath.section;
        NSString *letter = [self.brandSectionNames objectAtIndex:sectionIndex];
        NSArray *itemArray = [self.brandDic objectForKey:letter];
        self.currentSelectedBrandItem = itemArray[indexPath.row];
    }else if (index == 1){
        _currentSelectedModelItem = self.modelArray[indexPath.row];
    }else if (index == 2){
        //TODO 不确定结构
        _currentSelectedDisplacementItem = self.displacementArray[indexPath.row];
    }
    
    if (index >= MEMU_TABLEVIEW_COUNT - 1) {
        NSLog(@"任务完成，可以结束了");
        if (_finishHandler) {
            _finishHandler();
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSInteger nextIndex = index + 1;

    __weak typeof(self) weakSelf = self;
    [_stackView hideStackViewFromIndex:nextIndex animated:NO completion:^{
        if (nextIndex == 1) {
            weakSelf.currentSelectedModelItem = nil;
            weakSelf.currentSelectedDisplacementItem = nil;
            [weakSelf.modelArray removeAllObjects];
            weakSelf.modelArray = nil;
            [weakSelf.displacementArray removeAllObjects];
            weakSelf.displacementArray = nil;
            [weakSelf.tableview2 reloadData];
        }else if (nextIndex == 2){
            weakSelf.currentSelectedDisplacementItem = nil;
            [weakSelf.displacementArray removeAllObjects];
            weakSelf.displacementArray = nil;
            [weakSelf.tableview3 reloadData];
        }
        [_stackView showStackViewAtIndex:nextIndex animated:YES completion:^(){
            [weakSelf getDataWith:nextIndex];
        }];
    }];

    
}

#pragma mark - Index bar delegate

- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
{
    return self.brandSectionNames.count;
}

- (NSString *)stringForIndex:(NSUInteger)index
{
    return [self.brandSectionNames objectAtIndex:index];
}

- (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index
{
    NSInteger sectionIndex = index;

    [self.tableview1 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
}

@end
