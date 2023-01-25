--Cleaning Data

select * 
from PortfolioProject..[NashvilleHousing ]


--Standard Date Format
---select SaleDate, CONVERT(date, SaleDate)
--from PortfolioProject..[NashvilleHousing ]

alter table PortfolioProject..[NashvilleHousing ]
alter column SaleDate Date

--Populate Property Address Data
select [UniqueID ], ParcelID, PropertyAddress 
from PortfolioProject..[NashvilleHousing ]

select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..[NashvilleHousing ] a inner join PortfolioProject..[NashvilleHousing ] b on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..[NashvilleHousing ] a inner join PortfolioProject..[NashvilleHousing ] b on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--split columns(Address, City, State)
select PropertyAddress 
from PortfolioProject..[NashvilleHousing ]

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) State
from PortfolioProject..[NashvilleHousing ]


--select PropertyAddress,
--left (PropertyAddress, CHARINDEX(',', PropertyAddress)-1) Address_f,
--right (PropertyAddress,LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress))
--from PortfolioProject..[NashvilleHousing ]

--alter table PortfolioProject..[NashvilleHousing ]
--drop column if exists Property_Address_split, Property_city_split

alter table PortfolioProject..[NashvilleHousing ] 
add Property_Address_split nvarchar(255),
Property_city_split nvarchar(255)

update PortfolioProject..[NashvilleHousing ]
SET Property_Address_split = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
Property_city_split = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select OwnerAddress,
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject..[NashvilleHousing ]


alter table PortfolioProject..[NashvilleHousing ] 
add OwnerAddress_split nvarchar(255),
Ownercity_split nvarchar(255),
Ownerstate_split nvarchar(255)

update PortfolioProject..[NashvilleHousing ]
SET OwnerAddress_split = PARSENAME(replace(OwnerAddress, ',', '.'),3),
Ownercity_split = PARSENAME(replace(OwnerAddress, ',', '.'),2),
Ownerstate_split = PARSENAME(replace(OwnerAddress, ',', '.'),1)


--Change Y and N to Yes and No (Sold As Vacant)
select SoldAsVacant
from PortfolioProject..[NashvilleHousing ]

select SoldAsVacant
from PortfolioProject..[NashvilleHousing ]
where SoldAsVacant like 'Y' or SoldAsVacant like 'N'

update PortfolioProject..[NashvilleHousing ]
SET SoldAsVacant = case SoldAsVacant when 'Y' then 'Yes' when 'N' then 'No'
END


--Removing Duplicates
with rownumCTE as(
select *,ROW_NUMBER() over(PARTITION by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from PortfolioProject..[NashvilleHousing ]
)
select * 
from rownumCTE
where row_num>1
order by ParcelID


with rownumCTE as(
select *,ROW_NUMBER() over(PARTITION by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from PortfolioProject..[NashvilleHousing ]
)
Delete 
from rownumCTE
where row_num>1

--Delete Unused Columns
select *
from PortfolioProject..[NashvilleHousing ]

Alter table PortfolioProject..[NashvilleHousing ]
Drop column TaxDistrict, OwnerAddress, PropertyAddress










