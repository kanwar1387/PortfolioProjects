-- standardize date format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing;

Update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate); -- not working

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing;

select SaleDateConverted
from NashvilleHousing

-- Populate Property Address data

select *
from NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null


---- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing

select
SUBSTRING( PropertyAddress, 1, charindex( ',', PropertyAddress) -1) as Address -- charindex gives us number means ',' is at which place
, SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, len(PropertyAddress)) as City
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, charindex( ',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, len(PropertyAddress));

SELECT *
FROM NashvilleHousing

select OwnerAddress
from NashvilleHousing

select
parsename(REPLACE(OwnerAddress, ',', '.'),3)
, parsename(REPLACE(OwnerAddress, ',', '.'),2)
, parsename(REPLACE(OwnerAddress, ',', '.'),1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',', '.'),3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',', '.'),2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = parsename(REPLACE(OwnerAddress, ',', '.'),1);

--- change Y AND N TO YES AND NO IN " SOLD AS VACANT " FIELD

SELECT DISTINCT SoldAsVacant , COUNT(*) -- or COUNT(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
	END
from NashvilleHousinG

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
	END

SELECT DISTINCT SoldAsVacant , COUNT(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
ORDER BY 2

------ REMOVE DUPLICATES-----------

WITH RowNumCTE as(
select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference,
ROW_NUMBER() over( PARTITION by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
From NashvilleHousing)
Select *
from RowNumCTE
where row_num >1

WITH RowNumCTE as(
select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference,
ROW_NUMBER() over( PARTITION by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
From NashvilleHousing)
delete
from RowNumCTE
where row_num >1

----DELETE UNUSED COLUMNS----

ALTER TABLE NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
