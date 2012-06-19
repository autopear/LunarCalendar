#import <Foundation/Foundation.h>

@interface LunarCalendar : NSObject
{
    struct SolarTerm
    {
        NSString *solarName;
        int solarDate;
    };
    
    NSArray *HeavenlyStems;
    NSArray *EarthlyBranches;
    NSArray *LunarZodiac;
    NSArray *SolarTerms;
    NSArray *arrayMonth;
    NSArray *arrayDay;

    NSDate *thisdate;
    
    int year;
    int month;
    int day;
    
    int lunarYear;       //农历年
    int lunarMonth;      //农历月
    int doubleMonth;     //闰月
    bool isLeap;         //是否闰月标记
    int lunarDay;        //农历日
    
    struct SolarTerm solarTerm[2];
    
    NSString *yearHeavenlyStem;
    NSString *monthHeavenlyStem;
    NSString *dayHeavenlyStem;
    
    NSString *yearEarthlyBranch;
    NSString *monthEarthlyBranch;
    NSString *dayEarthlyBranch;
    
    NSString *monthLunar;
    NSString *dayLunar;
    
    NSString *zodiacLunar;
    
    NSString *solarTermTitle; 
}

-(void)loadWithDate:(NSDate *)date;

-(void)InitializeValue;
-(int)LunarYearDays:(int)y;
-(int)DoubleMonth:(int)y;
-(int)DoubleMonthDays:(int)y;
-(int)MonthDays:(int)y:(int)m;
-(void)ComputeSolarTerm;

-(double)Term:(int)y:(int)n:(bool)pd;
-(double)AntiDayDifference:(int)y:(double)x;
-(double)EquivalentStandardDay:(int)y:(int)m:(int)d;
-(int)IfGregorian:(int)y:(int)m:(int)d:(int)opt;
-(int)DayDifference:(int)y:(int)m:(int)d;
-(double)Tail:(double)x;

-(NSString *)MonthLunar;
-(NSString *)DayLunar;
-(NSString *)ZodiacLunar;
-(NSString *)YearHeavenlyStem;
-(NSString *)MonthHeavenlyStem;
-(NSString *)DayHeavenlyStem;
-(NSString *)YearEarthlyBranch;
-(NSString *)MonthEarthlyBranch;
-(NSString *)DayEarthlyBranch;
-(NSString *)SolarTermTitle;
-(bool)IsLeap;
-(int)GregorianYear;
-(int)GregorianMonth;
-(int)GregorianDay;
-(int)Weekday;
-(NSString *)Constellation;

@end
