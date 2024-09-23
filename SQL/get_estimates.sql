SELECT EVAL_GRP,
       COND_STATUS_CD,
       PREV_COND_STATUS_CD,
       PRESNFCD,
       PREV_PRESNFCD,
       OWNCD,
       PREV_OWNCD,
       RESERVCD,
       PREV_RESERVCD,
       FORTYPCD,
       PREV_FORTYPCD,
       STDORGCD,
       PREV_STDORGCD,
       SITECLCD,
       PREV_SITECLCD,
       SUM(ESTIMATE_BY_ESTN_UNIT.ESTIMATE) ESTIMATE,
       CASE
         WHEN SUM(ESTIMATE_BY_ESTN_UNIT.ESTIMATE) <> 0 THEN
          ABS(SQRT(SUM(ESTIMATE_BY_ESTN_UNIT.VAR_OF_ESTIMATE)) /
              SUM(ESTIMATE_BY_ESTN_UNIT.ESTIMATE) * 100)
         ELSE
          0
       END AS SE_OF_ESTIMATE_PCT,
       SQRT(SUM(ESTIMATE_BY_ESTN_UNIT.VAR_OF_ESTIMATE)) SE_OF_ESTIMATE,
       SUM(ESTIMATE_BY_ESTN_UNIT.VAR_OF_ESTIMATE) VAR_OF_ESTIMATE,
       SUM(ESTIMATE_BY_ESTN_UNIT.TOTAL_PLOTS) TOTAL_PLOTS,
       SUM(ESTIMATE_BY_ESTN_UNIT.NON_ZERO_PLOTS) NON_ZERO_PLOTS,
       SUM(ESTIMATE_BY_ESTN_UNIT.TOT_POP_AREA_ACRES) TOT_POP_AC
  FROM (SELECT POP_EVAL_GRP_CN,
               EVAL_GRP,
               EVAL_GRP_DESCR,
               SUM(COALESCE(YSUM_HD, 0) * PHASE_1_SUMMARY.EXPNS) ESTIMATE,
               PHASE_1_SUMMARY.N TOTAL_PLOTS,
               SUM(PHASE_SUMMARY.NUMBER_PLOTS_IN_DOMAIN) DOMAIN_PLOTS,
               SUM(PHASE_SUMMARY.NON_ZERO_PLOTS) NON_ZERO_PLOTS,
               TOTAL_AREA * TOTAL_AREA / PHASE_1_SUMMARY.N *
               ((SUM(W_H * PHASE_1_SUMMARY.N_H *
                     (((COALESCE(YSUM_HD_SQR, 0) / PHASE_1_SUMMARY.N_H) -
                     ((COALESCE(YSUM_HD, 0) / PHASE_1_SUMMARY.N_H) *
                     (COALESCE(YSUM_HD, 0) / PHASE_1_SUMMARY.N_H))) /
                     (PHASE_1_SUMMARY.N_H - 1)))) +
               1 / PHASE_1_SUMMARY.N *
               (SUM((1 - W_H) * PHASE_1_SUMMARY.N_H *
                     (((COALESCE(YSUM_HD_SQR, 0) / PHASE_1_SUMMARY.N_H) -
                     ((COALESCE(YSUM_HD, 0) / PHASE_1_SUMMARY.N_H) *
                     (COALESCE(YSUM_HD, 0) / PHASE_1_SUMMARY.N_H))) /
                     (PHASE_1_SUMMARY.N_H - 1))))) VAR_OF_ESTIMATE,
               TOTAL_AREA TOT_POP_AREA_ACRES,
               COND_STATUS_CD,
               PREV_COND_STATUS_CD,
               PRESNFCD,
               PREV_PRESNFCD,
               OWNCD,
               PREV_OWNCD,
               RESERVCD,
               PREV_RESERVCD,
               FORTYPCD,
               PREV_FORTYPCD,
               STDORGCD,
               PREV_STDORGCD,
               SITECLCD,
               PREV_SITECLCD
          FROM (SELECT PEV.CN EVAL_CN,
                       PEG.EVAL_GRP,
                       PEG.EVAL_GRP_DESCR,
                       PEG.CN POP_EVAL_GRP_CN,
                       POP_STRATUM.ESTN_UNIT_CN,
                       POP_STRATUM.EXPNS,
                       POP_STRATUM.CN POP_STRATUM_CN,
                       P1POINTCNT /
                       (SELECT SUM(STR.P1POINTCNT)
                          FROM FS_FIADB.POP_STRATUM STR
                         WHERE STR.ESTN_UNIT_CN = POP_STRATUM.ESTN_UNIT_CN) W_H,
                       (SELECT SUM(STR.P1POINTCNT)
                          FROM FS_FIADB.POP_STRATUM STR
                         WHERE STR.ESTN_UNIT_CN = POP_STRATUM.ESTN_UNIT_CN) N_PRIME,
                       P1POINTCNT N_PRIME_H,
                       (SELECT SUM(EU_S.AREA_USED)
                          FROM FS_FIADB.POP_ESTN_UNIT EU_S
                         WHERE EU_S.CN = POP_STRATUM.ESTN_UNIT_CN) TOTAL_AREA,
                       (SELECT SUM(STR.P2POINTCNT)
                          FROM FS_FIADB.POP_STRATUM STR
                         WHERE STR.ESTN_UNIT_CN = POP_STRATUM.ESTN_UNIT_CN) N,
                       POP_STRATUM.P2POINTCNT N_H
                  FROM FS_FIADB.POP_EVAL_GRP PEG
                  JOIN FS_FIADB.POP_EVAL_TYP PET
                    ON (PET.EVAL_GRP_CN = PEG.CN)
                  JOIN FS_FIADB.POP_EVAL PEV
                    ON (PEV.CN = PET.EVAL_CN)
                  JOIN FS_FIADB.POP_ESTN_UNIT PEU
                    ON (PEV.CN = PEU.EVAL_CN)
                  JOIN FS_FIADB.POP_STRATUM POP_STRATUM
                    ON (PEU.CN = POP_STRATUM.ESTN_UNIT_CN)
                 WHERE PEG.EVAL_GRP IN (&EVAL_GRP)
                   AND PET.EVAL_TYP = 'EXPCURR') PHASE_1_SUMMARY
          LEFT OUTER JOIN (SELECT POP_STRATUM_CN,
                                 ESTN_UNIT_CN,
                                 EVAL_CN,
                                 SUM(Y_HID_ADJUSTED) YSUM_HD,
                                 SUM(Y_HID_ADJUSTED * Y_HID_ADJUSTED) YSUM_HD_SQR,
                                 COUNT(*) NUMBER_PLOTS_IN_DOMAIN,
                                 SUM(CASE
                                       WHEN Y_HID_ADJUSTED IS NULL THEN
                                        0
                                       WHEN Y_HID_ADJUSTED = 0 THEN
                                        0
                                       ELSE
                                        1
                                     END) NON_ZERO_PLOTS,
                                 COND_STATUS_CD,
                                 PREV_COND_STATUS_CD,
                                 PRESNFCD,
                                 PREV_PRESNFCD,
                                 OWNCD,
                                 PREV_OWNCD,
                                 RESERVCD,
                                 PREV_RESERVCD,
                                 FORTYPCD,
                                 PREV_FORTYPCD,
                                 STDORGCD,
                                 PREV_STDORGCD,
                                 SITECLCD,
                                 PREV_SITECLCD
                            FROM (SELECT 1                        Y_HID_ADJUSTED,
                                         PEU.CN                   ESTN_UNIT_CN,
                                         PEV.CN                   EVAL_CN,
                                         POP_STRATUM.CN           POP_STRATUM_CN,
                                         PLOT.CN                  PLT_CN,
                                         COND.COND_STATUS_CD      COND_STATUS_CD,
                                         PREV_COND.COND_STATUS_CD PREV_COND_STATUS_CD,
                                         COND.PRESNFCD            PRESNFCD,
                                         PREV_COND.PRESNFCD       PREV_PRESNFCD,
                                         COND.OWNCD               OWNCD,
                                         PREV_COND.OWNCD          PREV_OWNCD,
                                         COND.RESERVCD            RESERVCD,
                                         PREV_COND.RESERVCD       PREV_RESERVCD,
                                         COND.FORTYPCD            FORTYPCD,
                                         PREV_COND.FORTYPCD       PREV_FORTYPCD,
                                         COND.STDORGCD            STDORGCD,
                                         PREV_COND.STDORGCD       PREV_STDORGCD,
                                         COND.SITECLCD            SITECLCD,
                                         PREV_COND.SITECLCD       PREV_SITECLCD
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
                                      ON (POP_PLOT_STRATUM_ASSGN.STRATUM_CN =
                                         POP_STRATUM.CN)
                                    JOIN FS_FIADB.PLOT
                                      ON (POP_PLOT_STRATUM_ASSGN.PLT_CN =
                                         PLOT.CN)
                                    JOIN FS_FIADB.PLOTGEOM
                                      ON (PLOT.CN = PLOTGEOM.CN)
                                    JOIN FS_FIADB.SDS_COND_VW COND
                                      ON (COND.PLT_CN = PLOT.CN)
                                    LEFT OUTER JOIN FS_FIADB.SDS_COND_VW PREV_COND
                                      ON (PREV_COND.PLT_CN = PLOT.PREV_PLT_CN)
                                   WHERE COND.CONDPROP_UNADJ IS NOT NULL
                                     AND PLOT.COUNTYCD
                                   &COUNTY /*Except for AK, OK, and TX this is IS NOT NULL*/
                                     AND PET.EVAL_TYP = 'EXPCURR'
                                     AND PEG.EVAL_GRP IN (&EVAL_GRP) /*Test 12023*/
                                     AND COND.CONDID = 1
                                        /*AND PREV_COND.CONDID = 1 */ /*IF NULL*/
                                     AND ((PLOT.PREV_PLT_CN IS NOT NULL AND
                                         PREV_COND.CONDID = 1) OR
                                         (PLOT.PREV_PLT_CN IS NULL))
                                     AND COND.COND_STATUS_CD <> 5
                                        /* AND PLOT.PREV_PLT_CN IS NOT NULL*/
                                     AND 1 = 1
                                   GROUP BY PEU.CN,
                                            PEV.CN,
                                            POP_STRATUM.CN,
                                            PLOT.CN,
                                            COND.COND_STATUS_CD,
                                            PREV_COND.COND_STATUS_CD,
                                            COND.PRESNFCD,
                                            PREV_COND.PRESNFCD,
                                            COND.OWNCD,
                                            PREV_COND.OWNCD,
                                            COND.RESERVCD,
                                            PREV_COND.RESERVCD,
                                            COND.FORTYPCD,
                                            PREV_COND.FORTYPCD,
                                            COND.STDORGCD,
                                            PREV_COND.STDORGCD,
                                            COND.SITECLCD,
                                            PREV_COND.SITECLCD) PLOT_SUMMARY
                           GROUP BY POP_STRATUM_CN,
                                    ESTN_UNIT_CN,
                                    EVAL_CN,
                                    COND_STATUS_CD,
                                    PREV_COND_STATUS_CD,
                                    PRESNFCD,
                                    PREV_PRESNFCD,
                                    OWNCD,
                                    PREV_OWNCD,
                                    RESERVCD,
                                    PREV_RESERVCD,
                                    FORTYPCD,
                                    PREV_FORTYPCD,
                                    STDORGCD,
                                    PREV_STDORGCD,
                                    SITECLCD,
                                    PREV_SITECLCD) PHASE_SUMMARY
            ON (PHASE_1_SUMMARY.POP_STRATUM_CN =
               PHASE_SUMMARY.POP_STRATUM_CN AND
               PHASE_1_SUMMARY.EVAL_CN = PHASE_SUMMARY.EVAL_CN AND
               PHASE_1_SUMMARY.ESTN_UNIT_CN = PHASE_SUMMARY.ESTN_UNIT_CN)
         GROUP BY PHASE_1_SUMMARY.POP_EVAL_GRP_CN,
                  PHASE_1_SUMMARY.EVAL_GRP,
                  PHASE_1_SUMMARY.EVAL_GRP_DESCR,
                  PHASE_1_SUMMARY.ESTN_UNIT_CN,
                  PHASE_1_SUMMARY.TOTAL_AREA,
                  PHASE_1_SUMMARY.N,
                  COND_STATUS_CD,
                  PREV_COND_STATUS_CD,
                  PRESNFCD,
                  PREV_PRESNFCD,
                  OWNCD,
                  PREV_OWNCD,
                  RESERVCD,
                  PREV_RESERVCD,
                  FORTYPCD,
                  PREV_FORTYPCD,
                  STDORGCD,
                  PREV_STDORGCD,
                  SITECLCD,
                  PREV_SITECLCD) ESTIMATE_BY_ESTN_UNIT
 WHERE NON_ZERO_PLOTS IS NOT NULL
 GROUP BY POP_EVAL_GRP_CN,
          EVAL_GRP,
          EVAL_GRP_DESCR,
          COND_STATUS_CD,
          PREV_COND_STATUS_CD,
          PRESNFCD,
          PREV_PRESNFCD,
          OWNCD,
          PREV_OWNCD,
          RESERVCD,
          PREV_RESERVCD,
          FORTYPCD,
          PREV_FORTYPCD,
          STDORGCD,
          PREV_STDORGCD,
          SITECLCD,
          PREV_SITECLCD
