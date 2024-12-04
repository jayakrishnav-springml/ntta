CREATE TABLE [TollPlus].[DMVResponse]
(
	[DMVResponseID] bigint NOT NULL,
	[FileID] bigint NOT NULL,
	[Original_Input_Request] varchar(160) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CurrentLicense] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateAgeYears] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Reg_ClassCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Plate_Type_Description] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CountyName] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleYear] int NULL,
	[VehicleMake] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Vehicle_Body_Style] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PreviousOwner] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerName_Line1] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerName_Line2] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerAddress_Line1] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerAddress_Line2] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerCity] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerState] varchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerZip] varchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Expiration_MM] int NULL,
	[Expiration_YYYY] int NULL,
	[Previous_Expiration_YYYY] int NULL,
	[VehicleModel] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Registration_IssueDate] datetime2(3) NULL,
	[Vehicle_SoldDate] datetime2(3) NULL,
	[ReceivedDate] datetime2(3) NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[InputLicenseNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleVIN] varchar(44) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleBodyVIN] varchar(44) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StickerNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PreviousLicense] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Renew_Receipt_Name] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Renew_Receipt_Addr_Line1] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Renew_Receipt_Addr_Line2] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Renew_Receipt_Addr_City] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Renew_Receipt_Addr_State] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Renew_Receipt_Addr_Zip] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RTS_TitleNumber] varchar(34) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RTS_TitleDate] datetime2(3) NULL,
	[SurrenerDate] datetime2(3) NULL,
	[Vehicle_Location_Addr] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Vehicle_Location_Addr2] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Vehicle_Location_City] varchar(38) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Vehicle_Location_State] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Vehicle_Location_Zip] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Primary_Color_Code] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Primary_Color] varchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Secondary_Color_Code] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Secondary_Color] varchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Unused_Extra_Space] varchar(82) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerZip2] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Renew_Receipt_Addr_Zip2] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Owner_MiddleName] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Owner_Suffix] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RegExpirationDate] datetime2(3) NULL,
	[ProviderName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([DMVResponseID] DESC), DISTRIBUTION = HASH([DMVResponseID]))
