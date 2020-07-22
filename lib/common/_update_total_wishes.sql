update unit set (total_wishes) = 
  (select count(*) as total from wish where unit.id = wish.unit_id group by unit_id) 
  from wish where unit.id = wish.unit_id