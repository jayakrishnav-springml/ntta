CREATE TABLE [Temp].[Fact_UnifiedTransaction_20240107] (
    [TPTripID] bigint NOT NULL, 
    [CustTripID] bigint NULL, 
    [CitationID] bigint NULL, 
    [TripDayID] int NOT NULL, 
    [TripDate] datetime2(3) NULL, 
    [TripWith] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [SourceOfEntry] tinyint NULL, 
    [LaneID] int NULL, 
    [OperationsMappingID] int NULL, 
    [TripIdentMethodID] int NULL, 
    [LaneTripIdentMethodID] smallint NOT NULL, 
    [RecordTypeID] smallint NOT NULL, 
    [TransactionPostingTypeID] int NULL, 
    [TripStageID] bigint NULL, 
    [TripStatusID] bigint NULL, 
    [ReasonCodeID] bigint NULL, 
    [CitationStageID] int NULL, 
    [TripPaymentStatusID] bigint NULL, 
    [CustomerID] bigint NOT NULL, 
    [VehicleID] bigint NOT NULL, 
    [VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagRefID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TxnAgencyID] bigint NULL, 
    [AccountAgencyID] bigint NULL, 
    [VehicleClassID] int NULL, 
    [BadAddressFlag] smallint NULL, 
    [NonRevenueFlag] smallint NULL, 
    [BusinessRuleMatchedFlag] smallint NULL, 
    [ManuallyReviewedFlag] smallint NOT NULL, 
    [OOSPlateFlag] smallint NOT NULL, 
    [VTollFlag] smallint NULL, 
    [ClassAdjustmentFlag] smallint NOT NULL, 
    [Rpt_PaidvsAEA] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [FirstPaidDate] date NULL, 
    [LastPaidDate] date NULL, 
    [ExpectedBase] decimal(19, 2) NULL, 
    [ExpectedPremium] decimal(19, 2) NULL, 
    [ExpectedAmount] decimal(19, 2) NULL, 
    [AdjustedExpectedAmount] decimal(19, 2) NULL, 
    [CalcAdjustedAmount] decimal(19, 2) NOT NULL, 
    [TripWithAdjustedAmount] decimal(19, 2) NULL, 
    [TollAmount] decimal(19, 2) NULL, 
    [ActualPaidAmount] decimal(19, 2) NOT NULL, 
    [OutStandingAmount] decimal(19, 2) NOT NULL, 
    [LND_UpdateDate] datetime2(3) NULL, 
    [EDW_UpdateDate] datetime2(3) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TPTripID]),  PARTITION ([TripDayID] RANGE RIGHT FOR VALUES (20190101, 20190201, 20190301, 20190401, 20190501, 20190601, 20190701, 20190801, 20190901, 20191001, 20191101, 20191201, 20200101, 20200201, 20200301, 20200401, 20200501, 20200601, 20200701, 20200801, 20200901, 20201001, 20201101, 20201201, 20210101, 20210201, 20210301, 20210401, 20210501, 20210601, 20210701, 20210801, 20210901, 20211001, 20211101, 20211201, 20220101, 20220201, 20220301, 20220401, 20220501, 20220601, 20220701, 20220801, 20220901, 20221001, 20221101, 20221201)));