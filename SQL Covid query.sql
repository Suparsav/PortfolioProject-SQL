--select * 
--from [Portfolio project]..coviddeaths
--order by 3,4

--select * 
--from [Portfolio project]..covidvaccinations
--order by 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM [Portfolio project]..coviddeaths
WHERE continent is NOT NULL
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths.
--Shows likelyhood of dying if you contract Covid in India
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio project]..coviddeaths
WHERE location like '%india%'
AND continent is NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population
SELECT location,date,population,total_cases,total_deaths, (total_cases/population)*100 as Percent_of_population_Infected
FROM [Portfolio project]..coviddeaths
WHERE location like '%india%'
AND continent is NOT NULL
ORDER BY 1,2

--Looking at country with highest infection rate.

SELECT location,population,MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as Percent_of_population_Infected
FROM [Portfolio project]..coviddeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY Location, Population
ORDER BY Percent_of_population_Infected DESC 

--Showing Countries with Highest Death Counts.


SELECT location,MAX(cast(total_deaths as int)) as Total_death_count
FROM [Portfolio project]..coviddeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY Total_death_count DESC

---- BREAKING DATA DOWN BY CONTINENT WISE

SELECT continent,MAX(cast(total_deaths as int)) as Total_death_count
FROM [Portfolio project]..coviddeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC
---- COrrect method
--SELECT location,MAX(cast(total_deaths as int)) as Total_death_count
--FROM [Portfolio project]..coviddeaths
----WHERE location like '%india%'
--WHERE continent is NULL
--GROUP BY location
--ORDER BY Total_death_count DESC

-- SHowing Continents with highest death count per population.

SELECT continent,MAX(cast(total_deaths as int)) as Total_death_count
FROM [Portfolio project]..coviddeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC





-- Global Numbers

SELECT date,SUM(new_cases) as Total_cases ,SUM(CAST(new_deaths as int)) as Total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
FROM [Portfolio project]..coviddeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Percentage of Pupolation Died because Of Covid-19 All over the World

SELECT SUM(new_cases) as Total_cases ,SUM(CAST(new_deaths as int)) as Total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
FROM [Portfolio project]..coviddeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population Vs Vaccinations


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date ) as Rolling_people_vaccinated
FROM [Portfolio project]..coviddeaths dea
JOIN [Portfolio project]..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE 
WITH popvsVac (Continent,location, date,population ,new_vaccination,Rolling_people_vaccinated) 
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date ) as Rolling_people_vaccinated
FROM [Portfolio project]..coviddeaths dea
JOIN [Portfolio project]..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT * ,(Rolling_people_vaccinated/population)*100 as Percentage_of_population_vaccinated
FROM popvsVac


-- By Using Temperary Table.
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date ) as Rolling_people_vaccinated
FROM [Portfolio project]..coviddeaths dea
JOIN [Portfolio project]..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT * ,(Rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Create view to store data for latyer visualisation.
DROP VIEW PercentPopulationVaccinated
USE [Portfolio project]
Go
create view PercentPopulationVaccinated as 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date ) as Rolling_people_vaccinated
FROM [Portfolio project]..coviddeaths dea
JOIN [Portfolio project]..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * 
FROM PercentPopulationVaccinated