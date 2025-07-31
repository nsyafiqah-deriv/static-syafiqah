function calculateWeeklyHours(dailyRecords) {
    let totalMinutes = 0;
    let balanceMinutes = 0; // Track balance (negative = deficit, positive = surplus)
    const REQUIRED_HOURS_PER_DAY = 8;
    const REQUIRED_MINUTES_PER_DAY = REQUIRED_HOURS_PER_DAY * 60;
  
    dailyRecords.forEach((day, index) => {
      // Assuming day.startTime and day.endTime are Date objects or time strings like "HH:MM"
      // For simplicity, let's assume they are "HH:MM" strings
      const parseTime = (timeString) => {
        const [hours, minutes] = timeString.split(':').map(Number);
        return hours * 60 + minutes; // Convert to total minutes from midnight
      };
  
      const startTimeMinutes = parseTime(day.startTime);
      const endTimeMinutes = parseTime(day.endTime);
  
      let dailyWorkingMinutes = endTimeMinutes - startTimeMinutes;
  
      // Deduct break minutes if provided
      if (day.breakMinutes) {
        dailyWorkingMinutes -= day.breakMinutes;
      }
  
      // Calculate daily balance (how much over/under the 8-hour requirement)
      const dailyBalance = dailyWorkingMinutes - REQUIRED_MINUTES_PER_DAY;
      
      // Add to running balance
      balanceMinutes += dailyBalance;
      
      totalMinutes += dailyWorkingMinutes;
    });
  
    // Convert total minutes to hours and remaining minutes
    const totalHours = Math.floor(totalMinutes / 60);
    const remainingMinutes = totalMinutes % 60;
    
    // Convert balance to hours and minutes
    const balanceHours = Math.floor(balanceMinutes / 60);
    const balanceRemainingMinutes = balanceMinutes % 60;
  
    return {
      hours: totalHours,
      minutes: remainingMinutes,
      balanceHours: balanceHours,
      balanceMinutes: balanceRemainingMinutes,
      totalBalanceMinutes: balanceMinutes,
      requiredHoursPerDay: REQUIRED_HOURS_PER_DAY
    };
  }
  
  // Example usage:
  const weeklyTimesheet = [
    { day: 'Monday', startTime: '09:00', endTime: '17:30', breakMinutes: 30 },
    { day: 'Tuesday', startTime: '09:00', endTime: '17:30', breakMinutes: 30 },
    { day: 'Wednesday', startTime: '09:00', endTime: '17:00', breakMinutes: 45 },
    { day: 'Thursday', startTime: '09:00', endTime: '18:00', breakMinutes: 60 },
    { day: 'Friday', startTime: '09:00', endTime: '16:30', breakMinutes: 30 },
    // Add more days as needed
  ];
  
  const weeklyTotal = calculateWeeklyHours(weeklyTimesheet);
  console.log(`Total weekly working hours: ${weeklyTotal.hours} hours and ${weeklyTotal.minutes} minutes.`);
  console.log(`Balance: ${weeklyTotal.balanceHours} hours and ${weeklyTotal.balanceMinutes} minutes.`);