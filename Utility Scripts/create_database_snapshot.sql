DECLARE
	 @CurrDB		SYSNAME = DB_NAME()
	,@WhatIf		BIT = 1

DECLARE @CMD NVARCHAR(MAX), @SnapshotName SYSNAME;

SET @SnapshotName = @CurrDB + '_snapshot_' + CONVERT(nvarchar, GETDATE(), 112) + REPLACE(CONVERT(nvarchar, GETDATE(), 114),':','');

SELECT @CMD = ISNULL(@CMD + N',
', N'') + N'(NAME = ' + QUOTENAME(name) + N'
, FILENAME = ' + QUOTENAME(LEFT(physical_name, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name)) + 1)
+ @SnapshotName + N'_' + name + '.ss', N'''')
+ N')'
FROM sys.master_files
WHERE type <> 1
AND database_id = DB_ID(@CurrDB)

SELECT
@CMD = N'CREATE DATABASE ' + QUOTENAME(SnapshotName) 
+ ISNULL(N'
ON ' + @CMD, N'') 
+ N'
AS SNAPSHOT OF ' + QUOTENAME(@CurrDB)
, @CurrDB = SnapshotName
FROM
(VALUES (@SnapshotName)) AS v(SnapshotName)

PRINT @CMD
IF @WhatIf = 0 EXEC(@CMD)
