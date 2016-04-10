
{bfv/web/wsdl/sample/ttperson.i}
{bfv/web/wsdl/sample/ttaddress.i}

define dataset dspersons
  namespace-uri "http://bfv.io/oe/crm"
  serialize-name "persons"
  for ttperson, ttaddress
  data-relation person_address for ttperson, ttaddress
    relation-fields (person_id, person_id) nested
    .