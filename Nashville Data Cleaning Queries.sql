--Populate property address
--It was seen that PropertyAdress is mostly the same for the same parcel ID
--Hence, we populate the missing address using this trend
UPDATE "Nashville" AS a
SET PropertyAddress = b.PropertyAddress
FROM "Nashville" b
WHERE b.ParcelID = a.ParcelID AND a.PropertyAddress IS NULL AND b.PropertyAddress IS NOT NULL
AND a.UniqueID <> b.UniqueID

--Split address to (adress city and state) & Delete Initial PropertyAddress
ALTER TABLE "Nashville"
ADD 'PropertyAddress，City' TEXT;

UPDATE "Nashville" as a
SET 'PropertyAddress，City' = SUBSTR(b.PropertyAddress,1,INSTR(b.PropertyAddress, ',')-1)
FROM "Nashville" b
WHERE b.UniqueID=a.UniqueID;

ALTER TABLE "Nashville"
ADD PropertyState TEXT;

UPDATE "Nashville" as a
SET PropertyState= SUBSTR(b.PropertyAddress, INSTR(b.PropertyAddress, ',')+1,LENGTH(b.PropertyAddress))
FROM "Nashville" b
WHERE b.UniqueID=a.UniqueID;

ALTER TABLE “Nashville”
DROP COLUMN PropertyAddress

--Standardized 'Yes' and 'No' in SoldAsVacant
UPDATE "Nashville" as a
SET SoldAsVacant=CASE b.SoldAsVacant
			WHEN 'Y' THEN 'Yes'
			WHEN 'N' THEN 'No'
		ELSE b.SoldAsVacant END
FROM "Nashville" b
WHERE a.UniqueID=b.UniqueID

--delete duplicates
DELETE FROM "Nashville"
WHERE EXISTS(
WITH t1 AS (Select *, row_number()
             over(PARTITION By
                  ParcelID,
                  PropertyAddress,
                  OwnerAddress,
                  LegalReference,
                  SaleDate,
                  SalePrice
              Order By UniqueID) AS rows
              FROM "Nashville")
SELECT * FROM t1
WHERE rows>1)
