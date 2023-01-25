select *
from PortfolioProject..CovidDeaths
order by 3,4

--Select Data (Covid19 Data Exploration)(CovidDeaths)
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases Vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null and location like '%states%'
order by 1,2

--Total Cases Vs Popualtion
select location, date, population, total_cases, (total_cases/population)*100 Infect_Percentage
from PortfolioProject..CovidDeaths
where continent is not null and location like '%states%'
order by 1,2

--Countries with Highest Infection Rate compared to population
select location, population, MAX(total_cases) Highestinfection_Count, MAX((total_cases/population))*100 Percent_poulationinfect
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Percent_poulationinfect desc

--Countries with Highest Deaths per population
select location, MAX(total_deaths/population)*100 Percent_Deathscount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by Percent_Deathscount desc

--Countries with Highest Deaths count per population
select location, population, MAX(cast(total_deaths as int)) Total_Deathscount
from PortfolioProject..CovidDeaths
where continent is not null 
Group by location, population
order by Total_Deathscount desc

--Continent with Highest Deaths count per population
select continent, MAX(cast(total_deaths as int)) Total_Deathscount
from PortfolioProject..CovidDeaths
where continent is not null 
Group by continent
order by Total_Deathscount desc

--[Total New Cases Vs Total New Deaths] Per Day
select date, SUM(new_cases) Total_Cases, SUM(CAST(new_deaths as int)) Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null 
Group by date

--Total Population vs vaccinations (Per Day)
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
SUM(CONVERT(int,va.new_vaccinations)) OVER(partition by de.location order by de.location, de.date) RollingPeople_Vaccinated
from PortfolioProject..CovidDeaths de inner join PortfolioProject..CovidVaccinations va on de.location=va.location
and de.date=va.date
where de.continent is not null

--CTE (Commom Table Expressoin)
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeople_Vaccinated)
as
(
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
SUM(CONVERT(int,va.new_vaccinations)) OVER(partition by de.location order by de.location, de.date) RollingPeople_Vaccinated
from PortfolioProject..CovidDeaths de inner join PortfolioProject..CovidVaccinations va on de.location=va.location
and de.date=va.date
where de.continent is not null
)
select *, (RollingPeople_Vaccinated/population)*100 Percentage_peopleVaccinated 
from popvsvac

--Temp Table
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeople_Vaccinated numeric
)

insert into #PercentPopulationVaccinated
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
SUM(CONVERT(int,va.new_vaccinations)) OVER(partition by de.location order by de.location, de.date) RollingPeople_Vaccinated
from PortfolioProject..CovidDeaths de inner join PortfolioProject..CovidVaccinations va on de.location=va.location
and de.date=va.date
--where de.continent is not null

select *, (RollingPeople_Vaccinated/population)*100 Percentage_peopleVaccinated 
from #PercentPopulationVaccinated
where continent is not null
order by 2,3

--Create View to Store data
DROP view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as 
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
SUM(CONVERT(int,va.new_vaccinations)) OVER(partition by de.location order by de.location, de.date) RollingPeople_Vaccinated
from PortfolioProject..CovidDeaths de inner join PortfolioProject..CovidVaccinations va on de.location=va.location
and de.date=va.date
where de.continent is not null
