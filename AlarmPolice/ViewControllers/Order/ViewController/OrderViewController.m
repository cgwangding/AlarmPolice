//
//  OrderViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/8.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "OrderViewController.h"
#import "AddressCell.h"
#import "CustomCalandarView.h"
#import "OrderSucceessView.h"
#import "JCAlertView.h"
#import "OrderModel.h"
#import "WDTextView.h"

@interface OrderViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    int flagArr[3];
    int addrSelArr[999];
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *certainButton;
@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (strong, nonatomic) UIView *choosenDateView;
@property (strong, nonatomic) UILabel *choosenDateLabel;
@property (strong, nonatomic) UIButton *choosenDateButton;

@property (strong, nonatomic) UIView *choosenAddrView;
@property (strong, nonatomic) UILabel *choosenAddrLabel;
@property (strong, nonatomic) UIButton *choosenAddrButton;

@property (strong, nonatomic) UIView *suggestView;
@property (strong, nonatomic) UILabel *suggestLabel;
@property (strong, nonatomic) UIButton *suggestButton;

@property (assign, nonatomic) CGFloat calandarHeight;

@property (strong, nonatomic) CustomCalandarView *calandarView;

@property (strong, nonatomic) NSString *orderDateStr;
@property (copy, nonatomic) NSString *orderAddrStr;

//用于接口提交
@property (copy, nonatomic) NSString *orderedDate;
@property (copy, nonatomic) NSString *orderedAddrID;

@property (strong, nonatomic) WDTextView *textView;

- (IBAction)messageButtonClicked:(id)sender;
- (IBAction)certainButtonClicked:(id)sender;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupWidget];
    flagArr[0] = 1;
    flagArr[1] = 1;
    flagArr[2] = 1;
    memset(&addrSelArr, 0, 999);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self orderAddress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        memset(&addrSelArr, 0, 999);
        addrSelArr[indexPath.row] = 1;
        [tableView reloadData];
        
        OrderAddr *model = self.infoDataArray[indexPath.row];
        self.orderedAddrID = model.policeID;
        self.choosenAddrLabel.text = model.police;
        self.orderAddrStr = self.choosenAddrLabel.text;
        [self performSelector:@selector(addressChoosenButtonClicked:) withObject:self.choosenAddrButton];
        if (self.orderDateStr) {
            self.certainButton.enabled = YES;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (flagArr[section] > 0) {
            return 1;
        }else{
            return 0;
        }
    }
    if (section == 1 ) {
        if (flagArr[section] > 0) {
            return self.infoDataArray.count;
        }else{
            return 0;
        }
    }
    if (section == 2) {
        if (flagArr[section] > 0) {
            return 1;
        }else{
            return 0;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"fasf";
    static NSString *addrCellIdentifier = @"addressCellIdentifier";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell.contentView addSubview:self.calandarView];
        return cell;
    }
    
    if (indexPath.section == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell.contentView addSubview:self.textView];
        return cell;
    }
    
    AddressCell *addCell = [tableView dequeueReusableCellWithIdentifier:addrCellIdentifier];
    if (addCell == nil) {
        addCell  = [[[NSBundle mainBundle] loadNibNamed:@"AddressCell" owner:self options:nil] lastObject];
    }
    addCell.backgroundColor = RGB(250, 250, 250);
    OrderAddr *model = self.infoDataArray[indexPath.row];
    addCell.addressLabel.text = model.police;
    if (addrSelArr[indexPath.row] == 1) {
        addCell.chooseButton.selected = YES;
    }else{
        addCell.chooseButton.selected = NO;
    }
    return addCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (flagArr[indexPath.section] <= 0) {
            return 0;
        }
        if (self.calandarHeight) {
            return self.calandarHeight;
        }
        return 362 * Screen_Width / 375.0;
    }
    
    if (indexPath.section == 2) {
        if (flagArr[indexPath.section] < 1) {
            return 0;
        }
        return 190;
    }
    if (flagArr[indexPath.section] <= 0) {
        return  0;
    }
    return 58.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return self.choosenDateView;
    }
    if (section == 2) {
        return self.suggestView;
    }
    return self.choosenAddrView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

#pragma mark - HTTP

- (void)orderAddress
{
    APShowLoading;
    __weak typeof(self) weakSelf = self;
    [APIManager orderAddressWithParams:@{} success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        OrderModel *model = [OrderModel mj_objectWithKeyValues:dict];
        [strongSelf.infoDataArray removeAllObjects];
        [strongSelf.infoDataArray addObjectsFromArray:model.Data.model];
        [strongSelf.tableView reloadData];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.infoDataArray removeAllObjects];
        [strongSelf.tableView reloadData];
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        APShowServiceError;
        [strongSelf.infoDataArray removeAllObjects];
        [strongSelf.tableView reloadData];
    }];
}

- (void)order
{
    NSDictionary *params = @{@"orderTime":self.orderedDate,@"tokenID":UUID,@"police":self.orderAddrStr,@"policeID":self.orderedAddrID};
    if (self.textView.text != nil) {
        params = @{@"orderTime":self.orderedDate,@"tokenID":UUID,@"police":self.orderAddrStr,@"policeID":self.orderedAddrID,@"wordes":self.textView.text};
    }
    APShowLoading;
    __weak typeof(self) weakSelf = self;
    [APIManager orderedWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        OrderSucceessView *view = [ OrderSucceessView shardSuccessView];
        view.orderAddrLabel.text = strongSelf.orderAddrStr;
        view.orderDateLabel.text = strongSelf.orderDateStr;
        [view show];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        APShowServiceError;
    }];
}

#pragma mark - override
- (UIColor *)navigaitonBarBackgroundColor
{
    return [UIColor whiteColor];
}

#pragma mark  - private
- (void)setupWidget
{
    [self.certainButton setBackgroundImage:[UIImage imageWithColor:[[UIColor colorWithHex:0x3A4B76] colorWithAlphaComponent:0.1] size:CGSizeMake(Screen_Width, 100)] forState:UIControlStateDisabled];
    [self.certainButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x3A4B76] size:CGSizeMake(Screen_Width, 100)] forState:UIControlStateNormal];
    [self.certainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 10)];
    view.backgroundColor = RGB(243, 243, 247);
    self.tableView.tableHeaderView = view;
    
    
    
}

#pragma mark - button action

- (IBAction)messageButtonClicked:(id)sender {
    
    [JCAlertView showOneButtonWithTitle:@"温馨提示" Message:@"待补充" ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"知道了" Click:^{
        
    }];
}

- (IBAction)certainButtonClicked:(id)sender {
    [self order];
    
}

- (void)dateChoosenButtonClicked:(UIButton*)button
{
    DDLog(@"%p",button);
    if (CGAffineTransformIsIdentity(self.choosenDateButton.transform) == NO) {
        //是否已经旋转过了，如果旋转过了，说明需要变回展开
        flagArr[0] = 1;
        self.choosenDateButton.transform = CGAffineTransformIdentity;
    }else{
        //如果没有，说明需要收回
        flagArr[0] = -1;
        self.choosenDateButton.transform = CGAffineTransformMakeRotation(M_PI);
        
    }
    [self.tableView reloadData];
}

- (void)addressChoosenButtonClicked:(UIButton*)button
{
    if (CGAffineTransformIsIdentity(self.choosenAddrButton.transform) == NO) {
        //是否已经旋转过了，如果旋转过了，说明需要变回展开
        flagArr[1] = 1;
        self.choosenAddrButton.transform = CGAffineTransformIdentity;
    }else{
        //如果没有，说明需要收回
        flagArr[1] = -1;
        self.choosenAddrButton.transform = CGAffineTransformMakeRotation(M_PI);
        
    }
    [self.tableView reloadData];
    
}

- (void)suggestButtonClicked:(UIButton*)button
{
    if (CGAffineTransformIsIdentity(self.suggestButton.transform) == NO) {
        //是否已经旋转过了，如果旋转过了，说明需要变回展开
        flagArr[2] = 1;
        self.suggestButton.transform = CGAffineTransformIdentity;
    }else{
        //如果没有，说明需要收回
        flagArr[2] = -1;
        self.suggestButton.transform = CGAffineTransformMakeRotation(M_PI);
        
    }
    [self.tableView reloadData];
}

#pragma mark - helper
- (NSString*)weekdayNameWithSymbol:(NSInteger)symbol
{
    NSString *weekday = nil;
    switch (symbol) {
        case 1:
            weekday = @"周日";
            break;
        case 2:
            weekday = @"周一";
            
            break;
        case 3:
            weekday = @"周二";
            
            break;
        case 4:
            weekday = @"周三";
            
            break;
        case 5:
            weekday = @"周四";
            
            break;
        case 6:
            weekday = @"周五";
            
            break;
        case 7:
            weekday = @"周六";
            
            break;
            
        default:
            break;
    }
    return weekday;
}

#pragma mark - getter

- (UIView *)choosenAddrView
{
    if (_choosenAddrView == nil) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 60)];
        view.backgroundColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 35, view.height)];
        [button setImage:[UIImage imageNamed:@"address"] forState:UIControlStateNormal];
        button.userInteractionEnabled = NO;
        [view addSubview:button];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.maxX, 0, 84, view.height)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor  = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        label.text = @"请选择办理处";
        [view addSubview:label];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(view.width - 35, 0, 35, view.height);
        [leftButton setImage:[UIImage imageNamed:@"drop_down"] forState:UIControlStateNormal];
        [view addSubview:leftButton];
        [leftButton addTarget:self action:@selector(addressChoosenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.choosenAddrButton = leftButton;
        if (flagArr[1] < 1) {
            leftButton.transform = CGAffineTransformMakeRotation(M_PI);
        }
        
        UILabel *choosenLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.maxX + 5, 0, leftButton.x - label.maxX, view.height)];
        choosenLabel.textAlignment = NSTextAlignmentRight;
        
        choosenLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        choosenLabel.font = [UIFont systemFontOfSize:14];
        [view addSubview:choosenLabel];
        self.choosenAddrLabel = choosenLabel;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, view.height - 1, view.width, 1)];
        line.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [view addSubview:line];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.width, 1)];
        line2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [view addSubview:line2];
        
        _choosenAddrView = view;
    }
    return _choosenAddrView;
}

- (UIView *)choosenDateView
{
    if (_choosenDateView == nil) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 60)];
        view.backgroundColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 35, view.height)];
        [button setImage:[UIImage imageNamed:@"calandar"] forState:UIControlStateNormal];
        button.userInteractionEnabled = NO;
        [view addSubview:button];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.maxX, 0, 84, view.height)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor  = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        label.text = @"选择办理日期";
        [view addSubview:label];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(view.width - 35, 0, 35, view.height);
        [leftButton setImage:[UIImage imageNamed:@"drop_down"] forState:UIControlStateNormal];
        [view addSubview:leftButton];
        [leftButton addTarget:self action:@selector(dateChoosenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.choosenDateButton = leftButton;
        if (flagArr[0] < 1) {
            leftButton.transform = CGAffineTransformMakeRotation(M_PI);
        }
        
        UILabel *choosenLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.maxX + 5, 0, leftButton.x - label.maxX, view.height)];
        choosenLabel.textAlignment = NSTextAlignmentRight;
        choosenLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        choosenLabel.font = [UIFont systemFontOfSize:14];
        [view addSubview:choosenLabel];
        self.choosenDateLabel = choosenLabel;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, view.height - 1, view.width, 1)];
        line.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [view addSubview:line];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.width, 1)];
        line2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [view addSubview:line2];
        
        _choosenDateView = view;
    }
    return _choosenDateView;
}

- (UIView *)suggestView
{
    if (_suggestView == nil) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 60)];
        view.backgroundColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 35, view.height)];
        [button setImage:[UIImage imageNamed:@"sugg"] forState:UIControlStateNormal];
        button.userInteractionEnabled = NO;
        [view addSubview:button];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.maxX, 0, 84, view.height)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor  = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        label.text = @"意见与反馈";
        [view addSubview:label];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(view.width - 35, 0, 35, view.height);
        [leftButton setImage:[UIImage imageNamed:@"drop_down"] forState:UIControlStateNormal];
        [view addSubview:leftButton];
        [leftButton addTarget:self action:@selector(suggestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.suggestButton = leftButton;
        if (flagArr[2] < 1) {
            leftButton.transform = CGAffineTransformMakeRotation(M_PI);
        }
        
        UILabel *choosenLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.maxX + 5, 0, leftButton.x - label.maxX, view.height)];
        choosenLabel.textAlignment = NSTextAlignmentRight;
        
        choosenLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        choosenLabel.font = [UIFont systemFontOfSize:14];
        [view addSubview:choosenLabel];
        self.suggestLabel = choosenLabel;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, view.height - 1, view.width, 1)];
        line.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [view addSubview:line];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.width, 1)];
        line2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [view addSubview:line2];
        
        _suggestView = view;
    }
    return _suggestView;
}

- (CustomCalandarView *)calandarView
{
    if (_calandarView == nil) {
        _calandarView = [[CustomCalandarView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 362 * Screen_Width / 375.0)];
        _calandarView.backgroundColor = RGB(251, 251, 251);
        [_calandarView onHeightDidChangedBlock:^(CGFloat tHeight) {
            _calandarHeight = tHeight;
            [_tableView reloadData];
        }];
        
        NSDate *date = [NSDate date];
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitCalendar;
        NSDateComponents *fromComp = [[NSCalendar currentCalendar] components:unit fromDate:date];
        fromComp.timeZone = [NSTimeZone localTimeZone];
        
        //由于周末不可预约，所以要加2天
        NSDate *toDate = [NSDate dateWithDaysFromNow:8];
        if (fromComp.weekday == 6 || fromComp.weekday == 7 || fromComp.weekday == 1) {
            toDate = [NSDate dateWithDaysFromNow:10];
        }
        NSDateComponents *toComp = [[NSCalendar currentCalendar]components:unit fromDate:toDate];
        toComp.timeZone = [NSTimeZone localTimeZone];
        
        __weak typeof(self) weakSelf = self;
        [_calandarView onSelectedItemBlock:^(BaseItem *item) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            DateModel *model = item.model;
            NSDateComponents *curComp = [[NSDateComponents alloc]init];
            curComp.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            curComp.year = model.year;
            curComp.month = model.month;
            curComp.day = model.day;
            curComp.weekday = model.weekday;
            
            ;
            NSInteger afterDays = [date distanceInDaysToDate:curComp.date];
            NSString *dateStr = [NSString stringWithFormat:@"%lu月%lu日 %@",model.month,model.day,[strongSelf weekdayNameWithSymbol:model.weekday]];
            if (afterDays == 0 && fromComp.day == model.day) {
                dateStr = [dateStr stringByAppendingString:@"(今天)"];
            }else{
                dateStr = [dateStr stringByAppendingFormat:@"(%lu天后)",afterDays+1];
            }
            
            NSRange range = [dateStr rangeOfString:@"("];
            
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:dateStr];
            //            _choosenDateLabel.
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, dateStr.length)];
            [attr addAttribute:NSForegroundColorAttributeName value:[[UIColor blackColor] colorWithAlphaComponent:.6] range:NSMakeRange(0, dateStr.length)];
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(range.location, dateStr.length - range.location)];
            [attr addAttribute:NSForegroundColorAttributeName value:[[UIColor blackColor] colorWithAlphaComponent:0.4] range:NSMakeRange(range.location, dateStr.length - range.location)];
            _choosenDateLabel.attributedText = attr;
            strongSelf.orderDateStr = dateStr;
            [strongSelf performSelector:@selector(dateChoosenButtonClicked:) withObject:self.choosenDateButton];
            
            if (strongSelf.orderAddrStr) {
                strongSelf.certainButton.enabled = YES;
            }
            
            NSString *orderedDate = [NSString stringWithFormat:@"%lu-%lu-%lu",model.year,model.month,model.day];
            strongSelf.orderedDate = orderedDate;
            
        }];
        
        [_calandarView validDateFormDateComponents:fromComp toDateComponents:toComp andWeekdayValid:NO];
    }
    return _calandarView;
}

- (WDTextView *)textView
{
    if (_textView == nil) {
        _textView = [[WDTextView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 190)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.showsVerticalScrollIndicator = YES;
        _textView.placeholder = @"请留下宝贵建议";
//        _textView.contentInset = UIEdgeInsetsMake(8, 12, 8, 8);
    }
    return _textView;
}

@end