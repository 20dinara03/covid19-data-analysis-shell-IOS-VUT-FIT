
# COVID-19 Coronavirus Infectious Disease Record Analyzer

## Overview

The `corona` script is a powerful tool designed to analyze and process records of COVID-19 infections. It provides various commands to filter, merge, and generate statistics on the infection data.

## Features

- Count the number of infected records.
- Merge multiple log files while maintaining the original order.
- Generate statistics based on gender, age, date, and location.
- Display data in both numerical and graphical (histogram) formats.

## Installation

To use the `corona` script, you need to have a POSIX-compliant shell (e.g., Bash) installed. No additional dependencies are required.

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/corona-analyzer.git
    ```
2. Navigate to the project directory:
    ```sh
    cd corona-analyzer
    ```
3. Ensure the script is executable:
    ```sh
    chmod +x corona
    ```

## Usage

```sh
corona [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]]
```

## Commands

- `infected` - Counts the number of infected records.
- `merge` - Merges several files with records into one, maintaining the original order.
- `gender` - Lists the count of infected for each gender.
- `age` - Lists statistics on the infected persons by age.
- `daily` - Lists statistics of infected persons for individual days.
- `monthly` - Lists statistics of infected persons for individual months.
- `yearly` - Lists statistics on infected persons for each year.
- `countries` - Lists statistics of infected persons for individual countries (excluding the Czech Republic, code CZ).
- `districts` - Lists statistics on infected persons for individual districts.
- `regions` - Lists statistics of infected persons for individual regions.

## Filters

- `-a DATETIME` - After: Only records of this date or later are considered (including this date). DATETIME is in the format YYYY-MM-DD.
- `-b DATETIME` - Before: Only records before this date are considered (including this date).
- `-g GENDER` - Only records of infected persons of a given gender are considered. GENDER can be M (men) or Z (women).
- `-s [WIDTH]` - For the `gender`, `age`, `daily`, `monthly`, `yearly`, `countries`, `districts`, and `regions` commands, it displays data graphically in the form of histograms.

## Examples

Count the number of infected persons:
```sh
corona infected data1.csv
```

Merge multiple log files:
```sh
corona merge data1.csv data2.csv > merged_data.csv
```

Filter records by gender and display statistics:
```sh
corona -g M gender data1.csv
```

List daily statistics for records after a specific date:
```sh
corona -a 2021-01-01 daily data1.csv
```

Generate a histogram for monthly statistics:
```sh
corona -s monthly data1.csv
```

## Help

To display the help message:
```sh
corona -h
```

## Authors

- [Dinara Garipova](https://github.com/20dinara03?tab=repositories)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

