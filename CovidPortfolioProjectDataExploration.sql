/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, creating views, converting data types

*/

Select *
From PortfolioProject..coviddeaths
Where continent is not null
Order by 3,4

--Select Data that we are starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
Where continent is not null
Order by 1,2

--Total cases vs Total Deaths
--Shows likelihood of dying if you contracted covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/convert(float,total_cases))*100 as DeathPercentage
From PortfolioProject..coviddeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Total cases vs Population
--Shows what percentage of population was infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
From PortfolioProject..coviddeaths
--where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentofPopulationInfected
From PortfolioProject..coviddeaths
--where location like '%states%'
Group by location, population
order by PercentofPopulationInfected desc

--countries with highest death count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--By Continent
--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
--group by continent
order by 1,2

--Total population vs Vaccinations
--Shows percentage of population that has recieved at least on covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using CTE to perform Calcuation on partition by in previous query

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercent
From PopvsVac

--using temp table to prefrom calcuations on partition by in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 