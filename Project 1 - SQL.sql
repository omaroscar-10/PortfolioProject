SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;


--Looking at Total Cases vs Total Deaths
--Showing Likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS TotalCases_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2;


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS TotalCases_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%olivia%'
GROUP BY location, population
ORDER BY TotalCases_Percentage DESC;


--Showing Countries with Highest Death Count per Popualtion

SELECT location, population, MAX((total_deaths/population))*100 AS TotalDeathsCount_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%olivia%'
GROUP BY location, population
ORDER BY TotalDeathsCount_Percentage DESC;

SELECT location, MAX(CAST(total_deaths AS INT))AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%olivia%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC;

--Let's break things down by continent
--Showing continents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT))AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%olivia%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC;


SELECT continent, MAX(CAST(total_deaths AS INT))AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%olivia%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC;

 
 -- Global Numbers

 SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
 SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 --Where location LIKE '%states%'
 WHERE continent IS NOT NULL
 --GROUP BY date
 ORDER BY 1,2;


 -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, 
RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL























