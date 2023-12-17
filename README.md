# Parse-Secpol

## Overview

The `Parse-Secpol` PowerShell script is designed to export and parse local Security Policy (secpol) settings, providing valuable insights into the security configurations of a system. This script exports the secpol settings to a temporary file, parses the contents, and outputs the results as a custom object. Additionally, it allows for exporting the parsed data to a CSV file for further analysis.

## Usage

`Parse-Secpol -Path "C:\temp" -ExportPath "C:\Reports"` 

-   **Path**: Specifies the temporary path for the secpol export. Default is "C:\temp".
-   **ExportPath**: Specifies the export path for a CSV report. It must be a valid existing folder. If not specified, the script only parses the secpol settings without exporting to CSV.


## Important Note

To run this script successfully, ensure that you have local admin privileges.

## How It Works

1.  Exports the secpol settings to a temporary file (`secpol.cfg`).
2.  Parses the contents of the secpol file.
3.  Creates a custom object to store the parsed data.
4.  Iterates through the parsed data and populates the custom object.
5.  Optionally exports the parsed data to a CSV file if the export path is specified.
6.  Cleans up the temporary secpol file.

## Examples

-   Parse secpol settings and export to CSV:

`Parse-Secpol -Path "D:\Temp" -ExportPath "D:\Reports"` 

-   Parse secpol settings without CSV:

`Parse-Secpol -Path "D:\Temp"` 
