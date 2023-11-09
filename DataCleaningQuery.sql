/*

Cleaning Data in SQL Queries

*/

Select *
From DataCleaningProject.dbo.NashvilleHousing



--standardize date formate

alter table DataCleaningProject.dbo.NashvilleHousing
add SaleDateConverted Date;

update DataCleaningProject.dbo.NashvilleHousing
set SaleDateConverted=CONVERT(date,SaleDate)



--Populate Property Address data


select *
from DataCleaningProject.dbo.NashvilleHousing
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from DataCleaningProject.dbo.NashvilleHousing a
join DataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 


update a
set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from DataCleaningProject.dbo.NashvilleHousing a
join DataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--breaking out Address into Individual Colums (Address, City, Sate)


select PropertyAddress 
from DataCleaningProject.dbo.NashvilleHousing

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress)) as Address

from DataCleaningProject.dbo.NashvilleHousing


alter table DataCleaningProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update DataCleaningProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)




alter table DataCleaningProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update DataCleaningProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress))




select *
from DataCleaningProject.dbo.NashvilleHousing




select OwnerAddress 
from DataCleaningProject.dbo.NashvilleHousing



Select
parsename(replace(OwnerAddress, ',' , '.'), 3)
, PARSENAME(replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from DataCleaningProject.dbo.NashvilleHousing





alter table DataCleaningProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update DataCleaningProject.dbo.NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',' , '.'), 3)



alter table DataCleaningProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update DataCleaningProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)



alter table DataCleaningProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update DataCleaningProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

Select *
From DataCleaningProject.dbo.NashvilleHousing


--change y and n to yes and no in "sold as vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from DataCleaningProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, Case when SoldAsVacant = 'y' then 'yes'
	when SoldAsVacant = 'n' then 'no'
	else SoldAsVacant
	end
from DataCleaningProject.dbo.NashvilleHousing


Update DataCleaningProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'y' then 'yes'
	when SoldAsVacant = 'n' then 'no'
	else SoldAsVacant
	end




--remove duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							order by 
									UniqueID
									) row_num
From DataCleaningProject.dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


select *
from DataCleaningProject.dbo.NashvilleHousing


-- Delete unused columns


select * 
from DataCleaningProject.dbo.NashvilleHousing


alter table DataCleaningProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
