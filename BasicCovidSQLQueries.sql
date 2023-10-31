/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
ORDER by 3,4

-- Select data that we are going to be using

SELECT	location,
		date,
		total_cases,
		new_cases,
		total_deaths,\
		population
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not null
ORDER by 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying, over time, if you had contracted covid in a particular country
SELECT
	location,
	date,
    total_cases,
    total_deaths,
    CASE 
        WHEN ISNUMERIC(total_cases) = 1 and ISNUMERIC(total_deaths) = 1 THEN
            FORMAT((CONVERT(decimal, total_deaths) * 100.0) / CONVERT(decimal, total_cases), 'N2')
        ELSE null
    END AS PercentageDeathRate
FROM PortfolioProject.dbo.coviddeaths
WHERE	total_cases is not null and
		location like '%states%' and
		continent is not null
ORDER BY 1,2;

-- look at Total Cases vs Population
-- shows what percentage of population got Covid
SELECT	location,
		date,
		total_cases,
		population,
		FORMAT((total_cases/population)*100, 'N2') AS PercentOfPopulationInfected
FROM	PortfolioProject.dbo.coviddeaths
WHERE	location like '%states%' and
		continent is not null
ORDER BY 1,2;

-- what countries had the highest infection rates compared to population
SELECT	location,
		population,
		MAX(total_cases) AS HighestInfectionCount,
		MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM	PortfolioProject.dbo.coviddeaths
-- WHERE location like '%states%'
Group by Location, Population
ORDER BY PercentOfPopulationInfected desc;

-- Countries with Highest Death Count per Population
SELECT	Location,
		MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM	PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE	continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT	continent,
		MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM	PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE	continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT	SUM(new_cases) as total_cases,
		SUM(cast(new_deaths as int)) as total_deaths,
		SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM	PortfolioProject.dbo.coviddeaths
--WHERE location like '%states%'
WHERE	continent is not null 
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--		, (RollingPeopleVaccinated/population)*100
FROM	PortfolioProject.dbo.coviddeaths dea
JOIN	PortfolioProject.dbo.covidvacinations vac ON dea.location = vac.location and dea.date = vac.date
WHERE	dea.continent is not null and
		vac.new_vaccinations is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacinations vac ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVacinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null