 
 /*------------------------------------------------------------------------
    File        : RuleProviderBase
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sun Apr 10 12:42:09 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using bfv.web.wsdl.IWsdlRuleProvider from propath.

block-level on error undo, throw.

class bfv.web.wsdl.WsdlRuleProviderBase implements IWsdlRuleProvider: 
  
  {bfv/web/wsdl/ttwsdlrule.i &accessor=protected}
  
  
	method public void GetRules(output table for ttwsdlrule):
	end.
  
  method protected void addRule(rulepathIn as character, ruletypeIn as character, rulevalueIn as character):
    
    create ttwsdlrule.
    assign 
      ttwsdlrule.rulepath = rulepathIn
      ttwsdlrule.ruletype = ruletypeIn
      ttwsdlrule.rulevalue = rulevalueIn
      .

  end method.
  
  
end class.