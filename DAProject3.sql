
--PROJECT 3: CLEANING DATA---



--Uvid u tabelu

Select *
from nashvillehousing;


--Promjena format datuma (ukoliko je potrebno)

--select SaleDate, convert(date, saledate)
--from nashvillehousing;

--update nashvillehousing
--set saledate=convert(date, saledate);

--alter table nashvillehousing
--add saleDateConverted=convert(date, SaleDate);


--Izdvajamo redove tabele u kojima je polje PropertyAddress prazno

select *
from nashvillehousing
where PropertyAddress is null;


--Uvid u tabelu sortiranu po ParcelID

select *
from nashvillehousing
order by ParcelID;



--Želimo popuniti prazna polja u koloni PropertyAddress--


--Izdvajanje parova koji imaju različite uniqueID, a iste parcelID pri čemu je adresa jednog u paru prazno polje

select a.parcelID, a.propertyAddress, b.parcelID, b.propertyAddress
from nashvillehousing  a
join nashvillehousing  b
    on a.ParcelID = b.ParcelID
    and a.uniqueID_ <> b.uniqueID_
where a.propertyaddress is null;

--Za razliku od prethodnog upita, na poljima a.propertyAddress i b.propertyAddress prikazujemo onu vrijednost od ove dvije koja je nenulta

select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, NVL (a.propertyaddress, b.propertyaddress)
from nashvillehousing  a
join nashvillehousing  b
    on a.ParcelID = b.ParcelID
    and a.uniqueID_ <> b.uniqueID_
where a.propertyaddress is null;

--Na osnovu prethodnog upita mijenjamo tabelu 

update nashvillehousing c
set c.propertyAddress =(select NVL (a.propertyaddress, b.propertyaddress)
from nashvillehousing a
join nashvillehousing  b
    on a.ParcelID = b.ParcelID
    and a.uniqueID_ <> b.uniqueID_
    where a.propertyaddress is null
    and c.propertyaddress = a.propertyaddress)
where c.propertyaddress is null;

--Provjera da li nam je ostala neka prazna adresa, tj. prazno polje kolone propertyAddress

select count(*)
from nashvillehousing
where propertyAddress is null;
    


--Razdvajanje kolone propertyAddress na dvije kolone (Address, City)--


--Uvid u kolonu propertyAddress

select propertyAddress
from nashvillehousing;


--Razdvajanje kolone propertyAddress na dvije kolone (Address, City), SAMO PRIKAZ

select 
	SUBSTR(propertyAddress, 1, instr(propertyAddress, ',')-1) as Address,
	SUBSTR(propertyAddress, instr(propertyAddress, ',')+1, length (propertyAddress)) as City
from nashvillehousing;


--Dodavanje nove kolone propertySplitAddress na kraj tabele

alter table nashvillehousing
add propertySplitAddress varchar2(255);
    

--Popunjavanje kolone propertySplitAddress 
    
update nashvillehousing
set propertySplitAddress =  SUBSTR(propertyAddress, 1, instr(propertyAddress, ',')-1); 


--Dodavanje nove kolone propertySplitCity na kraj tabele
    
alter table nashvillehousing
add propertySplitCity varchar2(255);

    
--Popunjavanje kolone propertySplitCity
    
update nashvillehousing
set propertySplitCity =  SUBSTR(propertyAddress, instr(propertyAddress, ',')+1, length (propertyAddress)); 

    
--Uvid u tabelu

select *
from nashvillehousing;


    
--Razdvajanje kolone ownerAddress na tri kolone (Address, City, State)--


--Uvid u kolonu ownerAddress

select ownerAddress
from nashvillehousing;


--Razdvajanje kolone ownerAddress na tri kolone (Address, City, State), SAMO PRIKAZ
    
select 
	SUBSTR(OwnerAddress, 1, instr(OwnerAddress, ',')-1) as A,
	SUBSTR(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), 1, instr(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), ',')-1) as C,
	SUBSTR(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), instr(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), ',')+1, length (SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)))) as S
from nashvillehousing;


--Dodavanje nove kolone ownerSplitAddress na kraj tabele
 
alter table nashvillehousing
add OwnerSplitAddress varchar2(255);


--Popunjavanje kolone ownerSplitAddress
 
update nashvillehousing
set OwnerSplitAddress = SUBSTR(OwnerAddress, 1, instr(OwnerAddress, ',')-1); 


--Dodavanje nove kolone ownerSplitCity na kraj tabele  
  
alter table nashvillehousing
add OwnerSplitCity varchar2(255);


--Popunjavanje kolone ownerSplitCity
    
update nashvillehousing
set OwnerSplitCity =  SUBSTR(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), 1, instr(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), ',')-1); 
 
 
 --Dodavanje nove kolone ownerSplitState na kraj tabele
 
alter table nashvillehousing
add OwnerSplitState varchar2(255);


--Popunjavanje kolone ownerSplitState
    
update nashvillehousing
set OwnerSplitState =  SUBSTR(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), instr(SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)), ',')+1, length (SUBSTR(OwnerAddress, instr(OwnerAddress, ',')+1, length (OwnerAddress)))); 
    
    
--Uvid u tabelu

select *
from nashvillehousing;



Mijenjamo 'Y' i 'N' u 'Yes' i 'No', respektivno
    
    
--Prikaz različitih vrijednosti kolone soldAsVacant
    
select distinct(soldAsVacant)
from nashvillehousing;


--Zamjena vrijednosti (SAMO PRIKAZ)
    
select soldAsVacant,
	case soldAsVacant
		 when 'Y' 
			then 'Yes'
         when 'N' 
            then 'No'
         when 'Yes' 
            then 'Yes'
         else 'No'
	end 
from nashvillehousing;
    
    
--Zamjena vrijednosti (PROMJENA U TABELI)
    
update nashvillehousing
    set soldAsVacant = case soldAsVacant
         when 'Y' 
            then 'Yes'
         when 'N' 
            then 'No'
         when 'Yes' 
            then 'Yes'
         else 'No'
	end;
    
    
        
--Brisanje duplikata
    
    
--Prikaz redova koji imaju duplikate (gledamo po vrijednostima kolona parcelID, propertyAddress, salePrice, saleDate, legalReference)

with RowNumCTE AS(
    select nvh.*, 
        row_number() over (
            partition by ParcelID,
                        PropertyAddress,
                        salePrice,
                        SaleDate,
                        LegalReference
                      ORDER BY
                        UniqueID_
        ) as row_num
	from nashvillehousing nvh
)
select *
from RowNumCTE
where row_num > 1
ORDER BY PropertyAddress;


--Brisanje duplikata na osnovu prethodnog upita
       
DELETE 
from nashvillehousing
where uniqueID_ in (  with RowNumCTE AS(
						select nvh.*, 
							row_number() over (
								partition by parcelID,
											 propertyAddress,
											 salePrice,
											 saleDate,
											 legalReference
								ORDER BY uniqueID_)
							as row_num
							from nashvillehousing nvh)
						select uniqueID_
						from RowNumCTE
						where row_num > 1 );
    
    
    
--Brisanje suvišnih kolona


--Uvid u tabelu

select * 
from nashvillehousing;


--Brisanje kolona ownerAddress, taxDistrict i propertyAddress

alter table nashvillehousing
drop  (OwnerAddress, TaxDistrict, PropertyAddress);


--Brisanje kolone saleDate

alter table nashvillehousing
drop  column SaleDate;




    
    