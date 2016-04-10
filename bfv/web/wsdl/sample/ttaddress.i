
define {&accessor} temp-table ttaddress no-undo
  {&reference-only}
  serialize-name "address"
  field address_id as integer serialize-name "id"
  field addresstype as integer
  field person_id as integer 
  field street as character
  field housenumber as integer
  field addition as character
  field postalcode as character
  field city as character
  field country as character
  index address_id as primary unique address_id
  .
  