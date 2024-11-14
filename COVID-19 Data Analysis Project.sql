Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likeihood of dying if you contract covid in your country

SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS DECIMAL(10, 2)) / CAST(total_cases AS DECIMAL(10, 2))) * 100 AS Deathpercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    location LIKE '%states%'
    AND continent IS NOT NULL
    AND TRY_CAST(total_cases AS DECIMAL(10, 2)) IS NOT NULL
    AND TRY_CAST(total_deaths AS DECIMAL(10, 2)) IS NOT NULL
ORDER BY 
    1, 2;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population gt Covid


SELECT 
    Location, 
    date, 
    population, 
    total_cases,  
    (TRY_CAST(total_cases AS DECIMAL(18, 2)) / TRY_CAST(population AS DECIMAL(18, 2))) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'  
WHERE 
    TRY_CAST(population AS DECIMAL(18, 2)) IS NOT NULL
    AND TRY_CAST(total_cases AS DECIMAL(18, 2)) IS NOT NULL
ORDER BY 
    1, 2;

-- Looking a Countries with  highest Infection Rate compared to Population

SELECT 
    Location, 
    Population, 
    MAX(TRY_CAST(total_cases AS FLOAT)) AS HighestInfectionCount,  
    MAX((TRY_CAST(total_cases AS FLOAT) / NULLIF(TRY_CAST(population AS FLOAT), 0)) * 100) AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'  
WHERE 
    TRY_CAST(total_cases AS FLOAT) IS NOT NULL
    AND TRY_CAST(population AS FLOAT) IS NOT NULL
GROUP BY 
    Location, 
    Population
ORDER BY 
    PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population

SELECT 
    Location, 
    MAX(TRY_CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'  
WHERE 
    continent IS NOT NULL
    AND TRY_CAST(total_deaths AS INT) IS NOT NULL  
GROUP BY 
    Location
ORDER BY 
    TotalDeathCount DESC;

-- Lets break things down by continent

--Showing the contintents with the highest death count per population

 SELECT 
    continent, 
    MAX(TRY_CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL  -- Exclude actual NULL values
    AND LTRIM(RTRIM(continent)) <> ''  -- Exclude empty or whitespace-only values
    AND TRY_CAST(total_deaths AS INT) IS NOT NULL  
    AND continent NOT LIKE '%NULL%'  -- Exclude any entries that contain "NULL" as text
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;

	-- GLobal Numbers

SELECT 
   
    SUM(TRY_CAST(new_cases AS INT)) AS TotalCases, 
    SUM(TRY_CAST(new_deaths AS INT)) AS TotalDeaths,
    (SUM(TRY_CAST(new_deaths AS DECIMAL(18, 2))) / NULLIF(SUM(TRY_CAST(new_cases AS DECIMAL(18, 2))), 0)) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
    AND TRY_CAST(new_cases AS INT) IS NOT NULL  -- Ensure new_cases is numeric
    AND TRY_CAST(new_deaths AS INT) IS NOT NULL  -- Ensure new_deaths is numeric
--GROUP BY 
--   date
ORDER BY 
    1,2;

-- Looking at Total Popultion vs Vaccinations 

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS INT)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated,

FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, dea.date;


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        TRY_CAST(dea.population AS BIGINT) AS population, 
        TRY_CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,
        SUM(TRY_CAST(vac.new_vaccinations AS BIGINT)) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.location, dea.date
        ) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *, (TRY_CAST(RollingPeopleVaccinated AS DECIMAL(18, 2)) / NULLIF(TRY_CAST(Population AS DECIMAL(18, 2)), 0)) * 100 AS VaccinationPercentage
FROM PopvsVac



-- Temp Table
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

-- Create the temporary table to store population vaccination data
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert data into the temporary table
INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    TRY_CAST(dea.population AS BIGINT) AS Population, 
    TRY_CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL;

-- Select data from the temporary table with calculated VaccinationPercentage
SELECT 
    *, 
    (TRY_CAST(RollingPeopleVaccinated AS DECIMAL(18, 2)) / NULLIF(TRY_CAST(Population AS DECIMAL(18, 2)), 0)) * 100 AS VaccinationPercentage
FROM 
    #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    TRY_CAST(dea.population AS BIGINT) AS Population, 
    TRY_CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


Select *
From PercentPopulationVaccinated