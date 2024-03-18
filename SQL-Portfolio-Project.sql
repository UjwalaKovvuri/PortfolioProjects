SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER by 1,2

--Looking at Deaths vs Cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathsPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%india%'
ORDER by 1,2

--Total Affected vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentageInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%india%'
ORDER by 1,2

--Each Country's highest infection rate
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) AS HighestInfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER by HighestInfectionPercentage DESC

--Each Country's total deaths
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER by TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER by 1,2

--Populations vs Vaccinations
SELECT dea.location, dea.population, MAX(CONVERT(int, vac.total_vaccinations)) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
WHERE dea.continent is not NULL
GROUP BY dea.location
ORDER BY 1

CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinatedRollingCount numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRollingCount
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (PeopleVaccinatedRollingCount/Population)*100 
FROM #PercentPeopleVaccinated


--Creating view to store data for later visualisations
CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedRollingCount
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
