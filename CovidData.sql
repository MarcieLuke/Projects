--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--order by 3,4

----SELECT *
----FROM PortfolioProject.dbo.CovidVaccinations
----order by 3,4

--Selecting the Data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%australia%'
order by 1,2

-- Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%australia%'
order by 1,2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as MaxInfectionCount, MAX(total_cases/population)*100 as MaxInfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by 4 DESC

-- Countries with highest death rate per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
order by 2 DESC

--Continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
order by 2 DESC


-- Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCount_Vaccination,

FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingCount_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount_Vaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingCount_vaccination/Population)*100
From PopvsVac

-- Temp Table 
DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccination numeric, 
RollingCount_Vaccination numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount_Vaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select*, (RollingCount_vaccination/Population)*100
From #PercentPopulationVaccinated


-- Create View
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount_Vaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated