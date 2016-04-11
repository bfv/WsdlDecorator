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

## Rule Providers ##
A rule provider can be anything which implements the interface `bfv.web.wsdl.IWsdlRuleProvider`. Since there's only one method inside, which is there to return the temp-table ttwsdlrule, the rest of the implementation is whatever you want. There's one provider alredy there, the `WsdlJsonRuleProvider`, which accepts JSON as input data for the temp-table. Setting up a provider can be as simple as:
```
define variable provider  as IWsdlRuleProvider no-undo.

provider = new WsdlJsonRuleProvider("./bfv/web/wsdl/sample/person.rules.json").
``` 
The purpose of a rule provider is to provide data for the Decorator.


