/*
Covid 19 Data Exploration 
Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


use projectPortfolio

select *
from projectPortfolio..covidDeaths
order by 3,4


select *
from projectPortfolio..covidVaccinations
order by 3,4

--Select the data which we are going to use

select location , date , total_cases , new_cases , total_deaths , population
from projectPortfolio..covidDeaths
order by 1,2								

-- Looking at the total cases vs total deaths

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as deathPersentage
from projectPortfolio..covidDeaths
where location like '%states' and total_cases is not null and total_deaths is not null
order by 1,2

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as deathPersentage
from projectPortfolio..covidDeaths
where continent is not null
order by 1,2

--looking at population vs total cases
--it shows the percentage of total cases over population

select location,date,population,total_cases,(total_cases/population)*100 as covidPercentage
from projectPortfolio..covidDeaths
where  total_cases is not null
order by 1,2

--looking at countries with highest infection rate over the population
select location,population,max(total_cases)as highestinfectioncount,max((total_cases/population))*100 as covidPercentage
from projectPortfolio..covidDeaths
where  total_cases is not null 
group by location , population
order by covidPercentage desc

-- selecct the unique location names from the table
select distinct(location) , continent
from projectPortfolio..covidDeaths
where continent is not null 
order by 2 desc

--showing country with highest death count by population

select location , max(cast(total_deaths as int)) as hightDeathCount
from projectPortfolio..covidDeaths
where continent is not null
group by location 
order by hightDeathCount desc

--showing continent with highest death count by population

select location , max(cast(total_deaths as int)) as hightDeathCount
from projectPortfolio..covidDeaths
where continent is null
group by location 
order by hightDeathCount desc


--GLOBAL NUMBERS

select date , sum(new_cases) as total_new_cases , sum(cast(new_deaths as int)) as total_new_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as new_death_persentage 
from projectPortfolio..covidDeaths
where continent is not null
group by date
order by 1,2

-- combine tables covidDeaths and covidVaccinations

select sum(covDeaths.population) as totalWorldPopulation , sum(cast(covVacc.total_vaccinations as bigint)) as totalVaccinated
,sum(cast(covVacc.total_vaccinations as bigint))/sum(covDeaths.population) *100 as persentageOfPeopleVaccinated
from projectPortfolio..covidDeaths as covDeaths join projectPortfolio..covidVaccinations as covVacc 
on covDeaths.location = covVacc.location and covDeaths.date = covVacc.date


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projectPortfolio..covidDeaths dea
Join projectPortfolio..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentageOfRollingPeopleVaccinated
From PopvsVac
--where population is not null and New_Vaccinations is not null



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
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projectPortfolio..covidDeaths dea
Join projectPortfolio..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
drop view if exists PercentagePopulationVaccinated
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projectPortfolio..covidDeaths dea
Join projectPortfolio..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVaccinated