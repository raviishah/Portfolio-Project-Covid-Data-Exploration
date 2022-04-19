/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


--Explore Covid Vaccinations data
--SELECT*
--From [Portfolio Project]..['Covid Vaccinations$']
--order by 3,4



--Explore Covid Deaths data
SELECT*
From [Portfolio Project]..['Covid Deaths$']
order by 3,4




Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['Covid Deaths$']
order by 1,2



--Total cases vs Total deaths
--shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercetage
From [Portfolio Project]..['Covid Deaths$']
where location like '%states%'
order by 1,2



--Total cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercetagePopulationInfected
From [Portfolio Project]..['Covid Deaths$']
--where location like '%states%'
order by 1,2



--Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max ((total_cases/population))*100 as PercetagePopulationInfected
From [Portfolio Project]..['Covid Deaths$']
--where location like '%states%'
Group by location,population
order by PercetagePopulationInfected desc



--Countires with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths$']
--where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc



--let's break things down by continent
-- Showing contintents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths$']
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..['Covid Deaths$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['Covid Deaths$'] dea
join [Portfolio Project]..['Covid Vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent  is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(z
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM((cast vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['Covid Deaths$'] dea
join [Portfolio Project]..['Covid Vaccinations$'] vac
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
From [Portfolio Project]..['Covid Deaths$'] dea
join [Portfolio Project]..['Covid Vaccinations$'] vac
On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['Covid Deaths$'] dea
join [Portfolio Project]..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
