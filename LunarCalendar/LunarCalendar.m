#import "LunarCalendar.h"

int LunarCalendarInfo[] = { 0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
    0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
    0x04970,0x0a4b0,0x0b4b5,0x06a50,0x06d40,0x1ab54,0x02b60,0x09570,0x052f2,0x04970,
    0x06566,0x0d4a0,0x0ea50,0x06e95,0x05ad0,0x02b60,0x186e3,0x092e0,0x1c8d7,0x0c950,
    0x0d4a0,0x1d8a6,0x0b550,0x056a0,0x1a5b4,0x025d0,0x092d0,0x0d2b2,0x0a950,0x0b557,
    0x06ca0,0x0b550,0x15355,0x04da0,0x0a5b0,0x14573,0x052b0,0x0a9a8,0x0e950,0x06aa0,
    0x0aea6,0x0ab50,0x04b60,0x0aae4,0x0a570,0x05260,0x0f263,0x0d950,0x05b57,0x056a0,
    0x096d0,0x04dd5,0x04ad0,0x0a4d0,0x0d4d4,0x0d250,0x0d558,0x0b540,0x0b6a0,0x195a6,
    0x095b0,0x049b0,0x0a974,0x0a4b0,0x0b27a,0x06a50,0x06d40,0x0af46,0x0ab60,0x09570,
    0x04af5,0x04970,0x064b0,0x074a3,0x0ea50,0x06b58,0x055c0,0x0ab60,0x096d5,0x092e0,
    0x0c960,0x0d954,0x0d4a0,0x0da50,0x07552,0x056a0,0x0abb7,0x025d0,0x092d0,0x0cab5,
    0x0a950,0x0b4a0,0x0baa4,0x0ad50,0x055d9,0x04ba0,0x0a5b0,0x15176,0x052b0,0x0a930,
    0x07954,0x06aa0,0x0ad50,0x05b52,0x04b60,0x0a6e6,0x0a4e0,0x0d260,0x0ea65,0x0d530,
    0x05aa0,0x076a3,0x096d0,0x04bd7,0x04ad0,0x0a4d0,0x1d0b6,0x0d250,0x0d520,0x0dd45,
    0x0b5a0,0x056d0,0x055b2,0x049b0,0x0a577,0x0a4b0,0x0aa50,0x1b255,0x06d20,0x0ada0,
    0x14b63};

@implementation LunarCalendar

-(id)init
{
    HeavenlyStems = [NSArray arrayWithObjects:@"1H",@"2H",@"3H",@"4H",@"5H",@"6H",@"7H",@"8H",@"9H",@"10H",nil];
    EarthlyBranches = [NSArray arrayWithObjects:@"1E",@"2E",@"3E",@"4E",@"5E",@"6E",@"7E",@"8E",@"9E",@"10E",@"11E",@"12E",nil];
    LunarZodiac = [NSArray arrayWithObjects:@"Rat",@"Ox",@"Tiger",@"Rabbit",@"Dragon",@"Snake",@"Horse",@"Goat",@"Monkey",@"Rooster",@"Dog",@"Pig",nil];
    
    SolarTerms = [NSArray arrayWithObjects:@"Start of spring", @"Rain water", @"Awakening of insects", @"Vernal equinox", @"Clear and bright", @"Grain rains", @"Start of summer", @"Grain full", @"Grain in ear", @"Summer solstice", @"Minor heat", @"Major heat", @"Start of autumn", @"Limit of heat", @"White dew", @"Autumnal equinox", @"Cold dew", @"Descent of frost", @"Start of winter", @"Minor snow", @"Major snow", @"Winter solstice", @"Minor cold", @"Major cold", nil];
    
    arrayMonth = [NSArray arrayWithObjects:@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP",  @"OCT", @"NOV", @"DEC", nil];
    
    arrayDay = [NSArray arrayWithObjects:@"1st", @"2nd", @"3rd", @"4th", @"5th", @"6th", @"7th", @"8th", @"9th", @"10th", @"11th", @"12th", @"13th", @"14th", @"15th", @"16th", @"17th", @"18th", @"19th", @"20th", @"21st", @"22nd", @"23rd", @"24th", @"25th", @"26th", @"27th", @"28th", @"29th", @"30th", @"31st", nil];
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)loadWithDate:(NSDate *)adate
{
    if (adate == nil)
        [self loadWithDate:[NSDate date]];
    else
    {
        HeavenlyStems = [NSArray arrayWithObjects:@"1H",@"2H",@"3H",@"4H",@"5H",@"6H",@"7H",@"8H",@"9H",@"10H",nil];
        EarthlyBranches = [NSArray arrayWithObjects:@"1E",@"2E",@"3E",@"4E",@"5E",@"6E",@"7E",@"8E",@"9E",@"10E",@"11E",@"12E",nil];
        LunarZodiac = [NSArray arrayWithObjects:@"Rat",@"Ox",@"Tiger",@"Rabbit",@"Dragon",@"Snake",@"Horse",@"Goat",@"Monkey",@"Rooster",@"Dog",@"Pig",nil];
        
        SolarTerms = [NSArray arrayWithObjects:@"Start of spring", @"Rain water", @"Awakening of insects", @"Vernal equinox", @"Clear and bright", @"Grain rains", @"Start of summer", @"Grain full", @"Grain in ear", @"Summer solstice", @"Minor heat", @"Major heat", @"Start of autumn", @"Limit of heat", @"White dew", @"Autumnal equinox", @"Cold dew", @"Descent of frost", @"Start of winter", @"Minor snow", @"Major snow", @"Winter solstice", @"Minor cold", @"Major cold", nil];
        
        arrayMonth = [NSArray arrayWithObjects:@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP",  @"OCT", @"NOV", @"DEC", nil];
        
        arrayDay = [NSArray arrayWithObjects:@"1st", @"2nd", @"3rd", @"4th", @"5th", @"6th", @"7th", @"8th", @"9th", @"10th", @"11th", @"12th", @"13th", @"14th", @"15th", @"16th", @"17th", @"18th", @"19th", @"20th", @"21st", @"22nd", @"23rd", @"24th", @"25th", @"26th", @"27th", @"28th", @"29th", @"30th", @"31st", nil];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        [dateFormatter setDateFormat:@"yyyy"];
        year = [[dateFormatter stringFromDate:adate] intValue];
        
        [dateFormatter setDateFormat:@"MM"];
        month = [[dateFormatter stringFromDate:adate] intValue];
        
        [dateFormatter setDateFormat:@"dd"];
        day = [[dateFormatter stringFromDate:adate] intValue];
        
        [dateFormatter release];
                
        thisdate = adate;
    }
}

-(void)InitializeValue
{
    NSString *start = @"1900-01-31";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *end = [dateFormatter stringFromDate:thisdate];
    [dateFormatter release];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [f dateFromString:start];
    NSDate *endDate = [f dateFromString:end];
    [f release];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    
    int dayCyclical=(([components day] + 30)/(86400/(3600*24)))+10;

    [gregorianCalendar release];

    int sumdays = [components day];
        
    int tempdays = 0;

    //计算农历年
    for (lunarYear = 1900; lunarYear < 2050 && sumdays > 0; lunarYear++)
    {
        tempdays = [self LunarYearDays:lunarYear];
        sumdays -= tempdays;
    }
    
    if (sumdays < 0)
    {
        sumdays += tempdays;
        lunarYear--;
    }
    
    //计算闰月
    doubleMonth = [self DoubleMonth:lunarYear];
    isLeap = false;
    
    //计算农历月
    for (lunarMonth = 1; lunarMonth < 13 && sumdays > 0; lunarMonth++)
    {
        //闰月
        if (doubleMonth > 0 && lunarMonth == (doubleMonth + 1) && isLeap == false)
        {
            --lunarMonth;
            isLeap = true;
            tempdays = [self DoubleMonthDays:lunarYear];
        }
        else
        {
            tempdays = [self MonthDays:lunarYear:lunarMonth];
        }
        
        //解除闰月
        if (isLeap == true && lunarMonth == (doubleMonth + 1))
        {
            isLeap = false;
        }
        sumdays -= tempdays;
    }
    
    //计算农历日
    if (sumdays == 0 && doubleMonth > 0 && lunarMonth == doubleMonth + 1)
    {
        if (isLeap)
        {
            isLeap = false;
        }
        else
        {
            isLeap = true;
            --lunarMonth;
        }
    }
    
    if (sumdays < 0)
    {
        sumdays += tempdays;
        --lunarMonth;
    }
    
    lunarDay = sumdays + 1;
    
    //计算节气
    [self ComputeSolarTerm];
    
    solarTermTitle = @"";
    for (int i=0; i<2; i++)
    {
        NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
        
        [currentFormatter setDateFormat:@"yyyyMMdd"];
        
        if (solarTerm[i].solarDate == [[currentFormatter stringFromDate:thisdate] intValue])
            solarTermTitle = solarTerm[i].solarName;
        
        [currentFormatter release];
    }

    monthLunar = (NSString *)[arrayMonth objectAtIndex:(lunarMonth - 1)];
    dayLunar = (NSString *)[arrayDay objectAtIndex:(lunarDay - 1)];
    zodiacLunar = (NSString *)[LunarZodiac objectAtIndex:((lunarYear - 4) % 60 % 12)];
    
    yearHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:((lunarYear - 4) % 60 % 10)];
    if ((((year-1900)*12+month+13)%10) == 0)
        monthHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:9];
    else
        monthHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:(((year-1900)*12+month+13)%10-1)];

    dayHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:(dayCyclical%10)];
    
    yearEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:((lunarYear - 4) % 60 % 12)];
    if ((((year-1900)*12+month+13)%12) == 0)
        monthEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:11];
    else
        monthEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:(((year-1900)*12+month+13)%12-1)];
    dayEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:(dayCyclical%12)];
}

-(int)LunarYearDays:(int)y
{
    int i, sum = 348;
    for (i = 0x8000; i > 0x8; i >>= 1)
    {
        if ((LunarCalendarInfo[y - 1900] & i) != 0)
            sum += 1;
    }
    return (sum + [self DoubleMonthDays:y]);
}

-(int)DoubleMonth:(int)y
{
    return (LunarCalendarInfo[y - 1900] & 0xf);
}

///返回农历年闰月的天数
-(int)DoubleMonthDays:(int)y
{
    if ([self DoubleMonth:y] != 0)
        return (((LunarCalendarInfo[y - 1900] & 0x10000) != 0) ? 30 : 29);
    else
        return (0);
}

///返回农历年月份的总天数
-(int)MonthDays:(int)y:(int)m
{
    return (((LunarCalendarInfo[y - 1900] & (0x10000 >> m)) != 0) ? 30 : 29);
}

-(void)ComputeSolarTerm
{
    for (int n = month * 2 - 1; n <= month * 2; n++)
    {
        double Termdays = [self Term:year:n:YES];
        double mdays = [self AntiDayDifference:year:floor(Termdays)];
        //double sm1 = floor(mdays / 100);
        int hour = (int)floor((double)[self Tail:Termdays] * 24);
        int minute = (int)floor((double)([self Tail:Termdays] * 24 - hour) * 60);
        int tMonth = (int)ceil((double)n / 2);
        int tday = (int)mdays % 100;
        
        if (n >= 3)
            solarTerm[n - month * 2 + 1].solarName = [SolarTerms objectAtIndex:(n - 3)];
        else
            solarTerm[n - month * 2 + 1].solarName = [SolarTerms objectAtIndex:(n + 21)];
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:year];
        [components setMonth:tMonth]; 
        [components setDay:tday];
        [components setHour:hour];
        [components setMinute:minute];

        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *ldate = [gregorian dateFromComponents:components];
        
        [gregorian release];
        [components release];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyyMMdd"];
                
        solarTerm[n - month * 2 + 1].solarDate = [[dateFormatter stringFromDate:ldate] intValue];
        [dateFormatter release];
    }
}

-(double)Tail:(double)x
{
    return x - floor(x);
}

-(double)Term:(int)y:(int)n:(bool)pd
{
    //儒略日
    double juD = y * (365.2423112 - 6.4e-14 * (y - 100) * (y - 100) - 3.047e-8 * (y - 100)) + 15.218427 * n + 1721050.71301;
    
    //角度
    double tht = 3e-4 * y - 0.372781384 - 0.2617913325 * n;
    
    //年差实均数
    double yrD = (1.945 * sin(tht) - 0.01206 * sin(2 * tht)) * (1.048994 - 2.583e-5 * y);
    
    //朔差实均数
    double shuoD = -18e-4 * sin(2.313908653 * y - 0.439822951 - 3.0443 * n);
    
    double vs = (pd) ? (juD + yrD + shuoD - [self EquivalentStandardDay:y:1:0] - 1721425) : (juD - [self EquivalentStandardDay:y:1:0] - 1721425);
    return vs;
}

-(double)AntiDayDifference:(int)y:(double)x
{
    int m = 1;
    for (int j = 1; j <= 12; j++)
    {
        int mL = [self DayDifference:y:(j+1):1] - [self DayDifference:y:j:1];
        if (x <= mL || j == 12)
        {
            m = j;
            break;
        }
        else
            x -= mL;
    }
    return 100 * m + x;
}

-(double)EquivalentStandardDay:(int)y:(int)m:(int)d
{
    //Julian的等效标准天数
    double v = (y - 1) * 365 + floor((double)((y - 1) / 4)) + [self DayDifference:y:m:d] - 2;
    
    if (y > 1582)
    {//Gregorian的等效标准天数
        v += -floor((double)((y - 1) / 100)) + floor((double)((y - 1) / 400)) + 2; 
    } 
    return v;
}

-(int)DayDifference:(int)y:(int)m:(int)d
{
    int ifG = [self IfGregorian:y:m:d:1];
    //NSArray *monL = [NSArray arrayWithObjects:, nil];
    NSInteger monL[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (ifG == 1)
        if ((y % 100 != 0 && y % 4 == 0) || (y % 400 == 0))
            monL[2] += 1;
            else
                if (y % 4 == 0)
                    monL[2] += 1;
                    int v = 0;
                    for (int i = 0; i <= m - 1; i++)
                    {
                        v += monL[i];
                    }
    v += d;
    if (y == 1582)
    {
        if (ifG == 1)
            v -= 10;
        if (ifG == -1)
            v = 0;  //infinity 
    }
    return v;
}

-(int)IfGregorian:(int)y:(int)m:(int)d:(int)opt
{
    if (opt == 1)
    {
        if (y > 1582 || (y == 1582 && m > 10) || (y == 1582 && m == 10 && d > 14))
            return (1);     //Gregorian
        else
            if (y == 1582 && m == 10 && d >= 5 && d <= 14)
                return (-1);  //空
            else
                return (0);  //Julian
    }
    
    if (opt == 2)
        return (1);     //Gregorian
    if (opt == 3)
        return (0);     //Julian
    return (-1);
}

-(NSString *)MonthLunar
{
    return monthLunar;
}

-(NSString *)DayLunar
{
    return dayLunar;
}

-(NSString *)ZodiacLunar
{
    return zodiacLunar;
}
-(NSString *)YearHeavenlyStem
{
    return yearHeavenlyStem;
}

-(NSString *)MonthHeavenlyStem
{
    return monthHeavenlyStem;
}

-(NSString *)DayHeavenlyStem
{
    return dayHeavenlyStem;
}

-(NSString *)YearEarthlyBranch
{
    return yearEarthlyBranch;
}

-(NSString *)MonthEarthlyBranch
{
    return monthEarthlyBranch;
}

-(NSString *)DayEarthlyBranch
{
    return dayEarthlyBranch;
}

-(NSString *)SolarTermTitle
{
    return solarTermTitle;
}

-(bool)IsLeap
{
    return isLeap;
}
@end
