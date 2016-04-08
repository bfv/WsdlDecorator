 
 /*------------------------------------------------------------------------
    File        : WsdlProcessor
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Thu Apr 07 15:04:22 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using bfv.web.wsdl.WsdlProcessor from propath.
using bfv.web.wsdl.IWsdlDecorator from propath.

block-level on error undo, throw.

class bfv.web.wsdl.WsdlProcessor: 
  
  define private variable sourceDoc as handle no-undo.
  define private variable targetDoc as handle no-undo.
  define private variable sourceRootNode as handle no-undo.
  define private variable targetRootNode as handle no-undo.
  define private variable tmpnode as handle no-undo.
  define private variable attrnode as handle no-undo.
  define private variable valuenode as handle no-undo.
  define private variable targetnode as handle no-undo.
  define private variable targetvaluenode as handle no-undo.
  define private variable currentpath as character no-undo.
  define private variable decorator as IWsdlDecorator no-undo.
  define private variable xmlSchemaPrefix as character no-undo.
  
  
  constructor WsdlProcessor():
    
  end.
  
  destructor WsdlProcessor():
    delete object sourceDoc no-error.
    delete object targetDoc no-error.
    delete object sourceRootNode no-error.
    delete object tmpnode no-error.
    delete object attrnode no-error.
    delete object valuenode no-error.
    delete object targetvaluenode no-error.
  end.
  
  
  method public longchar Decorate(decoratorIn as IWsdlDecorator, wsdlIn as longchar):
    
    decorator = decoratorIn.
    
    init().
    
    loadSourceDocument(wsdlIn).
    initializeTargetDocument().
    parseSourceDocument().
    
    return writeTargetDocument().
    
  end.
  
  
  method private void init():
    create x-noderef tmpnode.
    create x-noderef attrnode.
    create x-noderef valuenode.
    create x-noderef targetvaluenode.
  end method.
  
  
  
  method private void loadSourceDocument(wsdl as longchar):
    
    define variable wsdlfile as character no-undo.
    
    if (wsdl begins "file:///") then do:
      wsdlfile = substring(wsdl, 9).
      copy-lob file wsdlfile to wsdl.
    end.
    
    create x-document sourceDoc.
    sourceDoc:load("longchar", wsdl, false).
    
    create x-noderef sourceRootNode.
    sourceDoc:get-document-element(sourceRootNode).
    
    getXmlSchemaPrefix(sourceRootNode).
    
  end method.
  
  
  method private void initializeTargetDocument(): 
    create x-document targetDoc.
  end method.
  
  
  method private void parseSourceDocument():
    
    define variable i as integer no-undo.
    
    targetDoc:encoding = sourceDoc:encoding.
    
    /* setup the root node for the target */
    targetRootNode = copyNode(sourceRootNode, ?).
    targetDoc:append-child(targetRootNode).
    
    do i = 1 to sourceRootNode:num-children:
      sourceRootNode:get-child(tmpnode, i).
      if (tmpnode:subtype = "element") then
        traverseNode(tmpnode, targetRootNode).  
    end.
    
  end method.
  
  
  method private void traverseNode(currentsource as handle, currenttarget as handle):
    
    define variable i as integer no-undo.
    define variable childnode as handle no-undo.
    define variable copiednode as handle no-undo.
    define variable pathWasExpanded as logical no-undo.
    
    create x-noderef copiednode.
    
    pathWasExpanded = addToCurrentPath(currentsource).
    getXmlSchemaPrefix(currentsource).
    
    // copy first
    copiednode = copyNode(currentsource, ?).
    currenttarget:append-child(copiednode).
    
    if (currentsource:num-children > 0) then
      create x-noderef childnode.
      
    do i = 1 to currentsource:num-children:
      currentsource:get-child(childnode, i).
      if (childnode:subtype = "element") then 
        traverseNode(childnode, copiednode). 
    end.
    
    if (pathWasExpanded) then
      removeFromCurrentPath(currentsource).
    
    finally:
      delete object childnode no-error.
      delete object copiednode no-error.
    end.
    
  end method.

  
  method private handle copyNode(sourceNode as handle, targetNode as handle):
    
    define variable i as integer no-undo.
    define variable numEntries as integer no-undo.
    define variable attrname as character no-undo.
    define variable hasNameAtrribute as logical no-undo.
    
    
    if (not valid-handle(targetNode)) then do:
      create x-noderef targetNode.
      targetDoc:create-node(targetNode, sourceNode:name, sourceNode:subtype).
    end.
    
    /* copy attributes */
    numEntries = num-entries(sourceNode:attribute-names).
    do i = 1 to numEntries:
      
      attrname = entry(i, sourceNode:attribute-names).    
      if (attrname = "name") then
        hasNameAtrribute = true.
        
      targetNode:set-attribute(attrname, sourceNode:get-attribute(attrname)).
    end.
    
    if (valid-object(decorator) and hasNameAtrribute) then 
      decorator:Decorate(targetNode, currentpath).
    
    /* copy content */   
    do i = 1 to sourceNode:num-children:
      
      sourceNode:get-child(valuenode, i).      
      if (valuenode:subtype = "text" and trim(valuenode:node-value) > "") then do:
        targetDoc:create-node(targetvaluenode, ?, "text").
        targetvaluenode:node-value =  trim(valuenode:node-value).
        targetNode:append-child(targetvaluenode).
      end.
      
    end.
    
    return targetNode.
    
  end method.


  method private longchar writeTargetDocument():
    
    define variable resultWsdl as longchar no-undo.
    
    targetDoc:save("longchar", resultWsdl).
    
    return resultWsdl.
    
  end method.
  
  
  method private logical addToCurrentPath(node as handle): 
    
    define variable hasNameAttribute as logical no-undo.
    
    hasNameAttribute = (lookup("name", node:attribute-names) > 0).
    if (hasNameAttribute) then
      currentpath = currentpath + "/" + node:get-attribute("name").
    
    return hasNameAttribute.
    
  end method.
  
  
  method private void removeFromCurrentPath(node as handle):    
    currentpath = substring(currentpath, 1, r-index(currentpath, "/") - 1).
  end method.
  
  
  method private character getXmlSchemaPrefix(node as handle):
    
    define variable i as integer no-undo.
    define variable numAttributes as integer no-undo.
    define variable attributeName as character no-undo.
    define variable attributeValue as character no-undo.
    
    numAttributes = num-entries(node:attribute-names).
    loopattr:
    do i = 1 to numAttributes:
      
      attributeName = entry(i, node:attribute-names).
      attributeValue = node:get-attribute(attributeName).
      
      if (attributeValue = "http://www.w3.org/2001/XMLSchema") then do:
        
        if (num-entries(attributeName, ":") = 2) then
          xmlSchemaPrefix = entry(2, attributeName, ":").
        else 
          xmlSchemaPrefix = "".
          
        leave loopattr.
      end.
      
    end.
    
    if (valid-object(decorator)) then
      decorator:XmlSchemaPrefix = xmlSchemaPrefix.
    
    return xmlSchemaPrefix.
      
  end method.
  
  
end class.