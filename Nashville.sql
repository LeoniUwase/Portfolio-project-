 SELECT  * 
 FROM dbo.NashvilleHousing
 
 -- Standardizing the Date format with in the data 

 SELECT SaleDate, CONVERT(DATE, SaleDate)
 FROM dbo.NashvilleHousing

 ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE

UPDATE  dbo.NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

SELECT SaleDate ,CONVERT(Date,SaleDate)
FROM  dbo.NashvilleHousing 

SELECT  * 
FROM dbo.NashvilleHousing


-- Populate Property Address Data 

SELECT *
FROM dbo.NashvilleHousing
WHERE PropertyAddress is NULL 
ORDER BY ParcelID 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
    JOIN dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is Null 

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
    JOIN dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is Null 

SELECT PropertyAddress
FROM dbo.NashvilleHousing

-- Now we are going to breakout individual column into Address,City and State -- 

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing 
ADD Property_Spilt_Address NVARCHAR(225);


UPDATE dbo.NashvilleHousing 
SET Property_Spilt_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE dbo.NashvilleHousing 
ADD Property_Spilt_City NVARCHAR(225);

UPDATE dbo.NashvilleHousing 
SET Property_Spilt_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM dbo.NashvilleHousing

SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT 
  PARSENAME(REPLACE(Owneraddress,',','.'),3)
 ,PARSENAME(REPLACE(Owneraddress, ',','.'),2)
 ,PARSENAME(REPLACE(Owneraddress, ',', '.'),1)
FROM dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing 
ADD Owner_Spilt_Address NVARCHAR(255);

UPDATE NashvilleHousing 
SET Owner_Spilt_Address = PARSENAME(REPLACE(Owneraddress,',','.'),3)

ALTER TABLE NashvilleHousing 
ADD Owner_Spilt_City NVARCHAR(225);

UPDATE NashvilleHousing
SET Owner_Spilt_City = PARSENAME(REPLACE(Owneraddress, ',','.'),2)

ALTER TABLE NashvilleHousing 
ADD Owner_Spilt_State NVARCHAR(255)

UPDATE NashvilleHousing 
SET Owner_Spilt_State = PARSENAME(REPLACE(Owneraddress, ',', '.'),1)

SELECT *
FROM dbo.NashvilleHousing

-- Change Y and N  to Yes and No in 'Sold as Vacant' field 

SELECT DISTINCT (SoldasVacant), COUNT(SoldasVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldasVacant
ORDER BY 2 


SELECT SoldasVacant 
, CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
       WHEN SoldasVacant = 'N' THEN 'No'
       ELSE SoldasVacant 
       END 
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
       WHEN SoldasVacant = 'N' THEN 'No'
       ELSE SoldasVacant 
       END 

  

  SELECT * 
  FROM dbo.NashvilleHousing


  -- Remove the Duplicate 

 WITH Row_Num_CTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
             PARTITION BY ParcelID,
                          PropertyAddress,
                          SalePrice,
                          SaleDate,
                          LegalReference
             ORDER BY UniqueID
         ) AS row_num
  FROM dbo.NashvilleHousing
)

DELETE 
FROM Row_Num_CTE
WHERE row_num > 1;

SELECT * 
FROM dbo.NashvilleHousing 

-- Delete Unused Column 

SELECT * 
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 

Select * 
FROM dbo.NashvilleHousing