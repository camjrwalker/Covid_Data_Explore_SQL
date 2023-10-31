/*
Queries used for Tableau Project
*/

-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--where location = 'World'
--Group By date
--order by 1,2

-- 2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT	location,
		SUM(cast(new_deaths as int)) as TotalDeathCount
FROM	PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE	continent is null 
		and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc

-- 3.
SELECT	Location,
		Population,
		MAX(total_cases) as HighestInfectionCount,
		Max((total_cases/population))*100 as PercentPopulationInfected
FROM	PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- 4.
SELECT	Location,
		Population,
		date,
		MAX(total_cases) as HighestInfectionCount,
		Max((total_cases/population))*100 as PercentPopulationInfected
FROM	PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc

-- Extra queries

-- 1.
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM	PortfolioProject.dbo.CovidDeaths dea
JOIN	PortfolioProject.dbo.CovidVacinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE	dea.continent is not null 
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3

-- 2.
SELECT	SUM(new_cases) AS total_cases,
		SUM(cast(new_deaths as int)) AS total_deaths,
		SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--SELECT	SUM(new_cases) as total_cases,
--			SUM(cast(new_deaths as int)) as total_deaths,
--			SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--FROM		PortfolioProject.dbo.CovidDeaths
--WHERE		location like '%states%'
--WHERE		location = 'World'
--GROUP BY date
--ORDER BY 1,2

-- 3.
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT	location,
		SUM(cast(new_deaths as int)) as TotalDeathCount
FROM	PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE	continent is null 
		and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc

-- 4.
SELECT	Location,
		Population,
		MAX(total_cases) as HighestInfectionCount,
		Max((total_cases/population))*100 as PercentPopulationInfected
FROM	PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- 5.
--SELECT	Location,
--			date,
--			total_cases,
--			total_deaths,
--			(total_deaths/total_cases)*100 as DeathPercentage
--FROM		PortfolioProject.dbo.CovidDeaths
--WHERE		location like '%states%'
--WHERE		continent is not null 
--ORDER BY 1,2

-- took the above query and added population
SELECT	Location,
		date,
		population,
		total_cases,
		total_deaths
FROM	PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE	continent is not null 
ORDER BY 1,2

-- 6. 
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM	PortfolioProject.dbo.CovidDeaths dea
JOIN	PortfolioProject.dbo.CovidVacinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM PopvsVac

-- 7. 
SELECT	Location,
		Population,
		date,
		MAX(total_cases) AS HighestInfectionCount,
		Max((total_cases/population))*100 AS PercentPopulationInfected
FROM	PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc