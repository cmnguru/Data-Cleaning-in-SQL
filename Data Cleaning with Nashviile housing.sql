---- Cleaning data in sql

Select *
From Portfolioproject..Nashvillehousing

--Standardize Date Format

Select SaledateConverted, Convert(Date,saledate)
From Portfolioproject..Nashvillehousing

Update Nashvillehousing
SET saledate = Convert(Date,saledate) 

---- If it didnt work out, check out

Alter Table Nashvillehousing
Add SaleDateConverted Date;

Update Nashvillehousing
SET SaleDateConverted = Convert(Date,saledate)


---Populate Property Address Data

Select *
From Portfolioproject..Nashvillehousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.propertyAddress)
From Portfolioproject..Nashvillehousing  a
JOIN Portfolioproject..Nashvillehousing  b 
    ON a.parcelID =b.ParcelID
	AND a.UniqueID <> b.uniqueID
Where a.PropertyAddress is null
order by a.ParcelID, b.ParcelID Desc

Update a
SET PropertyAddress = ISNULL(a.propertyaddress,b.propertyAddress)
From Portfolioproject..Nashvillehousing  a
JOIN Portfolioproject..Nashvillehousing  b 
    ON a.parcelID =b.ParcelID
	AND a.UniqueID <> b.uniqueID
Where a.PropertyAddress is null

--Breaking out Addrress into individual columns (Address, city ,state)

Select *
From Portfolioproject..Nashvillehousing
--Where PropertyAddress is null
---order by PropertyAddress 

Select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Portfolioproject..Nashvillehousing

Alter Table Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

Alter Table Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update Nashvillehousing
SET  PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From Portfolioproject..Nashvillehousing


----Using parsename to make things easier

Select 
PARSENAME(REPLACE(Owneraddress,',','.'),3),
PARSENAME(REPLACE(Owneraddress,',','.'),2),
PARSENAME(REPLACE(Owneraddress,',','.'),1)
From Portfolioproject..Nashvillehousing


Alter Table Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress,',','.'),3)


Alter Table Nashvillehousing
Add OwnerSplitCity Nvarchar(255);

Update Nashvillehousing
SET  OwnerSplitCity = PARSENAME(REPLACE(Owneraddress,',','.'),2)


Alter Table Nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update Nashvillehousing
SET  OwnerSplitState = PARSENAME(REPLACE(Owneraddress,',','.'),1)



---Changing Y and N to YESand NO in SoldAsVacant
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolioproject..Nashvillehousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE 
    When SoldAsVacant = 'Y' Then 'YES'
	When SoldAsVacant = 'N' Then 'NO'
	Else SoldAsVacant
	End
From Portfolioproject..Nashvillehousing

Update Nashvillehousing
   SET SoldAsVacant 
  =CASE 
    When SoldAsVacant = 'Y' Then 'YES'
	When SoldAsVacant = 'N' Then 'NO'
	Else SoldAsVacant
	End


-----Removing Duplicates


WITH RowNumCTE AS(
Select*,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
		     SalePrice,
		     SaleDate,
		     LegalReference
		     ORDER BY 
		     UniqueID
		     ) row_num

From Portfolioproject..Nashvillehousing
---Order by ParcelID
)

Select * --Delete 
From RowNumCTE
Where row_num >1
--Order by PropertyAddress


----Delete Unused Columns
Select *
From Portfolioproject..Nashvillehousing


Alter Table Portfolioproject..Nashvillehousing
Drop Column Owneraddress, TaxDistrict,Propertyaddress


Alter Table Portfolioproject..Nashvillehousing
Drop Column Saledate