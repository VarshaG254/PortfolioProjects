--Cleaning Data in SQL Queries

Select *
From [Portfolio Project ].dbo.NashvilleHousing

--Standardized Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project ].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data

Select *
From [Portfolio Project ].dbo.NashvilleHousing
--Where PropertyAddress is nulle
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project ].dbo.NashvilleHousing a
JOIN [Portfolio Project ].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project ].dbo.NashvilleHousing a
JOIN [Portfolio Project ].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking The Addresses into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project ].dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Portfolio Project ].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From [Portfolio Project ].dbo.NashvilleHousing

Select OwnerAddress
From [Portfolio Project ].dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.') ,3)
,PARSENAME(Replace(OwnerAddress,',','.') ,2)
,PARSENAME(Replace(OwnerAddress,',','.') ,1)
From [Portfolio Project ].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From [Portfolio Project ].dbo.NashvilleHousing

--Changing Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project ].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From [Portfolio Project ].dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END

--Remove Duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


From [Portfolio Project ].dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Deleting Unused Columns

Select *
From [Portfolio Project ].dbo.NashvilleHousing

Alter Table [Portfolio Project ].dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [Portfolio Project ].dbo.NashvilleHousing
Drop Column SaleDate