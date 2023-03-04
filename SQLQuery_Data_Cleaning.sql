/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM Portfolio_Project..Nashville_Housing

-------------------------------------------
--Standardize Data Format

--Convert Dataformat
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Portfolio_Project..Nashville_Housing

--Using Update
--Updating does not work
Update Portfolio_Project..Nashville_Housing
SET SaleDate = CONVERT(Date, SaleDate)

--Using Update with Neu Column
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Portfolio_Project..Nashville_Housing

ALTER TABLE Portfolio_Project..Nashville_Housing
ADD SaleDateConverted Date;

Update Portfolio_Project..Nashville_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------
--Populate Property Address Data 

SELECT *
FROM Portfolio_Project..Nashville_Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Self Join
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Portfolio_Project..Nashville_Housing A
JOIN Portfolio_Project..Nashville_Housing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Corrected Address where Null is with Join
UPDATE A
SET PropertyAddress =  ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Portfolio_Project..Nashville_Housing A
JOIN Portfolio_Project..Nashville_Housing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

------------------------------------------------------------------------

--Breaking out Address Into Inividual Columns (Address, City, State) from PropertyAddress

SELECT PropertyAddress
FROM Portfolio_Project..Nashville_Housing

--Using SUBSTRING(Columnname, from, to) And CHARTINDE(substring, string)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Portfolio_Project..Nashville_Housing

ALTER TABLE Portfolio_Project..Nashville_Housing
ADD Property_Split_Address Nvarchar(255);

Update Portfolio_Project..Nashville_Housing
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE Portfolio_Project..Nashville_Housing
ADD Property_Split_City Nvarchar(255);

Update Portfolio_Project..Nashville_Housing
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT *
FROM Portfolio_Project..Nashville_Housing

-------------------------------------------------------------------------------
--Breaking out Address Into Inividual Columns (Address, City, State) from OwnerName

SELECT OwnerAddress
FROM Portfolio_Project..Nashville_Housing

--Using PARSENAME
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
FROM Portfolio_Project..Nashville_Housing

ALTER TABLE Portfolio_Project..Nashville_Housing
ADD Owner_Split_Address Nvarchar(255);

Update Portfolio_Project..Nashville_Housing
SET Owner_Split_Address =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Portfolio_Project..Nashville_Housing
ADD Owner_Split_City Nvarchar(255);

Update Portfolio_Project..Nashville_Housing
SET Owner_Split_City =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Portfolio_Project..Nashville_Housing
ADD Owner_Split_State Nvarchar(255);

Update Portfolio_Project..Nashville_Housing
SET Owner_Split_State =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM Portfolio_Project..Nashville_Housing

------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

--Show, how many N, Y, Yes and No have
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

--Show changed vs. old
SELECT 
  CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
  END AS Correctur, SoldAsVacant
FROM Portfolio_Project..Nashville_Housing

--Update SoldAsVacant
UPDATE Portfolio_Project..Nashville_Housing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
  END

SELECT SoldAsVacant
FROM Portfolio_Project..Nashville_Housing

--------------------------------------------------------------------
--Remove Duplicates

--Def a ROW_NUMBER as CTE
WITH Rownum_CTE AS(
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
      ORDER BY UniqueID) Rownums
  FROM Portfolio_Project..Nashville_Housing
)

--DELETE Dublicate
DELETE
FROM Rownum_CTE
WHERE Rownums > 1


SELECT *
FROM Rownum_CTE
WHERE Rownums > 1
ORDER BY PropertyAddress

--------------------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM Portfolio_Project..Nashville_Housing

ALTER TABLE Portfolio_Project..Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress