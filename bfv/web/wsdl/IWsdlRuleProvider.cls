
/*------------------------------------------------------------------------
    File        : IWsdlRuleProvider
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Apr 08 14:46:52 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/


interface bfv.web.wsdl.IWsdlRuleProvider:  
  
  {bfv/web/wsdl/ttwsdlrule.i}
  
  method public void GetRules(output table ttwsdlrule).
  
end interface.