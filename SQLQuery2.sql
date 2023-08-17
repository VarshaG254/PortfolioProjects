Select *
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From [Portfolio Project ]..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using

Select location,date, total_cases, new_cases, total_deaths, population
From [Portfolio Project ]..CovidDeaths
Order by 1,2

--Looking at the total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of poulation got covid

Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

--showing the countries with the highest death counte per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Showing the continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers

Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--group by date
Order by 1,2

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
	Where dea.continent is not null
	Order by 2,3

	--USE CTE (because we cant simply use a table we just created)-- 
	--If number of Columns in the CTE is different than the number of columns in original Select, you will get error

With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
	Where dea.continent is not null
	--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table
--DROP table if exists #PercentPeopleVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPOpulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
	Where dea.continent is not null
	--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store date for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
	Where dea.continent is not null
	--Order by 2,3

Select *
From PercentPopulationVaccinated