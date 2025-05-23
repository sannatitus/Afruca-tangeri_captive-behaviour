# Python script for random selection of daily husbandry videos for recording instantaneous observations of Afruca tangeri in two crabitats (110 tank & tub) at the Sainsbury Wellcome Centre for Neural Circuits and Animal Behaviour throughout 2022-2023. The intention here is to select four observation windows (representing each tide type) within five husbandry weekdays, two non-husbandry weekdays, and three weekend days (which are represented appropriately in terms of frequency) for each photoperiod (Spring, Summer, Fall, Winter) within each crabitat. 
# Composed by Sanna Titus | sannatitus@gmail.com | 1 September 2023

import os
from datetime import datetime, timedelta, time
import random

####################################################################
# LOCATE DATA
####################################################################
folder_path = r'X:\raw\CrabLab\CrabitatCam_daily'
file_names = os.listdir(folder_path)
tank_files = [file for file in file_names if 'tank' in file]
tub_files = [file for file in file_names if 'tub' in file]
# .avis only
def is_avi(file):
    return file.endswith('.avi')
####################################################################
# EXTRACT DATE & TIME
####################################################################
def extract_date_and_time(file_name, tub_tank):
    """
    Args: tub_tank = 'tub' or 'tank'
    """
    date_time_str = file_name[len(tub_tank):-4] 
    
    date_time_parts = date_time_str.split('T')
    
    if len(date_time_parts) == 2:
        date_str, time_str = date_time_parts[0], date_time_parts[1]
        
        time_parts = time_str.split('_')
        
        if len(time_parts) == 3:
            hour, minute, second_milliseconds = time_parts[0], time_parts[1], time_parts[2].split('.')[0]
            
            date_parts = date_str.split('-')
            
            if len(date_parts) == 3:
                year, month, day = date_parts[0], date_parts[1], date_parts[2]
                return (year, month, day, hour, minute, second_milliseconds)
    
    return None

tub_dates_and_times = []
for tub in tub_files:
    if is_avi(tub):
        date_time = extract_date_and_time(tub, 'tub')  
        if date_time:
            tub_dates_and_times.append([date_time, tub])
'''print("Tub Dates and Times:")
print(tub_dates_and_times)'''

tank_dates_and_times = []
for tank in tank_files:
    if is_avi(tank):
        date_time = extract_date_and_time(tank, 'tank')  
        if date_time:
            tank_dates_and_times.append([date_time, tank])
'''print("Tank Dates and Times:")
print(tank_dates_and_times)'''

def categorize_photoperiod(month, day):
    if '02-05' <= f'{month}-{day}' <= '05-04':
        return 'Spring'
    elif '05-05' <= f'{month}-{day}' <= '08-04':
        return 'Summer'
    elif '08-05' <= f'{month}-{day}' <= '11-05':
        return 'Fall'
    elif '11-06' <= f'{month}-{day}' and f'{month}-{day}' <= '12-31':
        return 'Winter'
    elif '01-01' <= f'{month}-{day}' <= '02-04':
        return 'Winter'
    else:
        return 'Unknown'

tub_photoperiods = {'Spring': [], 'Summer': [], 'Fall': [], 'Winter': [], 'Unknown': []}
tank_photoperiods = {'Spring': [], 'Summer': [], 'Fall': [], 'Winter': [], 'Unknown': []}

for tub_date, tub in tub_dates_and_times:
    year, month, day = tub_date[0], tub_date[1], tub_date[2]
    photoperiod = categorize_photoperiod(month, day)
    tub_photoperiods[photoperiod].append(tub)
    print(f"File: {tub}, Date: {year}-{month}-{day}, photoperiod: {photoperiod}")

for tank_date, tank in tank_dates_and_times:
    year, month, day = tank_date[0], tank_date[1], tank_date[2]
    photoperiod = categorize_photoperiod(month, day)
    tank_photoperiods[photoperiod].append(tank)
    print(f"File: {tank}, Date: {year}-{month}-{day}, photoperiod: {photoperiod}")
    
print("Tub Videos by photoperiod:")
for photoperiod, videos in tub_photoperiods.items():
    print(f"{photoperiod}: {videos}")

print("\nTank Videos by photoperiod:")
for photoperiod, videos in tank_photoperiods.items():
    print(f"{photoperiod}: {videos}")
# %% 
# ####################################################################
# Organise by daytype (i.e., weekend days, no husbandry weekdays, husbandry weekdays)
#################################################################### 
def categorize_day_of_week(year, month, day):
    date = datetime(int(year), int(month), int(day))
    day_of_week = date.strftime('%A')
    if day_of_week in ['Saturday', 'Sunday']:
        return 'Weekend'
    elif day_of_week in ['Tuesday', 'Thursday']:
        return 'TuesdayThursday'
    else:
        return 'MondayWednesdayFriday'

tub_photoperiods = {'Spring': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
               'Summer': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
               'Fall': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
               'Winter': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
               'Unknown': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []}}

tank_photoperiods = {'Spring': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
                'Summer': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
                'Fall': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
                'Winter': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []},
                'Unknown': {'Weekend': [], 'TuesdayThursday': [], 'MondayWednesdayFriday': []}}

for tub_date, tub in tub_dates_and_times:
    year, month, day = tub_date[0], tub_date[1], tub_date[2]
    photoperiod = categorize_photoperiod(month, day)
    day_of_week = categorize_day_of_week(year, month, day)
    tub_photoperiods[photoperiod][day_of_week].append(tub)

for tank_date, tank in tank_dates_and_times:
    year, month, day = tank_date[0], tank_date[1], tank_date[2]
    photoperiod = categorize_photoperiod(month, day)
    day_of_week = categorize_day_of_week(year, month, day)
    tank_photoperiods[photoperiod][day_of_week].append(tank)
#%% 
#####################################################################
# Randomly select files 
#################################################################### 
# For each photoperiod and crabitat, grab 3 videos from the weekend, 2 videos from non-husbandry weekdays (Tuesday & Thursday), and 5 videos from husbandry weekdays
def random_select_files(file_list, num_files_to_select):
    if num_files_to_select >= len(file_list):
        return file_list
    return random.sample(file_list, num_files_to_select)

selected_weekend_tub = {photoperiod: random_select_files(tub_photoperiods[photoperiod]['Weekend'], 3) for photoperiod in tub_photoperiods}
selected_weekend_tank = {photoperiod: random_select_files(tank_photoperiods[photoperiod]['Weekend'], 3) for photoperiod in tank_photoperiods}

selected_tue_thu_tub = {photoperiod: random_select_files(tub_photoperiods[photoperiod]['TuesdayThursday'], 2) for photoperiod in tub_photoperiods}
selected_tue_thu_tank = {photoperiod: random_select_files(tank_photoperiods[photoperiod]['TuesdayThursday'], 2) for photoperiod in tank_photoperiods}

selected_mon_wed_fri_tub = {photoperiod: random_select_files(tub_photoperiods[photoperiod]['MondayWednesdayFriday'], 5) for photoperiod in tub_photoperiods}
selected_mon_wed_fri_tank = {photoperiod: random_select_files(tank_photoperiods[photoperiod]['MondayWednesdayFriday'], 5) for photoperiod in tank_photoperiods}

'''print("Randomly Selected Weekend Videos for Tubs:")
for photoperiod, files in selected_weekend_tub.items():
    print(f"{photoperiod}: {files}")

print("\nRandomly Selected Weekend Videos for Tanks:")
for photoperiod, files in selected_weekend_tank.items():
    print(f"{photoperiod}: {files}")

print("\nRandomly Selected TuesdayThursday Videos for Tubs:")
for photoperiod, files in selected_tue_thu_tub.items():
    print(f"{photoperiod}: {files}")

print("\nRandomly Selected TuesdayThursday Videos for Tanks:")
for photoperiod, files in selected_tue_thu_tank.items():
    print(f"{photoperiod}: {files}")

print("\nRandomly Selected MondayWednesdayFriday Videos for Tubs:")
for photoperiod, files in selected_mon_wed_fri_tub.items():
    print(f"{photoperiod}: {files}")

print("\nRandomly Selected MondayWednesdayFriday Videos for Tanks:")
for photoperiod, files in selected_mon_wed_fri_tank.items():
    print(f"{photoperiod}: {files}")'''
# Randomly select 4x 30-minute windows, within a range of tidal scenarios, for each randomly selected file^ 
## For the tank, select 4x 30-minute windows for the flow high, ebb high, ebb low, and flow low tides for each randomly selected file^
tank_time_ranges = {
    'flow high': [('17', '20')],
    'ebb high': [('08', '11'), ('20', '22')],
    'ebb low': [('11', '14')],
    'flow low': [('14', '17')],
}

## For the tub, select 4x 30-minute windows for the high (2x) and low (2x) tide periods
tub_time_ranges = {
    'high': [('08', '14'), ('20', '22')],
    'low': [('14', '20')]
}

def get_mins_hours(minutes):
    return (minutes//60,minutes%60)

def random_time_from_range(start, end):
    """
    Args: start (list) e.g. [hours, seconds] [7, 0] 
    Args: emd (list) e.g. [hours, seconds] [9, 30] 
    """
    start_time = (start[0] * 60)+start[1]
    end_time = (end[0] * 60)+end[1]
    v_length = end_time - start_time
    if v_length >= 0:
        start_mins = random.randint(0, v_length)
        return get_mins_hours(start_time+start_mins)
    else:
        return 'null'



def calculate_valid_time_periods(video_start_time, crabitat_type):
    if crabitat_type == 'tank':
        time_categories = tank_time_ranges
    elif crabitat_type == 'tub':
        time_categories = tub_time_ranges    
    else:
        raise ValueError("Invalid crabitat type")

    valid_time_periods = {}
    for time_category, time_ranges in time_categories.items():
        valid_time_periods[time_category] = []
        for start_hour, end_hour in time_ranges:
            if int(start_hour) < int(video_start_time):
                valid_start_hour = int(video_start_time)
            else:
                valid_start_hour = int(start_hour)

            if int(end_hour) > int(video_start_time) + 24:  
                valid_end_hour = int(video_start_time) + 24
            else:
                valid_end_hour = int(end_hour)

            valid_time_periods[time_category].append((valid_start_hour, valid_end_hour))
    
    return valid_time_periods

def get_time_period(valid_time_periods, high_low):
    time_periods = valid_time_periods[high_low]
    random_range_iterator = random.randint(0, len(time_periods)-1)
    random_range = time_periods[random_range_iterator]
    selected_time_period = random_time_from_range([random_range[0], 0], [random_range[1]-1, 30])
    return selected_time_period

time_limit = 360
collected_data = []

for photoperiod, daytypes in tub_photoperiods.items():
    for day_type, files in daytypes.items():
        if day_type in ['Weekend', 'TuesdayThursday', 'MondayWednesdayFriday']:
            for file in files:
                if file in selected_weekend_tub[photoperiod] or file in selected_tue_thu_tub[photoperiod] or file in selected_mon_wed_fri_tub[photoperiod]:
                    video_start_time = extract_date_and_time(
                        file, 'tub')[-3] 
                    valid_time_periods = calculate_valid_time_periods(
                        video_start_time, 'tub')

                    for time_category in ['high'] * 2:
                        start_time = datetime.now()
                        selected_time_period = get_time_period(
                            valid_time_periods, 'high')

                        while selected_time_period == 'null':
                            current_time = datetime.now()
                            elapsed_time = current_time - start_time
                            if elapsed_time.total_seconds() >= time_limit:
                                print(
                                    "Time limit exceeded. No valid selection found.")
                                break  

                            selected_time_period = get_time_period(
                                valid_time_periods, 'high')

                        if selected_time_period != 'null':
                            '''print(f"photoperiod: {photoperiod}, Day Type: {day_type}, Video: {file}, Time Category: {time_category}, Selected Period: {selected_time_period[0]:02d}:{selected_time_period[1]:02d}")'''
                            collected_data.append(
                                [file, photoperiod, day_type, time_category, f"{selected_time_period[0]:02d}:{selected_time_period[1]:02d}"])

                    for time_category in ['low'] * 2:
                        start_time = datetime.now()
                        selected_time_period = get_time_period(
                            valid_time_periods, 'low')

                        while selected_time_period == 'null':
                            current_time = datetime.now()
                            elapsed_time = current_time - start_time
                            if elapsed_time.total_seconds() >= time_limit:
                                print(
                                    "Time limit exceeded. No valid selection found.")
                                break 

                            selected_time_period = get_time_period(
                                valid_time_periods, 'low')

                        if selected_time_period != 'null':
                            '''print(f"photoperiod: {photoperiod}, Day Type: {day_type}, Video: {file}, Time Category: {time_category}, Selected Period: {selected_time_period[0]:02d}:{selected_time_period[1]:02d}")'''
                            collected_data.append(
                                [file, photoperiod, day_type, time_category, f"{selected_time_period[0]:02d}:{selected_time_period[1]:02d}"])

for photoperiod, daytypes in tank_photoperiods.items():
    for day_type, files in daytypes.items():
        if day_type in ['Weekend', 'TuesdayThursday', 'MondayWednesdayFriday']:
            for file in files:
                if file in selected_weekend_tank[photoperiod] or file in selected_tue_thu_tank[photoperiod] or file in selected_mon_wed_fri_tank[photoperiod]:
                     video_start_time = extract_date_and_time(
                         file, 'tank')[-3] 
                      
                    valid_time_periods = calculate_valid_time_periods(
                           video_start_time, 'tank')

                for time_category in ['flow high']:
                            start_time = datetime.now()
                            selected_time_period = get_time_period(
                                valid_time_periods, 'flow high')

                            while selected_time_period == 'null':
                                current_time = datetime.now()
                                elapsed_time = current_time - start_time
                                if elapsed_time.total_seconds() >= time_limit:
                                    print(
                                        "Time limit exceeded. No valid selection found.")
                                    break 

                            selected_time_period = get_time_period(
                                valid_time_periods, 'flow high')

                        if selected_time_period != 'null':
                            '''print(f"photoperiod: {photoperiod}, Day Type: {day_type}, Video: {file}, Time Category: {time_category}, Selected Period: {selected_time_period[0]:02d}:{selected_time_period[1]:02d}")'''
                            collected_data.append(
                                [file, photoperiod, day_type, time_category, f"{selected_time_period[0]:02d}:{selected_time_period[1]:02d}"])

                        for time_category in ['flow low']:
                            start_time = datetime.now()
                            selected_time_period = get_time_period(
                                valid_time_periods, 'flow low')

                            while selected_time_period == 'null':
                                current_time = datetime.now()
                                elapsed_time = current_time - start_time
                                if elapsed_time.total_seconds() >= time_limit:
                                    print(
                                        "Time limit exceeded. No valid selection found.")
                                    break  

                            selected_time_period = get_time_period(
                                valid_time_periods, 'flow low')

                        if selected_time_period != 'null':
                            '''print(f"photoperiod: {photoperiod}, Day Type: {day_type}, Video: {file}, Time Category: {time_category}, Selected Period: {selected_time_period[0]:02d}:{selected_time_period[1]:02d}")'''
                            collected_data.append(
                                [file, photoperiod, day_type, time_category, f"{selected_time_period[0]:02d}:{selected_time_period[1]:02d}"])

                        for time_category in ['ebb high']:
                            start_time = datetime.now()
                            selected_time_period = get_time_period(
                                valid_time_periods, 'ebb high')

                            while selected_time_period == 'null':
                                current_time = datetime.now()
                                elapsed_time = current_time - start_time
                                if elapsed_time.total_seconds() >= time_limit:
                                    print(
                                        "Time limit exceeded. No valid selection found.")
                                    break  

                            selected_time_period = get_time_period(
                                valid_time_periods, 'ebb high')

                        if selected_time_period != 'null':
                            '''print(f"photoperiod: {photoperiod}, Day Type: {day_type}, Video: {file}, Time Category: {time_category}, Selected Period: {selected_time_period[0]:02d}:{selected_time_period[1]:02d}")'''
                            collected_data.append(
                                [file, photoperiod, day_type, time_category, f"{selected_time_period[0]:02d}:{selected_time_period[1]:02d}"])

                        for time_category in ['ebb low']:
                            start_time = datetime.now()
                            selected_time_period = get_time_period(
                                valid_time_periods, 'ebb low')

                            while selected_time_period == 'null':
                                current_time = datetime.now()
                                elapsed_time = current_time - start_time
                                if elapsed_time.total_seconds() >= time_limit:
                                    print(
                                        "Time limit exceeded. No valid selection found.")
                                    break  

                            selected_time_period = get_time_period(
                                valid_time_periods, 'ebb low')

                        if selected_time_period != 'null':
                            '''print(f"photoperiod: {photoperiod}, Day Type: {day_type}, Video: {file}, Time Category: {time_category}, Selected Period: {selected_time_period[0]:02d}:{selected_time_period[1]:02d}")'''
                            collected_data.append(
                                [file, photoperiod, day_type, time_category, f"{selected_time_period[0]:02d}:{selected_time_period[1]:02d}"])
#%% Save output
df = pd.DataFrame(collected_data, columns=[
                  "video file", "photoperiod", "day type", "tide category", "selected observation period start"])

excel_file = r'C:/Users/Sanna/Desktop/selected_data.xlsx'
df.to_excel(excel_file, index=False)
print(f"Data saved to {excel_file}.")

