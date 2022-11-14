CREATE TABLE general_info (
country VARCHAR(50) NOT NULL,
population INTEGER NOT NULL CHECK(population > 0),
percentage_year_change REAL CHECK(percentage_year_change BETWEEN -100 AND 100),
net_change INTEGER,
density REAL,
land_area REAL,
migrants REAL,
fertility_rate REAL,
medium_age REAL,
percentage_urban_population REAL,
percentage_world_share REAL
);

CREATE TABLE annual_population_above_age65 (
country VARCHAR(70) NOT NULL,
year SMALLINT CHECK(year <= date_part('year', CURRENT_DATE)),
percentage REAL CHECK(percentage BETWEEN -100 AND 100)
);

CREATE TABLE annual_population_below_age14 (
country VARCHAR(70) NOT NULL,
year SMALLINT CHECK(year <= date_part('year', CURRENT_DATE)),
percentage REAL CHECK(percentage BETWEEN -100 AND 100)
);

CREATE TABLE annual_population_density (
country VARCHAR(70) NOT NULL,
year SMALLINT CHECK(year <= date_part('year', CURRENT_DATE)),
count REAL
);

CREATE TABLE annual_female_population (
country VARCHAR(70) NOT NULL,
year SMALLINT CHECK(year <= date_part('year', CURRENT_DATE)),
percentage REAL CHECK(percentage BETWEEN -100 AND 100)
);

CREATE TABLE annual_population (
country VARCHAR(70) NOT NULL,
year SMALLINT CHECK(year <= date_part('year', CURRENT_DATE)),
count BIGINT CHECK(count > 0)
);