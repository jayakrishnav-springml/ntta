CREATE VIEW [dvo].[DIM_LANE_DIRECTION] AS select	distinct
		LANE_DIRECTION
from	dbo.DIM_LANE_ASOF;
