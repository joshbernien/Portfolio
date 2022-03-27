--Update date format
select * 
from PortfolioProject.dbo.NashvilleHousing	
order by UniqueID

select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing	

Update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

select * from PortfolioProject.dbo.NashvilleHousing	

alter table NashvilleHousing
add SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)


--Populating Property Addresses where previously null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.ParcelID
	and a.[uniqueID] != b.[uniqueID]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.ParcelID
	and a.[uniqueID] != b.[uniqueID]
where a.propertyaddress is null

--Breaking down Property Address

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1 , len(PropertyAddress)) as Address


from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1 , len(PropertyAddress))

--Splitting Owner Address

select 
parsename(replace(OwnerAddress, ',', '.'), 3)
,parsename(replace(OwnerAddress, ',', '.'), 2)
,parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


--Deleted Duplicates of Unique ID
SELECT DISTINCT UniqueID,COUNT(*) AS [Number of Duplcates]
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY UniqueID

with CTE as
(
select *, row_number() over 
(partition by UniqueID order by UniqueID) as Dupe
from PortfolioProject.dbo.NashvilleHousing
)
Delete from CTE where Dupe <> 1

--Uniformity in Sold As Vacant Column

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
Order by 2


select distinct(SoldAsVacant)
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject.dbo.NashvilleHousing

update nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

--Removing Duplicate Entries
with RowNumCTE as(
select *,
	row_number() over 
	(
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by ParcelID
	) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1
Order by PropertyAddress

--Deleting Unused Columns 

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



