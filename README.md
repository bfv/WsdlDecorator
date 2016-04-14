# WsdlDecorator #
If you don't have full control over a generated WSDL, this decorator gives the possibility to add your extra defs to the wsdl. Written in OpenEdge (11.6) 

## Rules ##
All rules have 3 components, the path, the type and the value. These rules are stored in the ttwsdlrule temp-table
```
define {&accessor} temp-table ttwsdlrule no-undo
  serialize-name "rules"
  field rulepath as character
  field ruletype as character
  field rulevalue as character
  .
```

### paths 
For a dataset persons, table person is path looks like: `/persons/person`
The firstName field with the person table can be addressed as `/persons/person/firstName`
A `*` can be used as wildcard. This is evaluated with the OpenEdge `matches` operator. A path of `/*` is true for each path starting with `/`

There are 3 types of rules:
* remove - removes an attribute for the given path, if exists
* add - adds an attribute
* restrict - set an restriction of values for the element in the path

### remove ###
In a remove rules multiple attributes can be removed, it's a comma separated list. The entries of the list are compared with first equality and then the matches operator. A value of `nillable,prodata*` removes the nillable attributes as well as all the attributes starting with prodata (for the given path).

### add ###
Comma separated list of attributes which will be added to the given path. Name and value are separated with the `=`. 
example: `minOccurs=1,maxOccurs=2`

### restrict ###
restrict gives the possibility to specify the valid values for an element (commaseparated). If the original element in the WSDL looks like: 
```
<element name="addresstype" nillable="true" type="xsd:int"/>
```
a restrict on value 1,2,3 will make the WSDL look like: 
```
<element name="addresstype">
	<simpleType>
		<restriction base="xsd:int">
			<enumeration value="1"/>
			<enumeration value="2"/>
			<enumeration value="3"/>
		</restriction>
	</simpleType>
</element>
```

a restriction can also have a value which looks like: 
```
class:bfv.crm.AddressTypeEnum:Values
class:bfv.crm.AddressTypeEnum:GetValues()
```

The above sample works voor static properties and methods right now. If the restriction ends with () it expected to be a method, otherwise a property. 

## Rule Providers ##
A rule provider can be anything which implements the interface `bfv.web.wsdl.IWsdlRuleProvider`. Since there's only one method inside, which is there to return the temp-table ttwsdlrule, the rest of the implementation is whatever you want. There's one provider alredy there, the `WsdlJsonRuleProvider`, which accepts JSON as input data for the temp-table. Setting up a provider can be as simple as:
```
define variable provider  as IWsdlRuleProvider no-undo.

provider = new WsdlJsonRuleProvider("./bfv/web/wsdl/sample/person.rules.json").
``` 
The purpose of a rule provider is to provide data for the Decorator.

## Decorators ###
A decorator is the class which implements the `bfv.web.wsdl.IWsdlDecorator` interface:
```
interface bfv.web.wsdl.IWsdlDecorator:  
  define public property XmlSchemaPrefix as character get. set.
  method public void Decorate(node as handle, currentPath as character).
end interface.
```

the `node` is the xml node in target xml document, the `currentPath` the full path of the node.
Based on there two parameters the Decorator can perform the rules it received via the Rule Provider. The provider is supplied to the decorator via the constructor of the decorator. Since the WsdlProcessor is only dependent on the `IWsdlDecorator` interface you could supply anything as a decorator. The `bfv.web.wsdl.WsdlDecorator` is a good starting point.

## WsdlProcessor ##
The class which orchestrates the decoration of the WSDL. It basically copied nodes from the source document to the target document. Furthermore it calls the Decorate method of the provider. The provider is passed to the Processor via the Decorate method:
```
method public longchar Decorate(decoratorIn as IWsdlDecorator, wsdlIn as longchar):
```
The input parameter can be both the content of a WSDL or a filename. In the latter case it must be prefixed with `file:///`. Currently only elements which have a `name` attribute are passed to the decorator.

## Sample ##
```
using bfv.web.wsdl.*. from propath.

define variable decorator as WsdlDecorator no-undo.
define variable parser as WsdlProcessor no-undo.
define variable wsdl as longchar no-undo.
define variable provider as IWsdlRuleProvider no-undo.


provider = new WsdlJsonRuleProvider("./bfv/web/wsdl/sample/person.rules.json").

decorator = new WsdlDecorator(provider).
parser = new WsdlProcessor().

wsdl = parser:Decorate(decorator, "file:///<whatever your root is>\bfv\web\wsdl\sample\wsperson.wsdl").

copy-lob wsdl to file "<whatever your root is>\bfv\web\wsdl\sample\wsperson.decorated.wsdl".
```

### Logging ###
Sometimes it can be useful to see what the actions of the decorator are. It is possible to pass a logger to the constructor of the decorator:
```
using bfv.web.wsdl.*. from propath.
using bfv.sys.*. from propath.

define variable logger as ILogger no-undo.

...

logger = new Logger("c:/temp/wsdldecoration.log").
decorator = new WsdlDecorator(provider, logger).
```

Anything which satisfies the `bfv.sys.ILogger` interface is usable. The supplied `bfv.sys.Logger` write to the specified file.
