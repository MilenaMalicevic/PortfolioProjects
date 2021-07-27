

select * 
from COVID_DEATHS
order by 3,4;

select location, dan, total_cases, new_cases, total_deaths, population
from covid_deaths where continent is not null
order by 1,2;

--ukupan broj slucajeva naspram ukupnog broja preminulih
--prikaz vjerovatnoce smrti u nasoj drzavi
select location, dan, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%States%' and continent is not null
order by 1,2;

--ukupan broj slucajeva naspram broja stanovnika
select location, dan, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from covid_deaths
where location like '%Bos%'
order by 1,2;

--zemlje sa najvecim brojem zarazenih u odnosu na broj stanovnika
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionPercentage
from covid_deaths
where total_cases is not NULL and continent is not null
--where location like '%Bos%'
group by location, population
order by 4 desc;

--raspodjela po kontinentima
select continent,  MAX(total_deaths) as TotalDeathsCount
from covid_deaths
where total_deaths is not NULL and continent is not  NULL
--where location like '%Bos%'
group by continent
order by 2 desc;

--zemlje sa najvecim brojem umrlih u odnosu na broj stanovnika
select location,  MAX(total_deaths) as TotalDeathsCount
from covid_deaths
where total_deaths is not NULL and continent is not NULL
--where location like '%Bos%'
group by location
order by 2 desc;

--kontinent sa najvecim brojem umrlih u odnosu na populaciju
select continent,  MAX(total_deaths) as TotalDeathsCount
from covid_deaths
where total_deaths is not NULL and continent is not  NULL
--where location like '%Bos%'
group by continent
order by 2 desc;

--brojevi na globalnom nivou
select dan, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from covid_deaths
where /*location like '%States%'*/ continent is not null
group by dan
order by 1,2;

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from covid_deaths
where /*location like '%States%'*/ continent is not null
order by 1,2;

--ukupna populacija naspram vakcinacija
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null
order by 2,3;

select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null
order by 2,3;

with pop_vs_vac  --(continent, location, dan, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null)

select continent, location, dan, population, new_vaccinations, rolling_people_vaccinated, (rolling_people_vaccinated/population)*100
from pop_vs_vac;

--privremena tabela


create table percent_population_vaccinated
(continent varchar2(26),
location varchar2(200),
dan date,
population number(38),
new_vaccinations number(38),
rolling_people_vaccinated number(38)
);


insert into percent_population_vaccinated
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan;
--where dea.continent is not null;

select continent, location, dan, population, new_vaccinations, rolling_people_vaccinated, (rolling_people_vaccinated/population)*100
from percent_population_vaccinated;

--kreiranje pogleda za cuvanje podtaka za kasniju vizualizaciju
create view percent_population_vaccinated_v as
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null;

SELECT * FROM percent_population_vaccinated_v;


