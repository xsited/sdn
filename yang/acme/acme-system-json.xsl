<?xml version='1.0' encoding='utf-8'?>
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:acme="http://acme.example.com/system" xmlns:en="urn:ietf:params:xml:ns:netconf:notification:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"><output method="text" /><include href="/usr/local/share/yang/xslt/jsonxsl-templates.xsl" /><strip-space elements="*" /><template name="nsuri-to-module"><param name="uri" /><choose><when test="$uri='http://acme.example.com/system'"><text>acme-system</text></when></choose></template><template match="//nc:*/acme:system"><call-template name="container"><with-param name="level">1</with-param></call-template></template><template match="//nc:*/acme:system/acme:host-name"><call-template name="leaf"><with-param name="level">2</with-param><with-param name="type">string</with-param></call-template></template><template match="//nc:*/acme:system/acme:domain-search"><call-template name="leaf-list"><with-param name="level">2</with-param><with-param name="type">string</with-param></call-template></template><template match="//nc:*/acme:system/acme:interface"><call-template name="list"><with-param name="level">2</with-param></call-template></template><template match="//nc:*/acme:system/acme:interface/acme:name"><call-template name="leaf"><with-param name="level">4</with-param><with-param name="type">string</with-param></call-template></template><template match="//nc:*/acme:system/acme:interface/acme:type"><call-template name="leaf"><with-param name="level">4</with-param><with-param name="type">string</with-param></call-template></template><template match="//nc:*/acme:system/acme:interface/acme:mtu"><call-template name="leaf"><with-param name="level">4</with-param><with-param name="type">unquoted</with-param></call-template></template></stylesheet>