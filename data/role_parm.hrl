-record(role_parm, {
  max_level,
  each_level :: [{Level :: integer(), [Max_num_of_building :: integer()]}],
  exp::integer()
}).