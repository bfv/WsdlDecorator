
define {&accessor} temp-table ttperson no-undo
  {&reference-only}
  serialize-name "person"
  field person_id as integer serialize-name "id"
  field firstname as character
  field middlename as character
  field lastname as character
  field birthdate as date
  index person_id as primary unique person_id
  .
  
  