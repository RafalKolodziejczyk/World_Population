"""Creating csv files required for sql analysis"""
import csv
import os

directory_path = os.path.join(os.path.dirname(__file__), 'resources')   # path to the directory with raw data
years = [i for i in range(1960, 2021)]  # list of analyzed years
columns_percent = ["Country", "Year", "Percent"]    # columns for result files
columns_count = ["Country", "Year", "Count"]        # columns for result files
# {csv file from resources: [name for result file, list of new column names]}
data_dict = {'API_EN.POP.DNST_DS2_en_csv_v2_4570301.csv': ['annual_population_density.csv', columns_count],
             'API_SP.POP.0014.TO.ZS_DS2_en_csv_v2_4523426.csv': ['annual_population_below_age14.csv', columns_percent],
             'API_SP.POP.65UP.TO.ZS_DS2_en_csv_v2_4531535.csv': ['annual_population_above_age65.csv', columns_percent],
             'API_SP.POP.TOTL.FE.ZS_DS2_en_csv_v2_4570248.csv': ['annual_female_population.csv', columns_percent],
             'API_SP.POP.TOTL_DS2_en_csv_v2_4578059.csv': ['annual_population.csv', columns_count]}

for file_name in data_dict.keys():
    # path to the csv file from resources
    file_path = os.path.join(directory_path, file_name)

    with open(file_path, 'r', encoding='utf-8') as file:
        csvreader = csv.reader(file, delimiter=',', lineterminator="\n")
        rows = [r for r in csvreader]

    columns = rows[4]   # row with column names
    data = rows[5:]     # rows with data

    dict_col = {}       # column indexes
    i = 0
    for col_name in columns:
        dict_col[col_name] = i
        i += 1

    dict_country_name = {}  # {country name: column index} -> {'Poland': 1}
    for row in data:
        dict_country_name[row[0]] = row

    data_new = []
    # create list of rows for analyzed range of years
    for year in years:
        for country in dict_country_name.keys():
            row_new = [country, year, dict_country_name[country][dict_col[str(year)]]]
            data_new.append(row_new)

    # path to the new csv file
    new_file_path = os.path.join(os.path.dirname(__file__), 'results')
    os.makedirs(new_file_path, exist_ok=True)
    # create and save new csv files, [0] new file name
    with open(f'{new_file_path}\{data_dict[file_name][0]}', 'w', encoding='utf-8') as file:
        csvwriter = csv.writer(file, delimiter=',', lineterminator="\n")
        csvwriter.writerow(data_dict[file_name][1])     # [1] new column names
        csvwriter.writerows(data_new)
