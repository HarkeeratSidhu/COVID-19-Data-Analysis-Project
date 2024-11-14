Project 1

COVID-19 Data Analysis Project
This project contains SQL queries for analyzing COVID-19 case, death, and vaccination data from the PortfolioProject database. The analysis focuses on infection rates, mortality rates, and vaccination coverage across various locations and continents.

Database Structure
Data is drawn from two tables:

CovidDeaths - Records COVID-19 cases, deaths, and population data.
CovidVaccinations - Records COVID-19 vaccination data.

Analysis Overview

Data Extraction & Preparation
Select COVID Deaths by Location: Filters CovidDeaths data for locations with known continents.
Cases and Deaths Data: Extracts key fields for subsequent analyses.


Key Analyses


Mortality Rate by Location: Calculates the death percentage from COVID-19 cases for each location.
Infection Rate by Population: Shows the percentage of the population infected in each location.
Top Infection Rates: Identifies countries with the highest infection rates relative to population.
Top Death Counts: Lists countries with the highest total death counts.
Death Counts by Continent: Aggregates death totals by continent.
Global Totals: Summarizes total global cases, deaths, and death percentage.


Vaccination Analysis


Vaccination Rollout: Calculates cumulative vaccinations by location and date.
Vaccination Percentage (CTE): Uses a CTE to calculate population vaccination coverage.
Temporary Table for Vaccinations: Stores vaccination data for calculating population vaccination percentages.
View for Visualization: Creates PercentPopulationVaccinated view to support visual analysis.
Usage
