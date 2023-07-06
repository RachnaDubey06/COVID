Select * 
from PortfolioProject..CovidDeaths
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4 

--select data that we are going to be using 

select location, date , total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1 , 2

--looking at total cases vs total deaths
--shows likelyhood of dying if you contact covid in your country
select location, date, total_cases, total_deaths from PortfolioProject..CovidDeaths

ALTER TABLE CovidDeaths ALTER COLUMN total_deaths float
ALTER TABLE CovidDeaths ALTER COLUMN total_cases  float




select location, date, total_cases, total_deaths ,
(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths

--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
--from PortfolioProject..CovidDeaths
--where location like '%India%'






--looking at total cases vs population 
--shows what % of population got covid
select location, date, Population, total_cases,  (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like '%India%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like '%India%'
Group by location, Population
order by PercentPopulationInfected desc

--showing the countries with highest death count per polpulation 

select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%India%'
where continent is not NULL
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS down by continent 

select continent , MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%India%'
where continent is not NULL
Group by continent   
order by TotalDeathCount desc

--showing the continents with the highest death count per population 

select continent , MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%India%'
where continent is not NULL
Group by continent   
order by TotalDeathCount desc

--global numbers (Agrigrate function ?)
select date ,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,sum(new_deaths)/sum (NULLIF(new_cases,0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by date 
order by 1, 2 

--total cases around the world 
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,sum(new_deaths)/sum (NULLIF(new_cases,0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1, 2 

--looking at total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations 
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
sum(convert (float,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte 

with PopvsVac (contitnet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
sum(convert (float,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp table 

Drop Table if exists #PercentPopulationVaccinated  
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar (255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
sum(convert (float,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
sum(convert (float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated 

