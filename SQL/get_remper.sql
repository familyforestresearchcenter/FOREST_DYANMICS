SELECT PLOT.CN                  PLT_CN,
       PLOT.MEASYEAR,
       PREV_PLOT.MEASYEAR       PREV_MEASYEAR,
       PLOT.REMPER
  FROM FS_FIADB.POP_EVAL_GRP PEG
  JOIN FS_FIADB.POP_EVAL_TYP PET
    ON (PET.EVAL_GRP_CN = PEG.CN)
  JOIN FS_FIADB.POP_EVAL PEV
    ON (PEV.CN = PET.EVAL_CN)
  JOIN FS_FIADB.POP_ESTN_UNIT PEU
    ON (PEV.CN = PEU.EVAL_CN)
  JOIN FS_FIADB.POP_STRATUM POP_STRATUM
    ON (PEU.CN = POP_STRATUM.ESTN_UNIT_CN)
  JOIN FS_FIADB.POP_PLOT_STRATUM_ASSGN POP_PLOT_STRATUM_ASSGN
    ON (POP_PLOT_STRATUM_ASSGN.STRATUM_CN = POP_STRATUM.CN)
  JOIN FS_FIADB.PLOT PLOT
    ON (POP_PLOT_STRATUM_ASSGN.PLT_CN = PLOT.CN)
  JOIN FS_FIADB.SDS_PLOT SDS_PLOT
    ON (SDS_PLOT.PLT_CN = PLOT.CN)
  JOIN FS_FIADB.PLOT PREV_PLOT
    ON (PREV_PLOT.CN = PLOT.PREV_PLT_CN)
  JOIN FS_FIADB.PLOTGEOM
    ON (PLOT.CN = PLOTGEOM.CN)
  JOIN FS_FIADB.SDS_COND_VW COND
    ON (COND.PLT_CN = PLOT.CN)
  JOIN FS_FIADB.SDS_COND_VW PREV_COND
    ON (PREV_COND.PLT_CN = PLOT.PREV_PLT_CN)
 WHERE COND.CONDPROP_UNADJ IS NOT NULL
   AND PLOT.COUNTYCD &COUNTY
   AND PET.EVAL_TYP = 'EXPCURR'
   AND PEG.EVAL_GRP IN (&EVAL_GRP)
   AND COND.CONDID = 1
   AND PREV_COND.CONDID = 1
   AND COND.COND_STATUS_CD IN (1, 2)
   AND PREV_COND.COND_STATUS_CD IN (1, 2)
   AND 1 = 1
 ORDER BY PLT_CN
