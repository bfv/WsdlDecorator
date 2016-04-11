 
 /*------------------------------------------------------------------------
    File        : PersonRuleProvider
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sun Apr 10 09:11:08 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using bfv.web.wsdl.WsdlRuleProviderBase from propath.

class bfv.web.wsdl.sample.PersonRuleProvider inherits WsdlRuleProviderBase: 
  
 
  constructor public PersonRuleProvider():
    
    addRule("/*", "remove", "nillable,~~prodata").
    addRule("/persons/person/firstname", "add", "required=true"). 
    addRule("/persons/person/address", "add", "minOccurss=1,maxOccurs=3").
    addRule("/persons/person/address/addresstype", "restrict", "class=bfv.web.wsdl.sample.AddressTypeEnum:GetValues()").
    //temp-table ttwsdlrule:write-json("file", "c:/tmp/json.out.json").
  end.
  
end class.