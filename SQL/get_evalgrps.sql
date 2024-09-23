select peg.eval_grp,
       peg.statecd,
       peg.eval_grp_descr,
        pe.start_invyr,
       pe.end_invyr
  from FS_FIADB.pop_eval pe, FS_FIADB.pop_eval_grp peg
 where peg.cn = pe.eval_grp_cn
 group by peg.eval_grp,
          peg.statecd,
          peg.eval_grp_descr,
           pe.start_invyr,
          pe.end_invyr
 order by peg.statecd, pe.end_invyr desc
