-record(role_parm, {
  max_level,
  each_level :: [any()]
}).

-record(role_level,{
	exp::integer(),
	max_nums::[integer()]
}).