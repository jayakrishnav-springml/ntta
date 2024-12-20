CREATE VIEW [DBO].[TOTAL_NET_REV_TFC_EVTS] AS SELECT *
     FROM (--EXPLAIN
			SELECT -- TOP(10)                      
				  0 ATD_ID,
                  ISNULL (TART.OPNM_ID, -1) OPNM_OPNM_ID,
                  ISNULL(TART.PMTY_ID, -1) PMTY_PMTY_ID,
                  ISNULL(TART.VCLY_ID, -1) VCLY_VCLY_ID,
                  TART.LANE_ID LANE_LANE_ID,
                  TART.TART_ID TART_TART_ID,
                  TART.DATE_TIME,
                  TART.EARNED_REV EAR_REV,
                  TART.EARNED_REV EXP_REV,
                  TART.ACTUAL_REV ACT_REV,
                  TCD.PRE_CLASS AVC_CLASS,
                  TCD.ATT_CLASS IND_CLASS,
                  TCD.REV_AXLE_CT,
                  TCD.ATT_CLASS,
                  TCD.FWD_AXLE_CT,
                  TCD.EXIT_LOOP_CTS,
                  TCD.ATT_FARE,
                  TCD.PRE_CLASS,
                  --DECODE ( ISNULL(TART.OPNM_ID, -1), 3, DECODE (TCD.ATT_CLASS, ISNULL (TART.VCLY_ID, -1), 0, NULL, 0, 1), 0) MISCLASS_CT,
				  CASE	WHEN ISNULL(TART.OPNM_ID, -1) = 3 THEN  CASE WHEN TCD.ATT_CLASS IS NULL OR TCD.ATT_CLASS = ISNULL(TART.VCLY_ID, -1) THEN  0
																		ELSE 1 END		
						ELSE 0 END MISCLASS_CT,
                  0 SIGN_FLG,
                  '' ADJ_STATUS,
                  TART.TXID_ID TXID_ID,                 -- ADDED FOR RITE 2029
                  EE.VES_SERIAL_NO VES_SERIAL_NO,       -- ADDED FOR RITE 2029
				  EE.VES_DATE_TIME,
                  TART.TRANSACTION_FILE_DETAIL_ID            -- 1919 (TSA FIX)
				  ,CAST(BB.AVI_HANDSHAKE AS FLOAT) AVI_HANDSHAKE				  --SELECT TOP(1) *
             FROM LND_LG_HOST.TXNOWNER.TA_REV_TFC_EVTS TART
             LEFT JOIN LND_LG_HOST.TXNOWNER.TA_TXN_AVI_DATAS BB ON TART.TART_ID = BB.TART_ID
			 LEFT JOIN LND_LG_HOST.TXNOWNER.TA_TXN_CLASS_DATAS TCD ON TART.TART_ID = TCD.TART_ID
			 LEFT JOIN LND_LG_HOST.TXNOWNER.TA_TXN_RITE_DATAS EE  ON TART.TART_ID = EE.TART_TART_ID--EE.TART_TART_ID-- ADDED THIS JOIN FOR RITE-2029
			 WHERE TART.PMTY_ID IS NOT NULL --)A
    --       UNION ALL --EXPLAIN
    --       SELECT ATD.ATD_ID,
    --              ATD.OPNM_OPNM_ID,
    --              ATD.PMTY_PMTY_ID,
    --              ATD.VCLY_VCLY_ID,
    --              ATD.LANE_LANE_ID,
    --              ATD.DUMMY_TART_ID,
    --              ATD.DATE_TIME,
    --              CASE WHEN SIGN_FLG = -1 THEN 0 ELSE ATD.EAR_REV END EAR_REV,
    --              CASE WHEN SIGN_FLG = -1 THEN 0 ELSE ATD.EXP_REV END EXP_REV,
    --              0 ACT_REV,
    --              ATD.VCLY_VCLY_ID AVC_CLASS,
    --              ATD.VCLY_VCLY_ID IND_CLASS,
    --              ATD.REV_AXLE_CT,
    --              ATD.ATT_CLASS,
    --              ATD.FWD_AXLE_CT,
    --              ATD.EXIT_LOOP_CTS,
    --              ATD.ATT_FARE,
    --              ATD.PRE_CLASS,
    --              ATD.MISCLASS_CT,
    --              ATD.SIGN_FLG,
    --              '!' ADJ_STATUS,
    --              TART.TXID_ID TXID_ID,                 -- ADDED FOR RITE 2029
    --              EE.VES_SERIAL_NO,                     -- ADDED FOR RITE 2029
				--  EE.VES_DATE_TIME,
    --              TART.TRANSACTION_FILE_DETAIL_ID            -- 1919 (TSA FIX) --SELECT TOP(1) *
    --         FROM LND_LG_HOST.TXNOWNER.AU_TXN_ADJ_DETAILS ATD
    --         LEFT JOIN LND_LG_HOST.TXNOWNER.TA_TXN_AVI_DATAS BB ON ATD.TART_TART_ID = BB.TART_ID
    --         LEFT JOIN LND_LG_HOST.TXNOWNER.TA_TXN_CLASS_DATAS CC ON ATD.TART_TART_ID = CC.TART_ID --ATD.TART_TART_ID
    --         LEFT JOIN LND_LG_HOST.TXNOWNER.TA_TXN_RITE_DATAS EE ON ATD.TART_TART_ID = EE.TART_TART_ID--EE.TART_TART_ID
			 ----LEFT JOIN LND_LG_HOST.TXNOWNER.TA_TXN_RITE_DATAS_NEW EE  ON ATD.TART_ID = EE.TART_ID       
    --         LEFT JOIN LND_LG_HOST.TXNOWNER.TA_REV_TFC_EVTS TART ON ATD.TART_TART_ID = TART.TART_ID
			 ) A;
