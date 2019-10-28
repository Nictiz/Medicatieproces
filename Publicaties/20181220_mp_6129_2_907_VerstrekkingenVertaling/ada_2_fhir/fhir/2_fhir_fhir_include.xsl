<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright © Nictiz

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<!-- Templates of the form 'make<datatype/flavor>Value' correspond to ART-DECOR supported datatypes / HL7 V3 Datatypes R1 -->
<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:uuid="http://www.uuid.org" xmlns:local="urn:fhir:stu3:functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- import because we want to be able to override the param for macAddress -->
    <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
    <!-- 02-00-00-00-00-00 may not be used in a production situation -->
    <xsl:import href="../../util/uuid.xsl"/>
    <xsl:import href="../../util/constants.xsl"/>
    <xsl:import href="../../util/datetime.xsl"/>
    <xsl:import href="../../util/units.xsl"/>
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
    <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
    <!-- 02-00-00-00-00-00 may not be used in a production situation -->
    <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>

    <xd:doc>
        <xd:desc>Privacy parameter. Accepts a comma separated list of patient ID root values (normally OIDs). When an ID is encountered with a root value in this list, then this ID will be masked in the output data. This is useful to prevent outputting Dutch bsns (<xd:ref name="oidBurgerservicenummer" type="variable"/>) for example. Default is to include any ID in the output as it occurs in the input.</xd:desc>
    </xd:doc>
    <xsl:param name="mask-ids" as="xs:string?"/>
    <xsl:variable name="mask-ids-var" select="tokenize($mask-ids, ',')" as="xs:string*"/>

    <xd:doc>
        <xd:desc>Returns an array of FHIR elements based on an array of ADA that a @datatype attribute to determine the type with. 
            <xd:p>After the type is determined, the element is handed off for further processing. Failure to determine type is a fatal error.</xd:p>
            <xd:p>Supported values for @datatype are ADA/DECOR datatypes boolean, code, identifier, quantity, string, text, blob, date, datetime</xd:p>
            <xd:p>FIXME: ‘ordinal’, ‘ratio' support</xd:p>
        </xd:desc>
        <xd:param name="in">Optional. Array of elements to process. If empty array, then no output is created.</xd:param>
        <xd:param name="elemName">Required. Base name of the FHIR element to produce. Gets postfixed with datatype, e.g. valueBoolean</xd:param>
    </xd:doc>
    <xsl:template name="any-to-value">
        <xsl:param name="in" select="." as="element()*"/>
        <xsl:param name="elemName" as="xs:string" required="yes"/>

        <xsl:for-each select="$in">
            <xsl:variable name="theDatatype" select="@datatype"/>

            <xsl:choose>
                <xsl:when test="$theDatatype = 'code' or @code">
                    <xsl:element name="{concat($elemName, 'CodeableConcept')}" namespace="http://hl7.org/fhir">
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$theDatatype = 'identifier' or @root">
                    <xsl:element name="{concat($elemName, 'Identifier')}" namespace="http://hl7.org/fhir">
                        <xsl:call-template name="id-to-Identifier">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <!-- Observation//value does not do valueDecimal, hence quantity without unit -->
                <xsl:when test="$theDatatype = ('quantity', 'duration', 'currency', 'decimal') or @unit">
                    <xsl:element name="{concat($elemName, 'Quantity')}" namespace="http://hl7.org/fhir">
                        <xsl:call-template name="hoeveelheid-to-Quantity">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$theDatatype = 'boolean' or @value castable as xs:boolean">
                    <xsl:element name="{concat($elemName, 'Boolean')}" namespace="http://hl7.org/fhir">
                        <xsl:call-template name="boolean-to-boolean">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$theDatatype = ('date', 'datetime') or @value castable as xs:date or @value castable as xs:dateTime">
                    <xsl:element name="{concat($elemName, 'DateTime')}" namespace="http://hl7.org/fhir">
                        <xsl:call-template name="date-to-datetime">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$theDatatype = 'blob' and (not(@value) or @value castable as xs:base64Binary)">
                    <xsl:element name="{concat($elemName, 'Attachment')}" namespace="http://hl7.org/fhir">
                        <xsl:call-template name="blob-to-attachment">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$theDatatype = ('string', 'text') or not($theDatatype)">
                    <xsl:element name="{concat($elemName, 'String')}" namespace="http://hl7.org/fhir">
                        <xsl:call-template name="string-to-string">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">Cannot determine the datatype based on @datatype, or value not supported: <xsl:value-of select="$theDatatype"/></xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Transforms ada boolean element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#boolean">@value</xd:a></xd:desc>
        <xd:param name="in">the ada boolean element, may have any name but should have ada datatype boolean</xd:param>
    </xd:doc>
    <xsl:template name="boolean-to-boolean" as="item()?">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:choose>
            <xsl:when test="$in/@value">
                <xsl:attribute name="value" select="$in/@value"/>
            </xsl:when>
            <xsl:when test="$in/@nullFlavor">
                <extension url="{$urlExtHL7NullFlavor}">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada string element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#string">@value</xd:a></xd:desc>
        <xd:param name="in">the ada string element, may have any name but should have ada datatype string</xd:param>
    </xd:doc>
    <xsl:template name="string-to-string" as="item()?">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:choose>
            <xsl:when test="$in/@value">
                <xsl:attribute name="value" select="$in/@value"/>
            </xsl:when>
            <xsl:when test="$in/@nullFlavor">
                <extension url="{$urlExtHL7NullFlavor}">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada string element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#datetime">@value</xd:a></xd:desc>
        <xd:param name="in">the ada date(time) element, may have any name but should have ada datatype date(time)</xd:param>
    </xd:doc>
    <xsl:template name="date-to-datetime" as="item()?">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:choose>
            <xsl:when test="$in/@value">
                <xsl:attribute name="value" select="$in/@value"/>
            </xsl:when>
            <xsl:when test="$in/@nullFlavor">
                <extension url="{$oidHL7NullFlavor}">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada blob element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#Attachment">data/@value</xd:a></xd:desc>
        <xd:param name="in">the ada blob element, may have any name but should have ada datatype blob</xd:param>
    </xd:doc>
    <xsl:template name="blob-to-attachment" as="item()?">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:choose>
            <xsl:when test="$in/@value">
                <data value="{$in/@value}"/>
            </xsl:when>
            <xsl:when test="$in/@nullFlavor">
                <extension url="{$urlExtHL7NullFlavor}">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada code element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#code">@value</xd:a></xd:desc>
        <xd:param name="in">the ada code element, may have any name but should have ada datatype code</xd:param>
        <xd:param name="codeMap">Array of map elements to be used to map input HL7v3 codes to output ADA codes if those differ. See handleCV for more documentation.
            
            <xd:p>Example. if you only want to translate ActStatus completed into a FHIR ObservationStatus final, this would suffice:</xd:p>
            <xd:p><code>&lt;map inCode="completed" inCodeSystem="$codeSystem" code="final"/&gt;</code>
                <div>to produce</div>
                <code>&lt;$elemName value="final"/&gt;</code></xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="code-to-code" as="attribute(value)?">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="codeMap" as="element()*"/>

        <xsl:for-each select="$in">
            <xsl:variable name="theCode">
                <xsl:choose>
                    <xsl:when test="@code">
                        <xsl:value-of select="@code"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@nullFlavor"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="theCodeSystem">
                <xsl:choose>
                    <xsl:when test="@code">
                        <xsl:value-of select="@codeSystem"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$oidHL7NullFlavor"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="out" as="element()">
                <xsl:choose>
                    <xsl:when test="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]">
                        <xsl:copy-of select="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]"/>
                    </xsl:when>
                    <xsl:when test="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]">
                        <xsl:copy-of select="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:attribute name="value">
                <xsl:value-of select="$out/@code"/>
                <!-- In the case where codeMap if only used to add a @value for ADA, this saves having to repeat the @inCode and @inCodeSystem as @code resp. @codeSystem -->
                <xsl:if test="not($out/@code) and not(empty($theCode))">
                    <xsl:value-of select="$theCode"/>
                </xsl:if>
            </xsl:attribute>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada code element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#CodeableConcept">CodeableConcept contents</xd:a></xd:desc>
        <xd:param name="in">the ada code element, may have any name but should have ada datatype code</xd:param>
        <xd:param name="elementName">Optionally provide the element name, default = coding. In extensions it is valueCoding.</xd:param>
        <xd:param name="userSelected">Optionally provide a user selected boolean.</xd:param>
    <xd:param name="treatNullFlavorAsCoding">Optionally provide a boolean to treat an input NullFlavor as coding. 
            Needed for when the nullFlavor is part of the valueSet. Defaults to false, which puts the NullFlavor in an extension.</xd:param>
    </xd:doc>
    <xsl:template name="code-to-CodeableConcept" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:param name="elementName" as="xs:string?">coding</xsl:param>
        <xsl:param name="userSelected" as="xs:boolean?"/>
        <xsl:param name="treatNullFlavorAsCoding" as="xs:boolean?" select="false()"/>
        <xsl:choose>
            <xsl:when test="$in[@codeSystem = $oidHL7NullFlavor] and not($treatNullFlavorAsCoding)">
                <extension url="{$urlExtHL7NullFlavor}">
                    <valueCode value="{$in/@code}"/>
                </extension>
            </xsl:when>
            <xsl:when test="$in[not(@codeSystem = $oidHL7NullFlavor) or $treatNullFlavorAsCoding]">
                <xsl:element name="{$elementName}">
                    <xsl:call-template name="code-to-Coding">
                        <xsl:with-param name="in" select="$in"/>
                        <xsl:with-param name="userSelected" select="$userSelected"/>
                    <xsl:with-param name="treatNullFlavorAsCoding" select="$treatNullFlavorAsCoding"/>
                    </xsl:call-template>
                </xsl:element>
                <!--<xsl:if test="$in/@displayName">
                    <text value="{$in/@displayName}"/>
                </xsl:if>-->
                <!-- ADA heeft geen ondersteuning voor vertalingen, dus onderstaande is theoretisch -->
                <xsl:for-each select="$in/translation">
                    <xsl:element name="{$elementName}">
                        <xsl:call-template name="code-to-Coding">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$in[@originalText]">
            <text value="{$in/@originalText}"/>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada code element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#Coding">Coding contents</xd:a></xd:desc>
        <xd:param name="in">the ada code element, may have any name but should have ada datatype code</xd:param>
        <xd:param name="userSelected">Optionally provide a user selected boolean.</xd:param>
    <xd:param name="treatNullFlavorAsCoding">Optionally provide a boolean to treat an input NullFlavor as coding. 
            Needed for when the nullFlavor is part of the valueSet. Defaults to false, which puts the NullFlavor in an extension.</xd:param>
    </xd:doc>
    <xsl:template name="code-to-Coding" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:param name="userSelected" as="xs:boolean?"/>
        <xsl:param name="treatNullFlavorAsCoding" as="xs:boolean?" select="false()"/>
        <xsl:choose>
            <xsl:when test="$in[@codeSystem = $oidHL7NullFlavor] and not($treatNullFlavorAsCoding)">
                <extension url="{$urlExtHL7NullFlavor}">
                    <valueCode value="{$in/@code}"/>
                </extension>
            </xsl:when>
            <xsl:when test="$in[not(@codeSystem = $oidHL7NullFlavor) or $treatNullFlavorAsCoding]">
                <system value="{local:getUri($in/@codeSystem)}"/>
                <code value="{$in/@code}"/>
                <xsl:if test="$in/@displayName">
                    <display value="{$in/@displayName}"/>
                </xsl:if>
                <xsl:if test="exists($userSelected)">
                    <userSelected value="{$userSelected}"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada 'hoeveelheid' element to FHIR Duration</xd:desc>
        <xd:param name="in">the ada 'hoeveelheid' element, may have any name but should have ada datatype hoeveelheid (quantity)</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-to-Duration" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:variable name="unit-UCUM" select="$in/nf:convertTime_ADA_unit2UCUM_FHIR(@unit)"/>
        <xsl:choose>
            <xsl:when test="$in[@value]">
                <value value="{$in/@value}"/>
                <xsl:if test="$unit-UCUM">
                    <unit value="{$in/@unit}"/>
                    <system value="{local:getUri($oidUCUM)}"/>
                    <code value="{$unit-UCUM}"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$in[@nullFlavor]">
                <extension url="{$urlExtHL7NullFlavor}">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada numerator and denominator elements to FHIR Ratio</xd:desc>
        <xd:param name="numerator">ada numerator element, may have any name but should have sub elements eenheid with datatype code and waarde with datatype aantal (count)</xd:param>
        <xd:param name="denominator">ada denominator element, may have any name but should have sub elements eenheid with datatype code and waarde with datatype aantal (count)</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-complex-to-Ratio" as="element()*">
        <xsl:param name="numerator" as="element()?"/>
        <xsl:param name="denominator" as="element()?"/>

        <xsl:for-each select="$numerator">
            <numerator>
                <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                    <xsl:with-param name="eenheid" select="./eenheid"/>
                    <xsl:with-param name="waarde" select="./waarde"/>
                </xsl:call-template>
            </numerator>
        </xsl:for-each>
        <xsl:for-each select="$denominator">
            <denominator>
                <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                    <xsl:with-param name="eenheid" select="./eenheid"/>
                    <xsl:with-param name="waarde" select="./waarde"/>
                </xsl:call-template>
            </denominator>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element of type hoeveelheid to FHIR Quantity</xd:desc>
        <xd:param name="in">ada element may have any name but should have datatype aantal (count)</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-to-Quantity" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$in[not(@value) or @nullFlavor]">
                <extension url="{$urlExtHL7NullFlavor}">
                    <xsl:variable name="valueCode" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$in[@nullFlavor]">
                                <xsl:value-of select="$in/@nullFlavor"/>
                            </xsl:when>
                            <xsl:otherwise>NI</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <valueCode value="{$valueCode}"/>
                </extension>
            </xsl:when>
            <xsl:otherwise>
                <value value="{$in/@value}"/>
                <xsl:for-each select="$in[@unit]">
                    <!-- UCUM -->
                    <unit value="{./@unit}"/>
                    <xsl:choose>
                        <xsl:when test="$in[@datatype = 'currency']">
                            <system value="urn:iso:std:iso:4217"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <system value="{local:getUri($oidUCUM)}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <code value="{nf:convert_ADA_unit2UCUM_FHIR(./@unit)}"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada waarde and eenheid elements to FHIR Quantity</xd:desc>
        <xd:param name="waarde">ada element may have any name but should have datatype aantal (count)</xd:param>
        <xd:param name="eenheid">ada element may have any name but should have datatype code</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-complex-to-Quantity" as="element()*">
        <xsl:param name="waarde" as="element()?"/>
        <xsl:param name="eenheid" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$waarde[not(@value) or @nullFlavor]">
                <extension url="{$urlExtHL7NullFlavor}">
                    <xsl:variable name="valueCode" select="
                            if ($waarde[@nullFlavor]) then
                                ($waarde/@nullFlavor)
                            else
                                ('NI')"/>
                    <valueCode value="{$valueCode}"/>
                </extension>
            </xsl:when>
            <xsl:otherwise>
                <value value="{$waarde/@value}"/>
                <xsl:for-each select="$eenheid[@code]">
                    <xsl:for-each select="./@displayName">
                        <unit value="{.}"/>
                    </xsl:for-each>
                    <xsl:for-each select="./@codeSystem">
                        <system value="{local:getUri(.)}"/>
                    </xsl:for-each>
                    <code value="{if (@codeSystem = $oidUCUM) then nf:convert_ADA_unit2UCUM_FHIR($eenheid/@code) else $eenheid/@code}"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element to FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#Identifier">Identifier contents</xd:a>. Masks ids, e.g. Burgerservicenummers, if their @root occurs in <xd:ref name="mask-ids" type="parameter"/></xd:desc>
        <xd:param name="in">ada element with datatype identifier</xd:param>
    </xd:doc>
    <xsl:template name="id-to-Identifier" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$in[@nullFlavor]">
                <extension url="{$urlExtHL7NullFlavor}">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
            <xsl:when test="$in[string-length(@root) gt 0][@root = $mask-ids-var]">
                <system value="{local:getUri($in/@root)}"/>
                <value>
                    <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                        <valueCode value="masked"/>
                    </extension>
                </value>
            </xsl:when>
            <xsl:when test="$in[@value | @root]">
                <xsl:for-each select="$in/@root">
                    <system value="{local:getUri(.)}"/>
                </xsl:for-each>
                <xsl:for-each select="$in/@value">
                    <value value="{.}"/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element with zib type interval and only start and end date to FHIR Period</xd:desc>
        <xd:param name="in">ada element with sub ada elements start and end date (both with datatype dateTime)</xd:param>
    </xd:doc>
    <xsl:template name="startend-to-Period" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:for-each select="$in">
            <xsl:choose>
                <xsl:when test="start_datum_tijd[@nullFlavor]">
                    <start>
                        <extension url="{$urlExtHL7NullFlavor}">
                            <valueCode value="{start_datum_tijd/@nullFlavor}"/>
                        </extension>
                    </start>
                </xsl:when>
                <xsl:when test="start_datum_tijd[@value]">
                    <start value="{nf:add-Amsterdam-timezone(start_datum_tijd/@value)}"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="eind_datum_tijd[@nullFlavor]">
                    <end>
                        <extension url="{$urlExtHL7NullFlavor}">
                            <valueCode value="{eind_datum_tijd/@nullFlavor}"/>
                        </extension>
                    </end>
                </xsl:when>
                <xsl:when test="eind_datum_tijd[@value]">
                    <end value="{nf:add-Amsterdam-timezone(eind_datum_tijd/@value)}"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Transforms ada element to FHIR Range</xd:desc>
        <xd:param name="in">ada element with sub ada elements min and max (both with datatype aantal/count) and a sibling ada element eenheid (datatype code)</xd:param>
    </xd:doc>
    <xsl:template name="minmax-to-Range" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$in/min[@nullFlavor]">
                <low>
                    <extension url="{$urlExtHL7NullFlavor}">
                        <valueCode value="{$in/min/@nullFlavor}"/>
                    </extension>
                </low>
            </xsl:when>
            <xsl:when test="$in/min[@value]">
                <low>
                    <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                        <xsl:with-param name="eenheid" select="$in/../eenheid"/>
                        <xsl:with-param name="waarde" select="$in/min"/>
                    </xsl:call-template>
                </low>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$in/max[@nullFlavor]">
                <high>
                    <extension url="{$urlExtHL7NullFlavor}">
                        <valueCode value="{$in/max/@nullFlavor}"/>
                    </extension>
                </high>
            </xsl:when>
            <xsl:when test="$in/max[@value]">
                <high>
                    <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                        <xsl:with-param name="eenheid" select="$in/../eenheid"/>
                        <xsl:with-param name="waarde" select="$in/max"/>
                    </xsl:call-template>
                </high>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element numerator-aantal, -eenheid and denominator to FHIR Ratio</xd:desc>
        <xd:param name="numeratorAantal">ada element of datatype aantal (count)</xd:param>
        <xd:param name="numeratorEenheid">ada element of datatype code</xd:param>
        <xd:param name="denominator">ada element of datatype hoeveelheid (quantity)</xd:param>
    </xd:doc>
    <xsl:template name="quotient-to-Ratio" as="element()*">
        <xsl:param name="numeratorAantal" as="element()?"/>
        <xsl:param name="numeratorEenheid" as="element()?"/>
        <xsl:param name="denominator" as="element()?"/>
        <xsl:if test="$numeratorAantal | $numeratorEenheid">
            <numerator>
                <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                    <xsl:with-param name="eenheid" select="$numeratorEenheid"/>
                    <xsl:with-param name="waarde" select="$numeratorAantal"/>
                </xsl:call-template>
            </numerator>
        </xsl:if>
        <xsl:for-each select="$denominator">
            <denominator>
                <xsl:call-template name="hoeveelheid-to-Duration">
                    <xsl:with-param name="in" select="."/>
                </xsl:call-template>
            </denominator>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Converts an ada time unit to the UCUM unit as used in FHIR</xd:desc>
        <xd:param name="ADAtime">The ada time unit string</xd:param>
    </xd:doc>
    <xsl:function name="nf:convertTime_ADA_unit2UCUM_FHIR" as="xs:string?">
        <xsl:param name="ADAtime" as="xs:string?"/>
        <xsl:if test="$ADAtime">
            <xsl:choose>
                <xsl:when test="$ADAtime = $ada-unit-second">s</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-minute">min</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-hour">h</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-day">d</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-week">wk</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-month">mo</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-year">a</xsl:when>
                <xsl:otherwise>
                    <!-- If all else fails: wrap in {} to make it an annotation -->
                    <xsl:value-of select="concat('{', $ADAtime, '}')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    <xd:doc>
        <xd:desc>Converts an ada unit to the UCUM unit as used in FHIR</xd:desc>
        <xd:param name="ADAunit">The ada unit string</xd:param>
    </xd:doc>
    <xsl:function name="nf:convert_ADA_unit2UCUM_FHIR" as="xs:string?">
        <xsl:param name="ADAunit" as="xs:string?"/>
        <xsl:if test="$ADAunit">
            <xsl:choose>
                <xsl:when test="$ADAunit = $ada-unit-gram">g</xsl:when>
                <xsl:when test="$ADAunit = $ada-unit-kilo">kg</xsl:when>
                <xsl:when test="$ADAunit = $ada-unit-cm">cm</xsl:when>
                <xsl:when test="$ADAunit = $ada-unit-m">m</xsl:when>
                <xsl:when test="nf:isValidUCUMUnit($ADAunit)">
                    <xsl:value-of select="$ADAunit"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- If all else fails: wrap in {} to make it an annotation -->
                    <xsl:value-of select="concat('{', $ADAunit, '}')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    <xd:doc>
        <xd:desc>Get the FHIR System URI based on an input OID from ada or HL7. xs:anyURI if possible, urn:oid:.. otherwise</xd:desc>
        <xd:param name="oid">input OID from ada or HL7</xd:param>
    </xd:doc>
    <xsl:function name="local:getUri" as="xs:string?">
        <xsl:param name="oid" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$oidMap[@oid = $oid][@uri]">
                <xsl:value-of select="$oidMap[@oid = $oid]/@uri"/>
            </xsl:when>
            <xsl:when test="matches($oid, $OIDpattern)">
                <xsl:value-of select="concat('urn:oid:', $oid)"/>
            </xsl:when>
            <xsl:when test="matches($oid, $UUIDpattern)">
                <xsl:value-of select="concat('urn:uuid:', $oid)"/>
            </xsl:when>
            <xsl:when test="matches($oid, '^https?:')">
                <xsl:value-of select="$oid"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$oid"/>
                <xsl:message>WARNING: local:getUri() expects an OID, but got "<xsl:value-of select="$oid"/>"</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc>Returns a UUID with urn:uuid: preconcatenated</xd:desc>
        <xd:param name="in">xml element to be used to generate uuid</xd:param>
    </xd:doc>
    <xsl:function name="nf:get-fhir-uuid" as="xs:string">
        <xsl:param name="in" as="element()"/>
        <xsl:value-of select="concat('urn:uuid:', uuid:get-uuid($in))"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>Returns a UUID</xd:desc>
        <xd:param name="in">xml element to be used to generate uuid</xd:param>
    </xd:doc>
    <xsl:function name="nf:get-uuid" as="xs:string">
        <xsl:param name="in" as="element()"/>
        <xsl:value-of select="uuid:get-uuid($in)"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>If possible generates an uri based on oid or uuid from input. If not possible generates an uri based on gerenated uuid making use of input element</xd:desc>
        <xd:param name="adaIdentification">input element for which uri is needed</xd:param>
    </xd:doc>
    <xsl:function name="nf:getUriFromAdaId" as="xs:string">
        <xsl:param name="adaIdentification" as="element()"/>

        <xsl:choose>
            <!-- root = oid and extension = numeric -->
            <xsl:when test="$adaIdentification[matches(@root, $OIDpattern)][matches(@value, '^\d+$')]">
                <xsl:variable name="ii" select="$adaIdentification[matches(@root, $OIDpattern)][matches(@value, '^\d+$')][1]"/>
                <xsl:value-of select="concat('urn:oid:', $ii/string-join((@root, replace(@value, '^0+', '')[not(. = '')]), '.'))"/>
            </xsl:when>
            <!-- root = oid and no extension -->
            <xsl:when test="$adaIdentification[matches(@root, $OIDpattern)][not(@value)]">
                <xsl:variable name="ii" select="$adaIdentification[matches(@root, $OIDpattern)][not(@value)][1]"/>
                <xsl:value-of select="concat('urn:oid:', $ii/string-join((@root, replace(@value, '^0+', '')[not(. = '')]), '.'))"/>
            </xsl:when>
            <!-- root = 'not important' and extension = uuid -->
            <xsl:when test="$adaIdentification[matches(@value, $UUIDpattern)]">
                <xsl:variable name="ii" select="$adaIdentification[matches(@value, $UUIDpattern)][1]"/>
                <xsl:value-of select="concat('urn:uuid:', $ii/@value)"/>
            </xsl:when>
            <!-- root = uuid and extension = 'not important' -->
            <xsl:when test="$adaIdentification[matches(@root, $UUIDpattern)]">
                <xsl:variable name="ii" select="$adaIdentification[matches(@root, $UUIDpattern)][1]"/>
                <xsl:value-of select="concat('urn:uuid:', $ii/@root)"/>
            </xsl:when>
            <!-- give up and do new uuid -->
            <xsl:otherwise>
                <xsl:value-of select="nf:get-fhir-uuid($adaIdentification[1])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="in"/>
    </xd:doc>
    <xsl:function name="nf:removeSpecialCharacters" as="xs:string?">
        <xsl:param name="in" as="xs:string?"/>
        <xsl:value-of select="replace(translate($in, '_.', '--'), '[^a-zA-Z0-9-]', '')"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Generates FHIR uri based on input ada code element. OID if possible, otherwise generates uri based on generated uuid using input element.</xd:desc>
        <xd:param name="adaCode">Input element for which uri is needed</xd:param>
    </xd:doc>
    <xsl:function name="nf:getUriFromAdaCode" as="xs:string?">
        <xsl:param name="adaCode" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$adaCode[matches(@codeSystem, $OIDpattern)][matches(@code, '^\d+$')]">
                <!-- No leading zeroes -->
                <xsl:value-of select="concat('urn:oid:', $adaCode/string-join((@codeSystem, replace(@code, '^0+', '')), '.'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="nf:get-fhir-uuid($adaCode)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>Try to interpret the value of complex type in ADA as a quantity string with value and unit</xd:desc>
        <xd:param name="value_string">The input text (like 12 mmol/l). Any comma in the value will be replaced with a dot, e.g. 1,05 will be returned as 1.05</xd:param>
        <xd:return>
            <xd:p>A collection of 'value' and possibly 'unit' tags if the string could be interpreted as a quantity string, or an empty collection.</xd:p>
            <xd:p><xd:b>NOTE:</xd:b> even if the string is interpreted as a quantity, only the textual 'unit' tag is included in the result, not a formal system/code pair.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="nf:try-complex-as-Quantity" as="element()*">
        <xsl:param name="value_string" as="xs:string?"/>
        <xsl:analyze-string select="normalize-space($value_string)" regex="^([\d\.,]+)\s*(.*)$">
            <xsl:matching-substring>
                <value value="{replace(regex-group(1), ',', '.')}"/>
                <xsl:if test="regex-group(2)">
                    <unit value="{regex-group(2)}"/>
                </xsl:if>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xd:doc>
        <xd:desc>Formats ada normal or relativeDate(time) or HL7 dateTime to FHIR date(Time) or Touchstone T variable string based on input precision</xd:desc>
        <xd:param name="dateTime">Input ada or HL7 date(Time)</xd:param>
        <xd:param name="precision">Determines the precision of the output. Precision of minutes outputs seconds as '00'</xd:param>
    <xd:param name="dateT">Optional parameter. The T-date for which a relativeDate must be calculated. If not given a Touchstone like parameterised string is outputted</xd:param>
        
    </xd:doc>
    <xsl:template name="format2FHIRDate">
        <xsl:param name="dateTime" as="xs:string?"/>
        <!-- precision determines the picture of the date format, currently only use case for day, minute or second. Seconds is the default. -->
        <xsl:param name="precision">second</xsl:param>
        <xsl:param name="dateT" as="xs:date?"/>
        
        <xsl:variable name="picture" as="xs:string?">
            <xsl:choose>
                <xsl:when test="upper-case($precision) = ('DAY', 'DAG', 'DAYS', 'DAGEN', 'D')">[Y0001]-[M01]-[D01]</xsl:when>
                <xsl:when test="upper-case($precision) = ('MINUTE', 'MINUUT', 'MINUTES', 'MINUTEN', 'MIN', 'M')">[Y0001]-[M01]-[D01]T[H01]:[m01]:00Z</xsl:when>
                <xsl:otherwise>[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="normalize-space($dateTime) castable as xs:dateTime">
                <xsl:value-of select="format-dateTime(xs:dateTime($dateTime), $picture)"/>
            </xsl:when>
            <xsl:when test="normalize-space($dateTime) castable as xs:date">
                <xsl:value-of select="format-date(xs:date($dateTime), '[Y0001]-[M01]-[D01]')"/>
            </xsl:when>
            <!-- there may be a relative date(time) like "T-50D{12:34:56}" in the input -->
            <xsl:when test="matches($dateTime, 'T[+\-]\d+(\.\d+)?[YMD]')">
                <xsl:variable name="sign" select="replace($dateTime, 'T([+\-]).*', '$1')"/>
                <xsl:variable name="amount" select="replace($dateTime, 'T[+\-](\d+(\.\d+)?)[YMD].*', '$1')"/>
                <xsl:variable name="yearMonthDay" select="replace($dateTime, 'T[+\-]\d+(\.\d+)?([YMD]).*', '$2')"/>
                <xsl:variable name="xsDurationString" select="replace($dateTime, 'T[+\-](\d+(\.\d+)?)([YMD]).*', 'P$1$3')"/>
                <xsl:variable name="timePart" select="replace($dateTime, 'T[+\-]\d+(\.\d+)?[YMD](\{(.*)})?', '$3')"/>
                <xsl:variable name="time">
                    <xsl:choose>
                        <xsl:when test="string-length($timePart) = 5">
                            <!-- time given in minutes, let's add 0 seconds -->
                            <xsl:value-of select="concat($timePart, ':00')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$timePart"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$dateT castable as xs:date">
                        <xsl:variable name="newDate" select="nf:calculate-t-date($dateTime, $dateT)"/>
                        <xsl:choose>
                            <xsl:when test="$newDate castable as xs:dateTime">
                                <!-- in an ada relative datetime the timezone is not permitted (or known), let's add the timezon -->
                                <xsl:value-of select="nf:add-Amsterdam-timezone-to-dateTimeString($newDate)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$newDate"/>
                            </xsl:otherwise>
                        </xsl:choose>                        
                      </xsl:when>
                    <xsl:otherwise>
                        <!-- output a relative date for Touchstone -->
                        <xsl:value-of select="concat('${DATE, T, ', $yearMonthDay, ', ', $sign, $amount, '}')"/>
                        <xsl:if test="$time castable as xs:time">
                            <!-- we'll assume the timezone (required in FHIR) because there is no way of knowing the T-date -->
                            <xsl:value-of select="concat('T', $time, '+02:00')"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- let's try if the input is HL7 date or dateTime, should not be since input is ada -->
                <xsl:variable name="newDateTime" select="replace(concat(normalize-space($dateTime), '00000000000000'), '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})', '$1-$2-$3T$4:$5:$6')"/>
                <xsl:variable name="newDate" select="replace(normalize-space($dateTime), '^(\d{4})(\d{2})(\d{2})', '$1-$2-$3')"/>
                <xsl:choose>
                    <xsl:when test="$newDateTime castable as xs:dateTime">
                        <xsl:value-of select="format-dateTime(xs:dateTime($newDateTime), $picture)"/>
                    </xsl:when>
                    <xsl:when test="$newDate castable as xs:date">
                        <xsl:value-of select="format-date(xs:date($newDateTime), $picture)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$dateTime"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Based on http://hl7.org/fhir/STU3/cm-data-absent-reason-v3.html</xd:desc>
        <xd:param name="in">Input node with @codeSystem = <xd:ref name="$oidHL7NullFlavor" type="variable"/></xd:param>
    </xd:doc>
    <xsl:template name="NullFlavor-to-DataAbsentReason" as="element()?">
        <xsl:param name="in" select="." as="element()?"/>

        <xsl:for-each select="$in[@codeSystem = $oidHL7NullFlavor]">
            <extension url="{$urlExtHL7DataAbsentReason}">
                <valueCode>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="@code = 'UNK'">unknown</xsl:when>
                            <xsl:when test="@code = 'ASKU'">asked</xsl:when>
                            <xsl:when test="@code = 'NAV'">temp</xsl:when>
                            <xsl:when test="@code = 'NASK'">not-asked</xsl:when>
                            <xsl:when test="@code = 'MSK'">masked</xsl:when>
                            <xsl:when test="@code = 'NA'">unsupported</xsl:when>
                            <xsl:otherwise>unknown</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </valueCode>
            </extension>
        </xsl:for-each>
    </xsl:template>

    <!-- FHIR Utility Functions -->

    <xd:doc>
        <xd:desc/>
        <xd:param name="entry"/>
    </xd:doc>
    <xsl:function name="nf:getFullUrlOrId" as="xs:string?">
        <xsl:param name="entry" as="element(f:entry)?"/>

        <xsl:choose>
            <xsl:when test="$referById">
                <xsl:value-of select="$entry/f:resource/*/concat(local-name(), '/', f:id[1]/@value)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$entry/f:fullUrl/@value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>If <xd:ref name="in" type="parameter"/> holds a value, return the upper-cased combined string of @value/@root/@code/@codeSystem/@nullFlavor. Else return empty</xd:desc>
        <xd:param name="in"/>
    </xd:doc>
    <xsl:function name="nf:getGroupingKeyDefault" as="xs:string?">
        <xsl:param name="in" as="element()?"/>
        <xsl:if test="$in">
            <xsl:value-of select="upper-case(string-join(($in//@value, $in//@root, $in//@unit, $in//@code[not(../@codeSystem = $oidHL7NullFlavor)], $in//@codeSystem[not(. = $oidHL7NullFlavor)])/normalize-space(), ''))"/>
        </xsl:if>
    </xsl:function>

    <xd:doc>
        <xd:desc>If <xd:ref name="patient" type="parameter"/> holds a value, return the upper-cased combined string of @value/@root/@code/@codeSystem/@nullFlavor on the patient_identification_number/name_information/address_information/contact_information. Else return empty</xd:desc>
        <xd:param name="patient"/>
    </xd:doc>
    <xsl:function name="nf:getGroupingKeyPatient" as="xs:string?">
        <xsl:param name="patient" as="element()?"/>
        <xsl:if test="$patient">
            <xsl:value-of select="concat(nf:getGroupingKeyDefault($patient/identificatienummer[not(@root = $oidBurgerservicenummer)] | $patient/patient_identificatie_nummer[not(@root = $oidBurgerservicenummer)] | $patient/patient_identification_number[not(@root = $oidBurgerservicenummer)]), nf:getGroupingKeyDefault($patient/patient_naam | $patient/name_information), nf:getGroupingKeyDefault($patient/adres | $patient/address_information), nf:getGroupingKeyDefault($patient/telefoon_email | $patient/contact_information))"/>
        </xsl:if>
    </xsl:function>

    <xd:doc>
        <xd:desc>If <xd:ref name="healthProfessional" type="parameter"/> holds a value, return the upper-cased combined string of @value/@root/@code/@codeSystem/@nullFlavor on the health_professional_identification_number/name_information/address_information/contact_information. Else return empty</xd:desc>
        <xd:param name="healthProfessional"/>
    </xd:doc>
    <xsl:function name="nf:getGroupingKeyPractitioner" as="xs:string?">
        <xsl:param name="healthProfessional" as="element()?"/>
        <xsl:variable name="personIdentifier" select="nf:getGroupingKeyDefault($healthProfessional/zorgverlener_identificatienummer | $healthProfessional/zorgverlener_identificatie_nummer | $healthProfessional/health_professional_identification_number)"/>
        <xsl:variable name="personName" select="nf:getGroupingKeyDefault($healthProfessional/zorgverlener_naam | $healthProfessional/naamgegevens | $healthProfessional/name_information)"/>
        <xsl:variable name="personAddress" select="nf:getGroupingKeyDefault($healthProfessional/adres | $healthProfessional/adresgegevens | $healthProfessional/address_information)"/>
        <xsl:variable name="contactInformation" select="nf:getGroupingKeyDefault($healthProfessional/telefoon_email | $healthProfessional/contactgegevens | $healthProfessional/contact_information)"/>

        <xsl:value-of select="concat($personIdentifier, $personName, $personAddress, $contactInformation)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>If <xd:ref name="healthProfessional" type="parameter"/> holds a value, return the upper-cased combined string of @value/@root/@code/@codeSystem/@nullFlavor on the health_professional_identification_number/name_information/address_information/contact_information. Else return empty</xd:desc>
        <xd:param name="healthProfessional"/>
    </xd:doc>
    <xsl:function name="nf:getGroupingKeyPractitionerRole" as="xs:string?">
        <xsl:param name="healthProfessional" as="element()?"/>
        <xsl:variable name="personIdentifier" select="nf:getGroupingKeyDefault(nf:ada-zvl-id($healthProfessional/zorgverlener_identificatienummer | $healthProfessional/zorgverlener_identificatie_nummer | $healthProfessional/health_professional_identification_number))"/>
        <xsl:variable name="specialism" select="nf:getGroupingKeyDefault($healthProfessional/specialisme | $healthProfessional/specialty)"/>
        <xsl:variable name="organizationId" select="nf:getGroupingKeyDefault(nf:ada-za-id($healthProfessional//zorgaanbieder_identificatienummer | $healthProfessional//healthcare_provider_identification_number))"/>

        <xsl:value-of select="concat($personIdentifier, $specialism, $organizationId)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="healthProfessional"/>
    </xd:doc>
    <xsl:function name="nf:get-practitioner-display" as="xs:string?">
        <xsl:param name="healthProfessional" as="element()?"/>
        <xsl:for-each select="$healthProfessional">
            <xsl:variable name="personIdentifier" select="nf:ada-zvl-id(.//zorgverlener_identificatienummer[1] | .//zorgverlener_identificatie_nummer[1] | .//health_professional_identification_number[1])/@value"/>
            <xsl:variable name="personName" select=".//naamgegevens[1]//*[not(name() = 'naamgebruik')]/@value | .//name_information[1]//*[not(name() = 'name_usage')]/@value"/>
            <xsl:variable name="organizationName" select=".//organisatie_naam[1]/@value | .//organization_name[1]/@value"/>
            <xsl:variable name="specialty" select=".//specialisme/@displayName | .//specialty/@displayName"/>
            <xsl:variable name="role" select=".//zorgverleners_rol/(@displayName, @code)[1] | .//health_professional_role/(@displayName, @code)[1]"/>

            <xsl:choose>
                <xsl:when test="$personName">
                    <xsl:value-of select="normalize-space(string-join($personName, ' '))"/>
                </xsl:when>
                <xsl:when test="$role">
                    <xsl:value-of select="normalize-space($role)"/>
                </xsl:when>
                <xsl:when test="$personIdentifier">
                    <xsl:value-of select="normalize-space($personIdentifier)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="healthProfessional"/>
    </xd:doc>
    <xsl:function name="nf:get-practitioner-role-display" as="xs:string?">
        <xsl:param name="healthProfessional" as="element()?"/>
        <xsl:for-each select="$healthProfessional">
            <xsl:variable name="personIdentifier" select="nf:ada-zvl-id(.//zorgverlener_identificatie_nummer[1] | .//health_professional_identification_number[1])/@value"/>
            <xsl:variable name="personName" select=".//naamgegevens[1]//*[not(name() = 'naamgebruik')]/@value | .//name_information[1]//*[not(name() = 'name_usage')]/@value"/>
            <xsl:variable name="organizationName" select=".//organisatie_naam[1]/@value | .//organization_name[1]/@value"/>
            <xsl:variable name="specialty" select=".//specialisme/@displayName | .//specialty/@displayName"/>
            <xsl:variable name="role" select=".//zorgverleners_rol/(@displayName, @code)[1] | .//health_professional_role/(@displayName, @code)[1]"/>

            <xsl:choose>
                <xsl:when test="$personName | $specialty | $organizationName">
                    <xsl:value-of select="normalize-space(string-join((string-join($personName, ' ')[not(. = '')], $specialty, $organizationName), ' || '))"/>
                </xsl:when>
                <xsl:when test="$role">
                    <xsl:value-of select="normalize-space($role)"/>
                </xsl:when>
                <xsl:when test="$personIdentifier">
                    <xsl:value-of select="normalize-space($personIdentifier)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="healthcareProviderIdentification">ADA element containing the healthcare provider organization identification</xd:param>
    </xd:doc>
    <xsl:function name="nf:ada-za-id" as="element()?">
        <xsl:param name="healthcareProviderIdentification" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$healthcareProviderIdentification[@root = $oidURAOrganizations]">
                <xsl:copy-of select="$healthcareProviderIdentification[@root = $oidURAOrganizations][1]"/>
            </xsl:when>
            <xsl:when test="$healthcareProviderIdentification[@root = $oidAGB]">
                <xsl:copy-of select="$healthcareProviderIdentification[@root = $oidAGB][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$healthcareProviderIdentification[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="healthProfessionalIdentification">ADA element containing the health professional identification</xd:param>
    </xd:doc>
    <xsl:function name="nf:ada-zvl-id" as="element()?">
        <xsl:param name="healthProfessionalIdentification" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$healthProfessionalIdentification[@root = $oidUZIPersons]">
                <xsl:copy-of select="$healthProfessionalIdentification[@root = $oidUZIPersons][1]"/>
            </xsl:when>
            <xsl:when test="$healthProfessionalIdentification[@root = $oidAGB]">
                <xsl:copy-of select="$healthProfessionalIdentification[@root = $oidAGB][1]"/>
            </xsl:when>
            <xsl:when test="$healthProfessionalIdentification[@root = $oidBIGregister]">
                <xsl:copy-of select="$healthProfessionalIdentification[@root = $oidBIGregister][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$healthProfessionalIdentification[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="patientIdentification">ADA element containing the patient identification</xd:param>
    </xd:doc>
    <xsl:function name="nf:ada-pat-id" as="element()?">
        <xsl:param name="patientIdentification" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$patientIdentification[@root = $oidBurgerservicenummer]">
                <xsl:copy-of select="$patientIdentification[@root = $oidBurgerservicenummer][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$patientIdentification[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>Resolves the reference in an ada-transaction. Outputs a sequence with the resolved element.</xd:desc>
        <xd:param name="adaElement">The ada element which may need resolving, if not return the element, else the resolved element</xd:param>
    </xd:doc>
    <xsl:function name="nf:ada-resolve-reference" as="element()*">
        <xsl:param name="adaElement" as="element()"/>
        <!-- The current ada-transaction element -->
        <xsl:variable name="currentAdaTransaction" select="$adaElement/ancestor::*[ancestor::data[ancestor::adaxml]]"/>
        <!-- resolve the reference -->
        <xsl:choose>
            <xsl:when test="$adaElement[not(@datatype = 'reference')]">
                <xsl:sequence select="$adaElement"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$currentAdaTransaction//*[@id = $adaElement/@value]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc> copy an element with all of it's contents in comments </xd:desc>
        <xd:param name="element"/>
    </xd:doc>
    <xsl:template name="copyElementInComment">
        <xsl:param name="element"/>
        <xsl:text disable-output-escaping="yes">
                       &lt;!--</xsl:text>
        <xsl:for-each select="$element">
            <xsl:call-template name="copyWithoutComments"/>
        </xsl:for-each>
        <xsl:text disable-output-escaping="yes">--&gt;
</xsl:text>
    </xsl:template>

    <xd:doc>
        <xd:desc> copy without comments </xd:desc>
    </xd:doc>
    <xsl:template name="copyWithoutComments">
        <xsl:copy>
            <xsl:for-each select="@* | *">
                <xsl:call-template name="copyWithoutComments"/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

<xd:doc>
        <xd:desc>Default copy template for outputting the results </xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()" mode="ResultOutput">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="ResultOutput"/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>
