-- DATA CLEANING

SELECT *
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate) --which sometimes did not work

--Alternative way to convert the date
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

-- Dealing with missing Property Address data
SELECT *
FROM NashvilleHousing
Where PropertyAddress is null

SELECT a.UniqueID,a.ParcelID,a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	and
	a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is null

Update a
Set PropertyAddress=isnull(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	and
	a.UniqueID<>b.UniqueID

-- Breaking the address into more specific columns
SELECT *
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--Changing Values in the Data through Case Expression
Update NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END
	
	

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



