SELECT *
FROM Portfolio..COVIDdeaths$
WHERE continent is not null 
ORDER BY 3,4;

--SELECT *
--FROM Portfolio..COVIDVaccine$
--ORDER BY 3,4;

--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..COVIDdeaths$
WHERE continent is not null 
ORDER BY 1, 2


--Converting from nvarchar to int

SELECT * 
FROM Portfolio..COVIDdeaths$
EXEC sp_help 'COVIDdeaths$';

ALTER TABLE COVIDdeaths$
ALTER COLUMN total_cases float

SELECT * 
FROM Portfolio..COVIDdeaths$
EXEC sp_help 'COVIDdeaths$';

ALTER TABLE COVIDdeaths$
ALTER COLUMN total_deaths float


-- Looking at total Cases vs Total deaths 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio..COVIDdeaths$
Where location ='Canada'
order by 1,2 

-- Looking at Total Cases vs Population 
-- Shows what percentage of Population got COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM Portfolio..COVIDdeaths$
Where location ='Canada'
order by 1,2 

-- Looking at Locations with highest infection rate compared to Population 

SELECT Location, population, MAX(total_cases) AS  highestinfectionlocation, MAX(total_cases/population)*100 as PopulationInfectionPercentage
FROM Portfolio..COVIDdeaths$
--Where location ='Canada'
WHERE continent is not null 
Group by location, population
order by PopulationInfectionPercentage desc

-- Showing Countries with highest death count per Population 

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM Portfolio..COVIDdeaths$
--Where location ='Canada'
WHERE continent is not null 
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent 
-- Showing continetns with the highest death count per population 

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Portfolio..COVIDdeaths$
--Where location ='Canada'
WHERE continent is not null 
Group by continent
order by TotalDeathCount desc 

-- Showing continent Asia with the highest death count per population 

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Portfolio..COVIDdeaths$
Where continent ='Asia'
Group by continent

-- Global numbers 

SELECT SUM (new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio..COVIDdeaths$
--Where location ='Canada'
Where continent is not null
--Group by date
order by 1,2 

-- Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
from Portfolio..COVIDdeaths$ dea
join Portfolio..COVIDVaccine$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3


--USE CTE

With PopvsVac (Contintent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations AS bigint)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
from Portfolio..COVIDdeaths$ dea
join Portfolio..COVIDVaccine$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Contintent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
from Portfolio..COVIDdeaths$ dea
join Portfolio..COVIDVaccine$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
from Portfolio..COVIDdeaths$ dea
join Portfolio..COVIDVaccine$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3

Select * 
From PercentPopulationVaccinated

Create View GlobalNumbers as
SELECT SUM (new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio..COVIDdeaths$
--Where location ='Canada'
Where continent is not null
--Group by date
--order by 1,2 
Select * 
From GlobalNumbers