 
/*------------------------------------------------------------------------
   File        : WsdlDecorator
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : bronco
   Created     : Thu Apr 07 19:44:45 CEST 2016
   Notes       : 
 ----------------------------------------------------------------------*/

using bfv.web.wsdl.IWsdlDecorator from propath.
using bfv.web.wsdl.IWsdlRuleProvider from propath.
using bfv.sys.log.ILogger from propath.
using bfv.web.wsdl.WsdlAttribute from propath.

block-level on error undo, throw.

class bfv.web.wsdl.WsdlDecorator implements IWsdlDecorator: 
  
  {bfv/web/wsdl/ttwsdlrule.i}
  
  define public property XmlSchemaPrefix as character get. set.
    
  define private variable supportedRules as character no-undo.
  define private variable logger as ILogger no-undo.
  
    
  constructor WsdlDecorator(provider as IWsdlRuleProvider):
    this-object(provider, ?).  
  end. 
  
  
  constructor public WsdlDecorator(provider as IWsdlRuleProvider, loggerIn as ILogger):
    
    supportedRules = "add,remove,restrict".
    logger = loggerIn.
    
    provider:GetRules(output table ttwsdlrule).
         
  end.
  
    
  method public void Decorate(node as handle, currentPath as character):
		
    define variable i as integer no-undo.
    define variable numAttributes as integer no-undo.
    define variable attributeName as character no-undo.
    define variable attributeNames as character no-undo.
    
    
    logthis(currentPath).

    applyRules(node, currentPath).
    
  end method.
	
  
  method private void applyRules(node as handle, currentPath as character):
    
    for each ttwsdlrule:
      
      if (isPathMatch(currentPath, ttwsdlrule.rulePath)) then do:
        
        if (lookup(ttwsdlrule.ruletype, supportedRules) > 0) then
          dynamic-invoke(this-object, "apply" + ttwsdlrule.ruletype + "Rule", node, ttwsdlrule.rulevalue).
                  
      end.
        
    end.
     
  end method.
  
  
  method private void applyRemoveRule(node as handle, ruleString as character):
    
    define variable i as integer no-undo.
    define variable j as integer no-undo.
    define variable numRules as integer no-undo.
    define variable numAttributes as integer no-undo.
    define variable attributes as character no-undo.
    
    define variable attributeName as character no-undo.
    define variable currentRule as character no-undo.
    define variable removeAttribute as logical no-undo.
    
    numAttributes = num-entries(node:attribute-names).
    attributes = node:attribute-names.
    
    numRules = num-entries(ruleString).
    rule:
    do i = 1 to numRules:
      
      currentRule = entry(i, ruleString).
      removeAttribute = false.
      do j = 1 to numAttributes:
        
        attributeName = entry(j, attributes).
        
        if (attributeName = currentRule) then
          removeAttribute = true.
          
        if (currentRule begins "~~" and attributeName begins substring(currentRule, 2)) then 
          removeAttribute = true.
          
        if (removeAttribute) then do:
          node:remove-attribute(attributeName).
          logthis("  remove: " + attributeName).
        end.
          
      end.
      
    end.
    
  end method.

  
  method private void applyAddRule(node as handle, ruleString as character):
    
    define variable i as integer no-undo.
    define variable numRules as integer no-undo.
    define variable attribute as WsdlAttribute no-undo.
    define variable currentRule as character no-undo.
    
    
    numRules = num-entries(ruleString).
    rule:
    do i = 1 to numRules:
      
      currentRule = entry(i, ruleString).
      
      if (num-entries(currentRule, "=") <> 2) then 
        next rule.
      
      attribute = new WsdlAttribute(entry(1, currentRule, "="), entry(2, currentRule, "=")).
      processAttribute(attribute).
      
      node:set-attribute(
        attribute:Name,
        attribute:Value      
      ).
      
      logthis("  add: " + attribute:Name + "=" + attribute:Value).
    
    end.
        
  end method.
  
  
  method private void applyRestrictRule(node as handle, ruleString as character):
    
    define variable typevalue as character no-undo.
    define variable restrictType as character no-undo.
    define variable restrictValue as character no-undo.
    
    restrictType = entry(1, ruleString, "=").
    restrictValue = substring(ruleString, index(ruleString, "=") + 1).
    
    case restrictType:
      
      when "values" then
        addValueRestriction(node, restrictValue).
        
      when "class" then 
        addClassRestriction(node, restrictValue).
          
    end.
          
  end method.
  
  
  method private void addValueRestriction(node as handle, restrictValues as character):
    
    define variable simpleTypeNode as handle no-undo.
    define variable restrictionNode as handle no-undo.
    define variable enumNode as handle no-undo.
    define variable nodeType as character no-undo.
    define variable i as integer no-undo.
    define variable numValues as integer no-undo.
    
    simpleTypeNode = createNode(node, "simpleType").
    
    nodeType = node:get-attribute("type").
    restrictionNode = createNode(simpleTypeNode, "restriction").
    restrictionNode:set-attribute("base", nodeType).
    node:remove-attribute("type").
    
    numValues = num-entries(restrictValues).
    do i = 1 to numValues:
      enumNode = createNode(restrictionNode, "enumeration").
      enumNode:set-attribute("value", trim(entry(i, restrictValues))).
    end.
    
    logthis("  restriction: " + restrictValues).
    
    delete object simpleTypeNode no-error.
    delete object restrictionNode no-error.
    
  end method.
  
  
  method private void addClassRestriction(node as handle, restrictOperation as character):
    
    define variable restrictValues as character no-undo.
    
    if (restrictOperation matches "*()") then do:
      
      restrictValues = dynamic-invoke(
        entry(1, restrictOperation, ":"),
        replace(entry(2, restrictOperation, ":"), "()", "")
      ).
      
    end.
    else do:
      
      restrictValues = dynamic-property(
        entry(1, restrictOperation, ":"),
        replace(entry(2, restrictOperation, ":"), "()", "")
      ).
      
    end.
    
    if (restrictValues > "") then 
      addValueRestriction(node, restrictValues).
    
  end method.
  
    
  method private handle createNode(parentNode as handle, nodeName as character):
    
    define variable node as handle no-undo.
    
    create x-noderef node.
    parentNode:owner-document:create-node(node, nodeName, "element").
    parentNode:append-child(node).
    
    return node.
    
  end method.
  
  
  method private logical isPathMatch(currentPath as character, rulePath as character):
    
    return (currentPath = rulePath or currentPath matches rulePath).
    
  end method.
  
  
  method private void logthis(logText as character):
    
    if (valid-object(logger)) then 
      logger:Log(logText).
    
  end method.
  
  
  method private WsdlAttribute processAttribute(attribute as WsdlAttribute):
    
    if (attribute:Name = "required") then do:
      attribute:Name = "minOccurs".
      attribute:Value = (if (attribute:Value) = "true" then "1" else "0").
    end.
    
    return attribute.
    
  end method.
  
end class.