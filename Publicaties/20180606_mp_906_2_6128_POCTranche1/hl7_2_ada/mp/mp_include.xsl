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
<xsl:stylesheet xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:nf="http://www.nictiz.nl/functions" xmlns:pharm="urn:ihe:pharm:medication" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
   <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>
   <xsl:include href="../hl7/hl7_include.xsl"/>
   <xsl:include href="../zib1bbr/zib1bbr_include.xsl"/>
   <xsl:include href="../naw/naw_include.xsl"/>
   <xsl:variable name="ada-unit-seconde" select="('seconde', 's', 'sec', 'second')"/>
   <xsl:variable name="ada-unit-minute" select="('minuut', 'min', 'minute')"/>
   <xsl:variable name="ada-unit-hour" select="('uur', 'h', 'hour')"/>
   <xsl:variable name="ada-unit-day" select="('dag', 'd', 'day')"/>
   <xsl:variable name="ada-unit-week" select="('week', 'wk')"/>
   <xsl:variable name="ada-unit-month" select="('maand', 'mo', 'month')"/>
   <xsl:variable name="ada-unit-year" select="('jaar', 'a', 'year')"/>

   <xsl:template name="mp9-code-attribs">
      <xsl:param name="current-hl7-code" select="."/>

      <xsl:choose>
         <xsl:when test="$current-hl7-code[@code]">
            <xsl:attribute name="code" select="./@code"/>
            <xsl:attribute name="codeSystem" select="./@codeSystem"/>
            <xsl:attribute name="displayName" select="./@displayName"/>
            <xsl:if test="./@codeSystemName">
               <xsl:attribute name="codeSystemName" select="./@codeSystemName"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="$current-hl7-code[@nullFlavor]">
            <xsl:attribute name="code" select="./@nullFlavor"/>
            <xsl:attribute name="codeSystem" select="'2.16.840.1.113883.5.1008'"/>
            <xsl:attribute name="displayName" select="
                  if (./@nullFlavor = 'OTH') then
                     'overig'
                  else
                     if (./@nullFlavor = 'UNK') then
                        'onbekend'
                     else
                        if (./@nullFlavor = 'NI') then
                           'geen informatie'
                        else
                           'unsupported_nullFlavor'"/>
            <xsl:for-each select="./hl7:originalText">
               <xsl:attribute name="originalText" select="./text()"/>
            </xsl:for-each>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="mp9-dagdeel">
      <xsl:param name="PIVL_TS-HD"/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-toedieningsschema"/>
      <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'dagdeel']/@type"/>
      <!-- Nacht -->
      <xsl:for-each select="$PIVL_TS-HD[hl7nl:phase/hl7nl:low/@value = '1970010100']">
         <dagdeel code="2546009" displayName="'s nachts" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
      </xsl:for-each>
      <!-- Ochtend -->
      <xsl:for-each select="$PIVL_TS-HD[hl7nl:phase/hl7nl:low/@value = '1970010106']">
         <dagdeel code="73775008" displayName="'s ochtends" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
      </xsl:for-each>
      <!-- Middag -->
      <xsl:for-each select="$PIVL_TS-HD[hl7nl:phase/hl7nl:low/@value = '1970010112']">
         <dagdeel code="255213009" displayName="'s middags" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
      </xsl:for-each>
      <!-- Avond -->
      <xsl:for-each select="$PIVL_TS-HD[hl7nl:phase/hl7nl:low/@value = '1970010118']">
         <dagdeel code="3157002" displayName="'s avonds" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="mp9-gebruiksinstructie-from-mp612">
      <xsl:param name="hl7-comp" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-comp"/>
      <xsl:variable name="xsd-gebruiksinstructie-complexType" select="$xsd-comp//xs:element[@name = 'gebruiksinstructie']/@type"/>
      <xsl:variable name="xsd-gebruiksinstructie" select="$xsd-ada//xs:complexType[@name = $xsd-gebruiksinstructie-complexType]"/>
      <xsl:for-each select="$hl7-comp">
         <!-- mar = hl7:medicationAdministrationRequest -->
         <xsl:variable name="mar" select="./hl7:product/hl7:dispensedMedication/hl7:therapeuticAgentOf/hl7:medicationAdministrationRequest"/>
         <gebruiksinstructie conceptId="{$xsd-gebruiksinstructie/xs:attribute[@name='conceptId']/@fixed}">
            <!-- omschrijving -->
            <!-- TODO: dit is nog niet goed, hier moeten we nog iets slims doen met ontdubbelen en concateneren -->
            <xsl:for-each select="$mar/hl7:text">
               <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'omschrijving']/@type"/>
               <omschrijving value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
            </xsl:for-each>
            <!-- toedieningsweg -->
            <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'toedieningsweg']/@type"/>
            <toedieningsweg conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
               <xsl:choose>
                  <xsl:when test="$mar/hl7:routeCode">
                     <xsl:call-template name="mp9-code-attribs">
                        <!-- moeten allemaal dezelfde toedieningsweg hebben voor 1 verstrekking, we nemen de eerste -->
                        <xsl:with-param name="current-hl7-code" select="($mar/hl7:routeCode)[1]"/>
                     </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                     <!-- Niet aanwezig in 6.12 -->
                     <xsl:attribute name="code" select="'NI'"/>
                     <xsl:attribute name="codeSystem" select="'2.16.840.1.113883.5.1008'"/>
                     <xsl:attribute name="displayName" select="'geen informatie'"/>
                  </xsl:otherwise>
               </xsl:choose>
            </toedieningsweg>
            <!-- aanvullende_instructie -->
            <xsl:for-each select="./hl7:support2/hl7:medicationAdministrationInstruction/hl7:code">
               <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'aanvullende_instructie']/@type"/>
               <aanvullende_instructie conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </aanvullende_instructie>
            </xsl:for-each>
            <!-- TODO invullen voor 6.12!!!! onderstaand is een kopie van de mp9 versie. -->
            <xsl:variable name="hl7-doseerinstructie" select="$mar"/>
            <!-- herhaalperiode_cyclisch_schema -->
            <!-- er mag er maar eentje zijn -->
            <xsl:for-each select="$hl7-doseerinstructie/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]/hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:phase[hl7:width]]/hl7:period">
               <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'herhaalperiode_cyclisch_schema']/@type"/>
               <herhaalperiode_cyclisch_schema value="{./@value}" unit="{./@unit}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
            </xsl:for-each>
            <!-- doseerinstructie -->
            <xsl:for-each select="$hl7-doseerinstructie">
               <xsl:variable name="xsd-doseerinstructie-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'doseerinstructie']/@type"/>
               <xsl:variable name="xsd-doseerinstructie" select="$xsd-ada//xs:complexType[@name = $xsd-doseerinstructie-complexType]"/>
               <doseerinstructie conceptId="{$xsd-doseerinstructie/xs:attribute[@name='conceptId']/@fixed}">
                  <!-- volgnummer -->
                  <!-- tel het aantal therapeuticAgentOf's met een IVL_TS/low die lager is dan de huidige IVL_TS low en tel daar 1 bij op. -->
                  <!-- als de huidige therapeuticAgentOf géén IVL_TS/low heeft, dan begint -ie zo vroeg mogelijk en is het sequenceNumber 1 -->
                  <xsl:variable name="volgnummer">
                     <xsl:choose>
                        <xsl:when test="not(.//*[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'IVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]/hl7:low)">1</xsl:when>
                        <xsl:otherwise>
                           <!-- count the amount of therapeuticAgentOf's earlier then this one -->
                           <xsl:variable name="all-MARs" select="./../../hl7:therapeuticAgentOf/hl7:medicationAdministrationRequest"/>
                           <xsl:variable name="all_IVL-TS-low" select="$all-MARs//*[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'IVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]/hl7:low"/>
                           <xsl:variable name="current-IVL-TS-low" select=".//*[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'IVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]/hl7:low"/>
                           <xsl:value-of select="count($all_IVL-TS-low[@value &lt; $current-IVL-TS-low/@value]) + 1"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name="xsd-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'volgnummer']/@type"/>
                  <volgnummer value="{$volgnummer}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"> </volgnummer>
                  <!-- doseerduur -->
                  <xsl:choose>
                     <!-- doseerduur in Cyclisch doseerschema. -->
                     <xsl:when test="./hl7:substanceAdministration/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and not(@alignment)][hl7nl:period][hl7nl:phase[hl7nl:width]]]/hl7:comp/hl7nl:phase/hl7nl:width">
                        <xsl:for-each select="./hl7:substanceAdministration/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and not(@alignment)][hl7nl:period][hl7nl:phase[hl7nl:width]]]/hl7:comp/hl7nl:phase/hl7nl:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'doseerduur']/@type"/>
                           <doseerduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                        </xsl:for-each>
                     </xsl:when>
                     <!-- overige gevallen -->
                     <xsl:otherwise>
                        <xsl:for-each select="./hl7:substanceAdministration/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'IVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]/hl7:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'doseerduur']/@type"/>
                           <doseerduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                        </xsl:for-each>
                     </xsl:otherwise>
                  </xsl:choose>
                  <!-- dosering -->
                  <xsl:for-each select="./hl7:substanceAdministration">
                     <xsl:variable name="xsd-dosering-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'dosering']/@type"/>
                     <xsl:variable name="xsd-dosering" select="$xsd-ada//xs:complexType[@name = $xsd-dosering-complexType]"/>
                     <dosering conceptId="{$xsd-dosering/xs:attribute[@name='conceptId']/@fixed}">
                        <!-- keerdosis -->
                        <xsl:for-each select="./hl7:doseQuantity">
                           <xsl:variable name="xsd-keerdosis-complexType" select="$xsd-dosering//xs:element[@name = 'keerdosis']/@type"/>
                           <xsl:variable name="xsd-keerdosis" select="$xsd-ada//xs:complexType[@name = $xsd-keerdosis-complexType]"/>
                           <keerdosis conceptId="{$xsd-keerdosis/xs:attribute[@name='conceptId']/@fixed}">
                              <xsl:variable name="xsd-aantal-complexType" select="$xsd-keerdosis//xs:element[@name = 'aantal']/@type"/>
                              <xsl:variable name="xsd-aantal" select="$xsd-ada//xs:complexType[@name = $xsd-aantal-complexType]"/>
                              <aantal conceptId="{$xsd-aantal/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:for-each select="./hl7:low/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
                                    <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'min']/@type"/>
                                    <min value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:center/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
                                    <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'vaste_waarde']/@type"/>
                                    <vaste_waarde value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:high/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
                                    <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'max']/@type"/>
                                    <max value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                              </aantal>
                              <xsl:for-each select="(./*/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2'])[1]">
                                 <xsl:variable name="xsd-complexType" select="$xsd-keerdosis//xs:element[@name = 'eenheid']/@type"/>
                                 <eenheid conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                                    <xsl:call-template name="mp9-code-attribs">
                                       <xsl:with-param name="current-hl7-code" select="."/>
                                    </xsl:call-template>
                                 </eenheid>
                              </xsl:for-each>
                           </keerdosis>
                        </xsl:for-each>
                        <!-- toedieningsschema -->
                        <!-- er moet een PIVL_TS zijn om een toedieningsschema te maken -->
                        <xsl:if test=".//*[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')]">
                           <xsl:variable name="xsd-toedieningsschema-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningsschema']/@type"/>
                           <xsl:variable name="xsd-toedieningsschema" select="$xsd-ada//xs:complexType[@name = $xsd-toedieningsschema-complexType]"/>
                           <toedieningsschema conceptId="{$xsd-toedieningsschema/xs:attribute[@name='conceptId']/@fixed}">
                              <!-- eenvoudig doseerschema met alleen één frequentie -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][@isFlexible = 'true'][not(@alignment)][hl7nl:frequency][not(hl7nl:phase)]">
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Eenvoudig doseerschema met alleen één interval.-->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][(@isFlexible = 'false' or not(@isFlexible))][not(@alignment)][hl7nl:frequency]">
                                 <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'interval']/@type"/>
                                 <xsl:variable name="interval-value" select="format-number(number(./hl7nl:frequency/hl7nl:denominator/@value) div number(./hl7nl:frequency/hl7nl:numerator/@value), '0.####')"/>
                                 <interval value="{$interval-value}" unit="{nf:convertTime_UCUM2ADA_unit(./hl7nl:frequency/hl7nl:denominator/@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                              </xsl:for-each>
                              <!-- Eenvoudig doseerschema met één vast tijdstip. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][hl7nl:phase[not(hl7nl:width)]]">
                                 <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'toedientijd']/@type"/>
                                 <toedientijd value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./hl7nl:phase/hl7nl:low/@value), nf:determine_date_precision(./hl7nl:phase/hl7nl:low/@value))}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                              </xsl:for-each>
                              <!-- Doseerschema met toedieningsduur. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][not(hl7nl:period)][hl7nl:phase[hl7nl:width]]">
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                                 <xsl:for-each select="hl7nl:phase/hl7nl:low">
                                    <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'toedientijd']/@type"/>
                                    <toedientijd value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./@value), nf:determine_date_precision(./@value))}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                              </xsl:for-each>
                              <!--Doseerschema met meer dan één vast tijdstip.-->
                              <xsl:for-each select="./hl7:effectiveTime[hl7:comp[not(@alignment)][hl7nl:period][hl7nl:phase[not(hl7nl:width)]]][not(hl7:comp/@alignment)][not(hl7:comp[not(hl7nl:period)])][not(hl7:comp[not(hl7nl:phase[not(hl7nl:width)])])]/hl7:comp">
                                 <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'toedientijd']/@type"/>
                                 <toedientijd value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./hl7nl:phase/hl7nl:low/@value), nf:determine_date_precision(./hl7nl:phase/hl7nl:low/@value))}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                              </xsl:for-each>
                              <!-- Cyclisch doseerschema. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and not(@alignment)][hl7nl:period][hl7nl:phase[hl7nl:width]]]/hl7:comp[hl7nl:frequency]">
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Eenmalig gebruik of aantal keren gebruik zonder tijd. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][hl7nl:count]/hl7nl:count">
                                 <xsl:variable name="xsd-frequentie-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'frequentie']/@type"/>
                                 <xsl:variable name="xsd-frequentie" select="$xsd-ada//xs:complexType[@name = $xsd-frequentie-complexType]"/>
                                 <frequentie conceptId="{$xsd-frequentie/xs:attribute[@name='conceptId']/@fixed}">
                                    <xsl:variable name="xsd-aantal-complexType" select="$xsd-frequentie//xs:element[@name = 'aantal']/@type"/>
                                    <xsl:variable name="xsd-aantal" select="$xsd-ada//xs:complexType[@name = $xsd-aantal-complexType]"/>
                                    <aantal conceptId="{$xsd-aantal/xs:attribute[@name='conceptId']/@fixed}">
                                       <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'vaste_waarde']/@type"/>
                                       <vaste_waarde value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                    </aantal>
                                 </frequentie>
                              </xsl:for-each>
                              <!-- Doseerschema één keer per week op één weekdag. -->
                              <xsl:for-each select="./hl7:effectiveTime[@alignment = 'DW']">
                                 <xsl:for-each select="./hl7nl:period">
                                    <xsl:variable name="xsd-frequentie-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'frequentie']/@type"/>
                                    <xsl:variable name="xsd-frequentie" select="$xsd-ada//xs:complexType[@name = $xsd-frequentie-complexType]"/>
                                    <frequentie conceptId="{$xsd-frequentie/xs:attribute[@name='conceptId']/@fixed}">
                                       <xsl:variable name="xsd-aantal-complexType" select="$xsd-frequentie//xs:element[@name = 'aantal']/@type"/>
                                       <xsl:variable name="xsd-aantal" select="$xsd-ada//xs:complexType[@name = $xsd-aantal-complexType]"/>
                                       <aantal conceptId="{$xsd-aantal/xs:attribute[@name='conceptId']/@fixed}">
                                          <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'vaste_waarde']/@type"/>
                                          <!-- altijd 1, 1 keer per week of 1 keer per 2 weken et cetera -->
                                          <vaste_waarde value="1" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                       </aantal>
                                       <xsl:variable name="xsd-complexType" select="$xsd-frequentie//xs:element[@name = 'tijdseenheid']/@type"/>
                                       <tijdseenheid value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                    </frequentie>
                                 </xsl:for-each>
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9155_20160727135123_only_phase_low">
                                    <xsl:with-param name="current_IVL" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Complexer doseerschema met weekdag(en). -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp/@alignment = 'DW']">
                                 <xsl:for-each select="./hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and @isFlexible = 'true' and hl7nl:frequency]">
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                       <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                       <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                    </xsl:call-template>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:comp[@alignment = 'DW']">
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9155_20160727135123_only_phase_low">
                                       <xsl:with-param name="current_IVL" select="."/>
                                       <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                       <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                    </xsl:call-template>
                                 </xsl:for-each>
                              </xsl:for-each>
                              <!-- Doseerschema met één dagdeel -->
                              <xsl:for-each select="./hl7:effectiveTime[@alignment = 'HD']">
                                 <xsl:call-template name="mp9-dagdeel">
                                    <xsl:with-param name="PIVL_TS-HD" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Complexer doseerschema met meer dan één dagdeel. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp/@alignment = 'HD']/hl7:comp">
                                 <xsl:call-template name="mp9-weekdag">
                                    <xsl:with-param name="hl7-phase-low" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                           </toedieningsschema>
                        </xsl:if>
                        <xsl:for-each select="./hl7:precondition/hl7:criterion/hl7:code">
                           <xsl:variable name="xsd-zo_nodig-complexType" select="$xsd-dosering//xs:element[@name = 'zo_nodig']/@type"/>
                           <xsl:variable name="xsd-zo_nodig" select="$xsd-ada//xs:complexType[@name = $xsd-zo_nodig-complexType]"/>
                           <zo_nodig conceptId="{$xsd-zo_nodig/xs:attribute[@name='conceptId']/@fixed}">
                              <xsl:variable name="xsd-criterium-complexType" select="$xsd-zo_nodig//xs:element[@name = 'criterium']/@type"/>
                              <xsl:variable name="xsd-criterium" select="$xsd-ada//xs:complexType[@name = $xsd-criterium-complexType]"/>
                              <criterium conceptId="{$xsd-criterium/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:variable name="xsd-complexType" select="$xsd-criterium//xs:element[@name = 'code']/@type"/>
                                 <code conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                                    <xsl:call-template name="mp9-code-attribs">
                                       <xsl:with-param name="current-hl7-code" select="."/>
                                    </xsl:call-template>
                                 </code>
                                 <!-- no use case for omschrijving, omschrijving is in code/@originalText -->
                                 <!--  <omschrijving value="zo nodig criterium omschrijving in vrije tekst" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23270"/>-->
                              </criterium>
                           </zo_nodig>
                        </xsl:for-each>
                        <xsl:for-each select="./hl7:rateQuantity">
                           <xsl:variable name="xsd-toedieningssnelheid-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningssnelheid']/@type"/>
                           <xsl:variable name="xsd-toedieningssnelheid" select="$xsd-ada//xs:complexType[@name = $xsd-toedieningssnelheid-complexType]"/>
                           <toedieningssnelheid conceptId="{$xsd-toedieningssnelheid/xs:attribute[@name='conceptId']/@fixed}">
                              <xsl:variable name="xsd-waarde-complexType" select="$xsd-toedieningssnelheid//xs:element[@name = 'waarde']/@type"/>
                              <xsl:variable name="xsd-waarde" select="$xsd-ada//xs:complexType[@name = $xsd-waarde-complexType]"/>
                              <waarde conceptId="{$xsd-waarde/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:for-each select="./hl7:low">
                                    <xsl:variable name="xsd-complexType" select="$xsd-waarde//xs:element[@name = 'min']/@type"/>
                                    <min value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:center">
                                    <xsl:variable name="xsd-complexType" select="$xsd-waarde//xs:element[@name = 'vaste_waarde']/@type"/>
                                    <vaste_waarde value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:high">
                                    <xsl:variable name="xsd-complexType" select="$xsd-waarde//xs:element[@name = 'max']/@type"/>
                                    <max value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                              </waarde>
                              <xsl:variable name="ucum-eenheid" select="substring-before((./*/@unit)[1], '/')"/>
                              <xsl:variable name="xsd-complexType" select="$xsd-toedieningssnelheid//xs:element[@name = 'eenheid']/@type"/>
                              <eenheid conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:call-template name="UCUM2GstdBasiseenheid">
                                    <xsl:with-param name="UCUM" select="$ucum-eenheid"/>
                                 </xsl:call-template>
                              </eenheid>
                              <xsl:variable name="ucum-tijdseenheid" select="substring-after((./*/@unit)[1], '/')"/>
                              <xsl:variable name="xsd-complexType" select="$xsd-toedieningssnelheid//xs:element[@name = 'tijdseenheid']/@type"/>
                              <tijdseenheid unit="{nf:convertTime_UCUM2ADA_unit($ucum-tijdseenheid)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                           </toedieningssnelheid>
                        </xsl:for-each>
                        <!-- Doseerschema met toedieningsduur. -->
                        <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][not(hl7nl:period)]/hl7nl:phase/hl7nl:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningsduur']/@type"/>
                           <toedieningsduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23282"/>
                        </xsl:for-each>
                        <!-- Doseerschema één keer per week op één weekdag met toedieningsduur -->
                        <xsl:for-each select="./hl7:effectiveTime[@alignment = 'DW']/hl7nl:phase/hl7nl:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningsduur']/@type"/>
                           <toedieningsduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23282"/>

                        </xsl:for-each>
                     </dosering>
                  </xsl:for-each>
               </doseerinstructie>
            </xsl:for-each>
         </gebruiksinstructie>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="mp9-gebruiksinstructie-from-mp9">
      <xsl:param name="hl7-comp" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-comp"/>
      <xsl:variable name="xsd-gebruiksinstructie-complexType" select="$xsd-comp//xs:element[@name = 'gebruiksinstructie']/@type"/>
      <xsl:variable name="xsd-gebruiksinstructie" select="$xsd-ada//xs:complexType[@name = $xsd-gebruiksinstructie-complexType]"/>
      <xsl:for-each select="$hl7-comp">
         <gebruiksinstructie conceptId="{$xsd-gebruiksinstructie/xs:attribute[@name='conceptId']/@fixed}">
            <!-- omschrijving -->
            <xsl:for-each select="./hl7:text">
               <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'omschrijving']/@type"/>
               <omschrijving value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
            </xsl:for-each>
            <!-- toedieningsweg -->
            <xsl:for-each select="./hl7:routeCode">
               <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'toedieningsweg']/@type"/>
               <toedieningsweg conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </toedieningsweg>
            </xsl:for-each>
            <!-- aanvullende_instructie -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9085']/hl7:code">
               <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'aanvullende_instructie']/@type"/>
               <aanvullende_instructie conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </aanvullende_instructie>
            </xsl:for-each>
            <xsl:variable name="hl7-doseerinstructie" select="./hl7:entryRelationship[hl7:substanceAdministration/hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9149']"/>
            <!-- herhaalperiode_cyclisch_schema -->
            <!-- er mag er maar eentje zijn -->
            <xsl:for-each select="$hl7-doseerinstructie/hl7:substanceAdministration/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]/hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and not(@alignment)][hl7nl:phase[hl7nl:width]]/hl7nl:period">
               <xsl:variable name="xsd-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'herhaalperiode_cyclisch_schema']/@type"/>
               <herhaalperiode_cyclisch_schema value="{./@value}" unit="{./@unit}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
            </xsl:for-each>
            <!-- doseerinstructie -->
            <xsl:for-each select="$hl7-doseerinstructie">
               <xsl:variable name="xsd-doseerinstructie-complexType" select="$xsd-gebruiksinstructie//xs:element[@name = 'doseerinstructie']/@type"/>
               <xsl:variable name="xsd-doseerinstructie" select="$xsd-ada//xs:complexType[@name = $xsd-doseerinstructie-complexType]"/>
               <doseerinstructie conceptId="{$xsd-doseerinstructie/xs:attribute[@name='conceptId']/@fixed}">
                  <!-- volgnummer -->
                  <xsl:for-each select="./hl7:sequenceNumber">
                     <xsl:variable name="xsd-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'volgnummer']/@type"/>
                     <volgnummer value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                  </xsl:for-each>
                  <!-- doseerduur -->
                  <xsl:choose>
                     <!-- doseerduur in Cyclisch doseerschema. -->
                     <xsl:when test="./hl7:substanceAdministration/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and not(@alignment)][hl7nl:period][hl7nl:phase[hl7nl:width]]]/hl7:comp/hl7nl:phase/hl7nl:width">
                        <xsl:for-each select="./hl7:substanceAdministration/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and not(@alignment)][hl7nl:period][hl7nl:phase[hl7nl:width]]]/hl7:comp/hl7nl:phase/hl7nl:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'doseerduur']/@type"/>
                           <doseerduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                        </xsl:for-each>
                     </xsl:when>
                     <!-- overige gevallen -->
                     <xsl:otherwise>
                        <xsl:for-each select="./hl7:substanceAdministration/hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'IVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]/hl7:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'doseerduur']/@type"/>
                           <doseerduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                        </xsl:for-each>
                     </xsl:otherwise>
                  </xsl:choose>
                  <!-- dosering -->
                  <xsl:for-each select="./hl7:substanceAdministration">
                     <xsl:variable name="xsd-dosering-complexType" select="$xsd-doseerinstructie//xs:element[@name = 'dosering']/@type"/>
                     <xsl:variable name="xsd-dosering" select="$xsd-ada//xs:complexType[@name = $xsd-dosering-complexType]"/>
                     <dosering conceptId="{$xsd-dosering/xs:attribute[@name='conceptId']/@fixed}">
                        <!-- keerdosis -->
                        <xsl:for-each select="./hl7:doseQuantity">
                           <xsl:variable name="xsd-keerdosis-complexType" select="$xsd-dosering//xs:element[@name = 'keerdosis']/@type"/>
                           <xsl:variable name="xsd-keerdosis" select="$xsd-ada//xs:complexType[@name = $xsd-keerdosis-complexType]"/>
                           <keerdosis conceptId="{$xsd-keerdosis/xs:attribute[@name='conceptId']/@fixed}">
                              <xsl:variable name="xsd-aantal-complexType" select="$xsd-keerdosis//xs:element[@name = 'aantal']/@type"/>
                              <xsl:variable name="xsd-aantal" select="$xsd-ada//xs:complexType[@name = $xsd-aantal-complexType]"/>
                              <aantal conceptId="{$xsd-aantal/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:for-each select="./hl7:low/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
                                    <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'min']/@type"/>
                                    <min value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:center/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
                                    <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'vaste_waarde']/@type"/>
                                    <vaste_waarde value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:high/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
                                    <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'max']/@type"/>
                                    <max value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                              </aantal>
                              <xsl:for-each select="(./*/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2'])[1]">
                                 <xsl:variable name="xsd-complexType" select="$xsd-keerdosis//xs:element[@name = 'eenheid']/@type"/>
                                 <eenheid conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                                    <xsl:call-template name="mp9-code-attribs">
                                       <xsl:with-param name="current-hl7-code" select="."/>
                                    </xsl:call-template>
                                 </eenheid>
                              </xsl:for-each>
                           </keerdosis>
                        </xsl:for-each>
                        <!-- toedieningsschema -->
                        <!-- er moet een PIVL_TS zijn om een toedieningsschema te maken -->
                        <xsl:if test=".//*[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')]">
                           <xsl:variable name="xsd-toedieningsschema-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningsschema']/@type"/>
                           <xsl:variable name="xsd-toedieningsschema" select="$xsd-ada//xs:complexType[@name = $xsd-toedieningsschema-complexType]"/>
                           <toedieningsschema conceptId="{$xsd-toedieningsschema/xs:attribute[@name='conceptId']/@fixed}">
                              <!-- eenvoudig doseerschema met alleen één frequentie -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][@isFlexible = 'true'][not(@alignment)][hl7nl:frequency][not(hl7nl:phase)]">
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Eenvoudig doseerschema met alleen één interval.-->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][(@isFlexible = 'false' or not(@isFlexible))][not(@alignment)][hl7nl:frequency]">
                                 <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'interval']/@type"/>
                                 <xsl:variable name="interval-value" select="format-number(number(./hl7nl:frequency/hl7nl:denominator/@value) div number(./hl7nl:frequency/hl7nl:numerator/@value), '0.####')"/>
                                 <interval value="{$interval-value}" unit="{nf:convertTime_UCUM2ADA_unit(./hl7nl:frequency/hl7nl:denominator/@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                              </xsl:for-each>
                              <!-- Eenvoudig doseerschema met één vast tijdstip. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][hl7nl:phase[not(hl7nl:width)]]">
                                 <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'toedientijd']/@type"/>
                                 <toedientijd value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./hl7nl:phase/hl7nl:low/@value), nf:determine_date_precision(./hl7nl:phase/hl7nl:low/@value))}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                              </xsl:for-each>
                              <!-- Doseerschema met toedieningsduur. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][not(hl7nl:period)][hl7nl:phase[hl7nl:width]]">
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                                 <xsl:for-each select="hl7nl:phase/hl7nl:low">
                                    <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'toedientijd']/@type"/>
                                    <toedientijd value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./@value), nf:determine_date_precision(./@value))}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                              </xsl:for-each>
                              <!--Doseerschema met meer dan één vast tijdstip.-->
                              <xsl:for-each select="./hl7:effectiveTime[hl7:comp[not(@alignment)][hl7nl:period][hl7nl:phase[not(hl7nl:width)]]][not(hl7:comp/@alignment)][not(hl7:comp[not(hl7nl:period)])][not(hl7:comp[not(hl7nl:phase[not(hl7nl:width)])])]/hl7:comp">
                                 <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'toedientijd']/@type"/>
                                 <toedientijd value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./hl7nl:phase/hl7nl:low/@value), nf:determine_date_precision(./hl7nl:phase/hl7nl:low/@value))}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                              </xsl:for-each>
                              <!-- Cyclisch doseerschema. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and not(@alignment)][hl7nl:period][hl7nl:phase[hl7nl:width]]]/hl7:comp[hl7nl:frequency]">
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Eenmalig gebruik of aantal keren gebruik zonder tijd. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][hl7nl:count]/hl7nl:count">
                                 <xsl:variable name="xsd-frequentie-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'frequentie']/@type"/>
                                 <xsl:variable name="xsd-frequentie" select="$xsd-ada//xs:complexType[@name = $xsd-frequentie-complexType]"/>
                                 <frequentie conceptId="{$xsd-frequentie/xs:attribute[@name='conceptId']/@fixed}">
                                    <xsl:variable name="xsd-aantal-complexType" select="$xsd-frequentie//xs:element[@name = 'aantal']/@type"/>
                                    <xsl:variable name="xsd-aantal" select="$xsd-ada//xs:complexType[@name = $xsd-aantal-complexType]"/>
                                    <aantal conceptId="{$xsd-aantal/xs:attribute[@name='conceptId']/@fixed}">
                                       <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'vaste_waarde']/@type"/>
                                       <vaste_waarde value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                    </aantal>
                                 </frequentie>
                              </xsl:for-each>
                              <!-- Doseerschema één keer per week op één weekdag. -->
                              <xsl:for-each select="./hl7:effectiveTime[@alignment = 'DW']">
                                 <xsl:for-each select="./hl7nl:period">
                                    <xsl:variable name="xsd-frequentie-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'frequentie']/@type"/>
                                    <xsl:variable name="xsd-frequentie" select="$xsd-ada//xs:complexType[@name = $xsd-frequentie-complexType]"/>
                                    <frequentie conceptId="{$xsd-frequentie/xs:attribute[@name='conceptId']/@fixed}">
                                       <xsl:variable name="xsd-aantal-complexType" select="$xsd-frequentie//xs:element[@name = 'aantal']/@type"/>
                                       <xsl:variable name="xsd-aantal" select="$xsd-ada//xs:complexType[@name = $xsd-aantal-complexType]"/>
                                       <aantal conceptId="{$xsd-aantal/xs:attribute[@name='conceptId']/@fixed}">
                                          <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'vaste_waarde']/@type"/>
                                          <!-- altijd 1, 1 keer per week of 1 keer per 2 weken et cetera -->
                                          <vaste_waarde value="1" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                       </aantal>
                                       <xsl:variable name="xsd-complexType" select="$xsd-frequentie//xs:element[@name = 'tijdseenheid']/@type"/>
                                       <tijdseenheid value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                    </frequentie>
                                 </xsl:for-each>
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9155_20160727135123_only_phase_low">
                                    <xsl:with-param name="current_IVL" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Complexer doseerschema met weekdag(en). -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp/@alignment = 'DW']">
                                 <xsl:for-each select="./hl7:comp[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3') and @isFlexible = 'true' and hl7nl:frequency]">
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
                                       <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                       <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                    </xsl:call-template>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:comp[@alignment = 'DW']">
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9155_20160727135123_only_phase_low">
                                       <xsl:with-param name="current_IVL" select="."/>
                                       <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                       <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                    </xsl:call-template>
                                 </xsl:for-each>
                              </xsl:for-each>
                              <!-- Doseerschema met één dagdeel -->
                              <xsl:for-each select="./hl7:effectiveTime[@alignment = 'HD']">
                                 <xsl:call-template name="mp9-dagdeel">
                                    <xsl:with-param name="PIVL_TS-HD" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                              <!-- Complexer doseerschema met meer dan één dagdeel. -->
                              <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'SXPR_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')][hl7:comp/@alignment = 'HD']/hl7:comp">
                                 <xsl:call-template name="mp9-weekdag">
                                    <xsl:with-param name="hl7-phase-low" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
                                 </xsl:call-template>
                              </xsl:for-each>
                           </toedieningsschema>
                        </xsl:if>
                        <xsl:for-each select="./hl7:precondition/hl7:criterion/hl7:code">
                           <xsl:variable name="xsd-zo_nodig-complexType" select="$xsd-dosering//xs:element[@name = 'zo_nodig']/@type"/>
                           <xsl:variable name="xsd-zo_nodig" select="$xsd-ada//xs:complexType[@name = $xsd-zo_nodig-complexType]"/>
                           <zo_nodig conceptId="{$xsd-zo_nodig/xs:attribute[@name='conceptId']/@fixed}">
                              <xsl:variable name="xsd-criterium-complexType" select="$xsd-zo_nodig//xs:element[@name = 'criterium']/@type"/>
                              <xsl:variable name="xsd-criterium" select="$xsd-ada//xs:complexType[@name = $xsd-criterium-complexType]"/>
                              <criterium conceptId="{$xsd-criterium/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:variable name="xsd-complexType" select="$xsd-criterium//xs:element[@name = 'code']/@type"/>
                                 <code conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                                    <xsl:call-template name="mp9-code-attribs">
                                       <xsl:with-param name="current-hl7-code" select="."/>
                                    </xsl:call-template>
                                 </code>
                                 <!-- no use case for omschrijving, omschrijving is in code/@originalText -->
                                 <!--  <omschrijving value="zo nodig criterium omschrijving in vrije tekst" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23270"/>-->
                              </criterium>
                           </zo_nodig>
                        </xsl:for-each>
                        <xsl:for-each select="./hl7:rateQuantity">
                           <xsl:variable name="xsd-toedieningssnelheid-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningssnelheid']/@type"/>
                           <xsl:variable name="xsd-toedieningssnelheid" select="$xsd-ada//xs:complexType[@name = $xsd-toedieningssnelheid-complexType]"/>
                           <toedieningssnelheid conceptId="{$xsd-toedieningssnelheid/xs:attribute[@name='conceptId']/@fixed}">
                              <xsl:variable name="xsd-waarde-complexType" select="$xsd-toedieningssnelheid//xs:element[@name = 'waarde']/@type"/>
                              <xsl:variable name="xsd-waarde" select="$xsd-ada//xs:complexType[@name = $xsd-waarde-complexType]"/>
                              <waarde conceptId="{$xsd-waarde/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:for-each select="./hl7:low">
                                    <xsl:variable name="xsd-complexType" select="$xsd-waarde//xs:element[@name = 'min']/@type"/>
                                    <min value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:center">
                                    <xsl:variable name="xsd-complexType" select="$xsd-waarde//xs:element[@name = 'vaste_waarde']/@type"/>
                                    <vaste_waarde value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                                 <xsl:for-each select="./hl7:high">
                                    <xsl:variable name="xsd-complexType" select="$xsd-waarde//xs:element[@name = 'max']/@type"/>
                                    <max value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                                 </xsl:for-each>
                              </waarde>
                              <xsl:variable name="ucum-eenheid" select="substring-before((./*/@unit)[1], '/')"/>
                              <xsl:variable name="xsd-complexType" select="$xsd-toedieningssnelheid//xs:element[@name = 'eenheid']/@type"/>
                              <eenheid conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:call-template name="UCUM2GstdBasiseenheid">
                                    <xsl:with-param name="UCUM" select="$ucum-eenheid"/>
                                 </xsl:call-template>
                              </eenheid>
                              <xsl:variable name="ucum-tijdseenheid" select="substring-after((./*/@unit)[1], '/')"/>
                              <xsl:variable name="xsd-complexType" select="$xsd-toedieningssnelheid//xs:element[@name = 'tijdseenheid']/@type"/>
                              <tijdseenheid unit="{nf:convertTime_UCUM2ADA_unit($ucum-tijdseenheid)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                           </toedieningssnelheid>
                        </xsl:for-each>
                        <!-- Doseerschema met toedieningsduur. -->
                        <xsl:for-each select="./hl7:effectiveTime[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'PIVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-nl:v3')][not(@alignment)][not(hl7nl:period)]/hl7nl:phase/hl7nl:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningsduur']/@type"/>
                           <toedieningsduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23282"/>
                        </xsl:for-each>
                        <!-- Doseerschema één keer per week op één weekdag met toedieningsduur -->
                        <xsl:for-each select="./hl7:effectiveTime[@alignment = 'DW']/hl7nl:phase/hl7nl:width">
                           <xsl:variable name="xsd-complexType" select="$xsd-dosering//xs:element[@name = 'toedieningsduur']/@type"/>
                           <toedieningsduur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23282"/>

                        </xsl:for-each>
                     </dosering>
                  </xsl:for-each>
               </doseerinstructie>
            </xsl:for-each>
         </gebruiksinstructie>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="mp9-gebruiksperiode-eind">
      <xsl:param name="inputValue"/>
      <xsl:param name="xsd-comp"/>
      <xsl:param name="xsd-ada"/>
      <xsl:variable name="xsd-complexType" select="$xsd-comp//xs:element[@name = 'gebruiksperiode_eind']/@type"/>
      <gebruiksperiode_eind value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime($inputValue), nf:determine_date_precision($inputValue))}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
   </xsl:template>
   <xsl:template name="mp9-gebruiksperiode-start">
      <xsl:param name="inputValue"/>
      <xsl:param name="xsd-comp"/>
      <xsl:param name="xsd-ada"/>
      <xsl:variable name="xsd-complexType" select="$xsd-comp//xs:element[@name = 'gebruiksperiode_start']/@type"/>
      <gebruiksperiode_start value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime($inputValue), nf:determine_date_precision($inputValue))}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
   </xsl:template>
   <xsl:template name="mp9-geslacht">
      <xsl:param name="current-administrativeGenderCode" select="."/>
      <xsl:choose>
         <xsl:when test="$current-administrativeGenderCode/@code = 'F'">
            <geslacht value="3" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19831" code="F" codeSystem="2.16.840.1.113883.5.1" displayName="Vrouw"/>
         </xsl:when>
         <xsl:when test="$current-administrativeGenderCode/@code = 'M'">
            <geslacht value="2" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19831" code="M" codeSystem="2.16.840.1.113883.5.1" displayName="Man"/>
         </xsl:when>
         <xsl:when test="$current-administrativeGenderCode/@code = 'UN'">
            <geslacht value="1" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19831" code="UN" codeSystem="2.16.840.1.113883.5.1" displayName="Ongedifferentieerd"/>
         </xsl:when>
         <xsl:otherwise>
            <geslacht value="4" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19831" code="UNK" codeSystem="2.16.840.1.113883.5.1008" displayName="Onbekend"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="mp9-ingredient-eenheid">
      <xsl:param name="hl7-num-or-denom" select="."/>
      <xsl:choose>
         <xsl:when test="./hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
            <xsl:for-each select="./hl7:translation">
               <xsl:attribute name="code" select="./@code"/>
               <xsl:attribute name="codeSystem" select="./@codeSystem"/>
               <xsl:attribute name="displayName" select="./@displayName"/>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <!-- translate UCUM unit to Gstd -->
            <xsl:call-template name="UCUM2GstdBasiseenheid">
               <xsl:with-param name="UCUM" select="./@unit"/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="mp9-ingredient-waarde">
      <xsl:param name="hl7-num-or-denom" as="node()"/>
      <xsl:variable name="gstd-translation" select="$hl7-num-or-denom/hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']"/>
      <xsl:choose>
         <xsl:when test="$gstd-translation">
            <xsl:attribute name="value" select="$gstd-translation/@value"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:attribute name="value" select="./@value"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="mp-ingredient-waarde-en-eenheid">
      <xsl:param name="hl7-num-or-denom"/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-hoeveelheid"/>
      <xsl:variable name="xsd-complexType" select="$xsd-hoeveelheid//xs:element[@name = 'waarde']/@type"/>
      <waarde conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
         <xsl:call-template name="mp9-ingredient-waarde">
            <xsl:with-param name="hl7-num-or-denom" select="$hl7-num-or-denom"/>
         </xsl:call-template>
      </waarde>
      <xsl:variable name="xsd-complexType" select="$xsd-hoeveelheid//xs:element[@name = 'eenheid']/@type"/>
      <eenheid conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
         <xsl:call-template name="mp9-ingredient-eenheid">
            <xsl:with-param name="hl7-num-or-denom" select="$hl7-num-or-denom"/>
         </xsl:call-template>
      </eenheid>
   </xsl:template>
   <xsl:template name="mp9-naamgebruik">
      <xsl:param name="hl7-name"/>
      <xsl:choose>
         <xsl:when test="hl7:family[@qualifier = 'BR' or not(@qualifier)] and not(hl7:family[@qualifier = 'SP'])">
            <naamgebruik value="1" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19803" code="NL1" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Eigen geslachtsnaam"/>
         </xsl:when>
         <xsl:when test="hl7:family[@qualifier = 'SP'] and not(hl7:family[@qualifier = 'BR' or not(@qualifier)])">
            <naamgebruik value="2" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19803" code="NL2" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Geslachtsnaam partner"/>
         </xsl:when>
         <xsl:when test="hl7:family[@qualifier = 'SP'] and not(hl7:family[@qualifier = 'SP']/ancestor::hl7:family[@qualifier = 'BR' or not(@qualifier)])">
            <naamgebruik value="3" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19803" code="NL3" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Geslachtsnaam partner gevolgd door eigen geslachtsnaam"/>
         </xsl:when>
         <xsl:when test="hl7:family[@qualifier = 'BR' or not(@qualifier)] and not(hl7:family[@qualifier = 'BR' or not(@qualifier)]/ancestor::hl7:family[@qualifier = 'SP'])">
            <naamgebruik value="4" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19803" code="NL4" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Eigen geslachtsnaam gevolgd door geslachtsnaam partner"/>
         </xsl:when>
         <xsl:otherwise>
            <naamgebruik value="5" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19803" code="OTH" codeSystem="2.16.840.1.113883.5.1008" displayName="Onbekend"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="mp9-naamgegevens">
      <!-- naam binnen patiënt -->
      <xsl:param name="current-hl7-name" select="."/>
      <!-- See for the HL7 spec of name: http://www.hl7.nl/wiki/index.php/DatatypesR1:PN -->
      <naamgegevens conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19799">
         <!-- ongestructureerde_naam -->
         <xsl:for-each select="$current-hl7-name[text()][not(child::*)]">
            <ongestructureerde_naam conceptId="1.2.3.4.5.12345.19799.1">
               <xsl:attribute name="value">
                  <xsl:value-of select="."/>
               </xsl:attribute>
            </ongestructureerde_naam>
         </xsl:for-each>
         <!-- voornamen -->
         <xsl:for-each select="$current-hl7-name[hl7:given[contains(@qualifier, 'BR') or not(@qualifier)]]">
            <xsl:variable name="voornamen_concatted">
               <xsl:for-each select="./hl7:given[contains(@qualifier, 'BR') or not(@qualifier)]">
                  <xsl:value-of select="concat(./text(), ' ')"/>
               </xsl:for-each>
            </xsl:variable>
            <voornamen value="{normalize-space($voornamen_concatted)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19800"/>
         </xsl:for-each>
         <!-- initialen -->
         <xsl:for-each select="$current-hl7-name[hl7:given[contains(@qualifier, 'BR') or not(@qualifier) or @qualifier = 'IN']]">
            <!-- in HL7 mogen de initialen van officiële voornamen niet herhaald / gedupliceerd worden in het initialen veld -->
            <!-- in de zib moeten de initialen juist compleet zijn, dus de initialen hier toevoegen van de officiële voornamen -->
            <xsl:variable name="initialen_concatted">
               <xsl:for-each select="./hl7:given[contains(@qualifier, 'BR') or not(@qualifier)]">
                  <xsl:for-each select="tokenize(., ' ')">
                     <xsl:value-of select="concat(substring(., 1, 1), '.')"/>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="./hl7:given[@qualifier = 'IN']">
                  <xsl:value-of select="./text()"/>
               </xsl:for-each>
            </xsl:variable>
            <initialen conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19801" value="{$initialen_concatted}"/>
         </xsl:for-each>
         <xsl:for-each select="$current-hl7-name[hl7:given[contains(@qualifier, 'CL')]]">
            <xsl:variable name="roepnamen_concatted">
               <xsl:for-each select="./hl7:given[contains(@qualifier, 'CL')]">
                  <xsl:value-of select="concat(./text(), ' ')"/>
               </xsl:for-each>
            </xsl:variable>
            <roepnaam value="{normalize-space($roepnamen_concatted)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19802"/>
         </xsl:for-each>
         <xsl:call-template name="mp9-naamgebruik">
            <xsl:with-param name="hl7-name" select="$current-hl7-name"/>
         </xsl:call-template>
         <xsl:for-each select="$current-hl7-name/hl7:family[@qualifier = 'BR' or not(@qualifier)]">
            <geslachtsnaam conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19804">
               <xsl:for-each select="./preceding-sibling::hl7:prefix[@qualifier = 'VV'][position() = 1]">
                  <voorvoegsels conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19805">
                     <xsl:attribute name="value" select="./text()"/>
                  </voorvoegsels>
               </xsl:for-each>
               <achternaam value="Eigengeslachtsnaam" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19806">
                  <xsl:attribute name="value" select="./text()"/>
               </achternaam>
            </geslachtsnaam>
         </xsl:for-each>
         <xsl:for-each select="$current-hl7-name/hl7:family[@qualifier = 'SP']">
            <geslachtsnaam_partner conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19807">
               <xsl:for-each select="./preceding-sibling::hl7:prefix[@qualifier = 'VV'][position() = 1]">
                  <voorvoegsels_partner value="van " conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19808">
                     <xsl:attribute name="value" select="./text()"/>
                  </voorvoegsels_partner>
               </xsl:for-each>
               <achternaam_partner value="Partner" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19809">
                  <xsl:attribute name="value" select="./text()"/>
               </achternaam_partner>
            </geslachtsnaam_partner>
         </xsl:for-each>
      </naamgegevens>
   </xsl:template>
   <xsl:template name="mp9-toedieningsafspraak-from-mp612">
      <xsl:param name="current-dispense-event"/>
      <xsl:param name="IVL_TS"/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-mbh"/>
      <xsl:variable name="xsd-toedieningsafspraak-complexType" select="$xsd-mbh//xs:element[@name = 'toedieningsafspraak']/@type"/>
      <xsl:variable name="xsd-toedieningsafspraak" select="$xsd-ada//xs:complexType[@name = $xsd-toedieningsafspraak-complexType]"/>
      <!-- toedieningsafspraak -->
      <toedieningsafspraak conceptId="{$xsd-toedieningsafspraak/xs:attribute[@name='conceptId']/@fixed}">
         <!-- gebruiksperiode-start -->
         <!-- gebruiksperiode-eind -->
         <xsl:if test="$IVL_TS/hl7:low[@value]">
            <!-- gebruiksperiode-start -->
            <!-- TODO: er kunnen er meer dan 1 zijn in 6.12 - neem de laagste low als gebruiksperiode startdatum -->
            <!-- en denk ook nog aan intelligentie voor width en high!!! -->
            <xsl:variable name="start-datums">
               <xsl:for-each select="$IVL_TS/hl7:low[@value]">
                  <xsl:value-of select="nf:appendDate2DateTime(./@value)"/>
               </xsl:for-each>
            </xsl:variable>
            <xsl:comment>start-datums is: <xsl:value-of select="$start-datums"/></xsl:comment>
            <xsl:call-template name="mp9-gebruiksperiode-start">
<!--               <xsl:with-param name="inputValue" select="format-number((min($start-datums),)"/>
-->               <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
               <xsl:with-param name="xsd-comp" select="$xsd-toedieningsafspraak"/>
            </xsl:call-template>
         </xsl:if>
         <!-- gebruiksperiode-eind -->
         <xsl:for-each select="$IVL_TS/hl7:high[@value]">
            <xsl:call-template name="mp9-gebruiksperiode-eind">
               <xsl:with-param name="inputValue" select="./@value"/>
               <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
               <xsl:with-param name="xsd-comp" select="$xsd-toedieningsafspraak"/>
            </xsl:call-template>
         </xsl:for-each>
         <!-- identificatie -->
         <xsl:for-each select="$current-dispense-event/hl7:id[@extension]">
            <identificatie root="{./@root}" value="{concat('TAConverted_', ./@extension)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20134"/>
         </xsl:for-each>
         <!-- er is geen afspraakdatum in een 6.12 verstrekkingenbericht -->
         <!-- benaderen met verstrekkingsdatum -->
         <xsl:comment>afspraakdatum is benaderd met de verstrekkingsdatum (medicationDispenseEvent/effectiveTime)</xsl:comment>
         <!-- afspraakdatum -->
         <xsl:for-each select="$current-dispense-event/hl7:effectiveTime[@value]">
            <afspraakdatum conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20133">
               <xsl:attribute name="value" select="nf:formatHL72XMLDate(./@value, nf:determine_date_precision(./@value))"/>
            </afspraakdatum>
         </xsl:for-each>
         <!-- gebruiksperiode -->
         <xsl:for-each select="$IVL_TS/hl7:width[@value]">
            <gebruiksperiode value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22660"/>
         </xsl:for-each>
         <!-- geannuleerd indicator en stoptype wordt niet ondersteund in 6.12 -->
         <!--<geannuleerd_indicator conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23034" value="UNK"/>
         <stoptype value="1" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22498" code="1" codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.5.2.1" displayName="Onderbreking"/>-->
         <!-- verstrekker -->
         <xsl:for-each select="$current-dispense-event/hl7:responsibleParty/hl7:assignedCareProvider/hl7:representedOrganization">
            <xsl:variable name="verstrekker-complexType" select="$xsd-toedieningsafspraak//xs:element[@name = 'verstrekker']/@type"/>
            <xsl:variable name="xsd-verstrekker" select="$xsd-ada//xs:complexType[@name = $verstrekker-complexType]"/>
            <verstrekker conceptId="{$xsd-verstrekker/xs:attribute[@name='conceptId']/@fixed}">
               <!-- zorgaanbieder -->
               <xsl:variable name="zorgaanbieder-complexType" select="$xsd-verstrekker//xs:element[@name = 'zorgaanbieder']/@type"/>
               <xsl:variable name="xsd-zorgaanbieder" select="$xsd-ada//xs:complexType[@name = $zorgaanbieder-complexType]"/>
               <zorgaanbieder conceptId="{$xsd-zorgaanbieder/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="mp9-zorgaanbieder">
                     <xsl:with-param name="hl7-current-organization" select="."/>
                     <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                     <xsl:with-param name="xsd-parent-of-zorgaanbieder" select="$xsd-zorgaanbieder"/>
                  </xsl:call-template>
               </zorgaanbieder>
            </verstrekker>
         </xsl:for-each>
         <!-- reden afspraak wordt niet ondersteund in 6.12 -->
         <!--         <reden_afspraak conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22499" value="reden afspraak TA"/>-->
         <!-- geneesmiddel_bij_toedieningsafspraak  -->
         <xsl:for-each select=".//hl7:product/hl7:dispensedMedication/hl7:MedicationKind">
            <xsl:variable name="geneesmiddel_bij_toedieningsafspraak-complexType" select="$xsd-toedieningsafspraak//xs:element[@name = 'geneesmiddel_bij_toedieningsafspraak']/@type"/>
            <xsl:variable name="xsd-geneesmiddel_bij_toedieningsafspraak" select="$xsd-ada//xs:complexType[@name = $geneesmiddel_bij_toedieningsafspraak-complexType]"/>
            <geneesmiddel_bij_toedieningsafspraak conceptId="{$xsd-geneesmiddel_bij_toedieningsafspraak/xs:attribute[@name='conceptId']/@fixed}">
               <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.106_20130521000000">
                  <xsl:with-param name="product-hl7" select="."/>
                  <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                  <xsl:with-param name="xsd-geneesmiddel" select="$xsd-geneesmiddel_bij_toedieningsafspraak"/>
               </xsl:call-template>
            </geneesmiddel_bij_toedieningsafspraak>
         </xsl:for-each>
         <!-- gebruiksinstructie -->
         <xsl:call-template name="mp9-gebruiksinstructie-from-mp612">
            <xsl:with-param name="hl7-comp" select="."/>
            <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
            <xsl:with-param name="xsd-comp" select="$xsd-toedieningsafspraak"/>
         </xsl:call-template>
         <!--         <xsl:for-each select=".//hl7:therapeuticAgentOf/hl7:medicationAdministrationRequest">
            <gebruiksinstructie conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22098">
               <!-\- omschrijving -\->
               <xsl:for-each select="./hl7:text">
                  <omschrijving conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22619">
                     <xsl:attribute name="value" select="./text()"/>
                  </omschrijving>
               </xsl:for-each>
               <!-\- toedieningsweg -\->
               <toedieningsweg conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22620">
                  <xsl:choose>
                     <xsl:when test="./hl7:routeCode">
                        <xsl:call-template name="mp9-code-attribs">
                           <xsl:with-param name="current-hl7-code" select="./hl7:routeCode"/>
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:otherwise>
                        <!-\- Niet aanwezig in 6.12 -\->
                        <xsl:attribute name="code" select="'NI'"/>
                        <xsl:attribute name="codeSystem" select="'2.16.840.1.113883.5.1008'"/>
                        <xsl:attribute name="displayName" select="'geen informatie'"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </toedieningsweg>
               <!-\- aanvullende_instructie -\->
               <xsl:for-each select="./hl7:support2/hl7:medicationAdministrationInstruction/hl7:code">
                  <aanvullende_instructie conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22621">
                     <xsl:call-template name="mp9-code-attribs">
                        <xsl:with-param name="current-hl7-code" select="."/>
                     </xsl:call-template>
                  </aanvullende_instructie>
               </xsl:for-each>
               <!-\- herhaalperiode_cyclisch_schema -\->
               <herhaalperiode_cyclisch_schema unit="d" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22622" value="4"/>
               <!-\-doseerinstructie -\->
               <doseerinstructie conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22623">
                  <volgnummer conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22624" value="1"/>
                  <doseerduur unit="dag" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22625" value="5"/>
                  <dosering conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22626">
                     <keerdosis conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22627">
                        <aantal conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22628">
                           <min conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22698" value="1"/>
                           <vaste_waarde conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22699" value="2"/>
                           <max conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22700" value="4"/>
                        </aantal>
                        <eenheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22629" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="milliliter" code="203"/>
                     </keerdosis>
                     <toedieningsschema conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22631">
                        <frequentie conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22632">
                           <aantal conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22633">
                              <min conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22701" value="4"/>
                              <vaste_waarde conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22702" value="5"/>
                              <max conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22703" value="6"/>
                           </aantal>
                           <tijdseenheid unit="minuut" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22634" value="10"/>
                        </frequentie>
                        <interval unit="dag" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22635" value="1"/>
                        <toedientijd conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22636" value="2018-04-06T05:00:00"/>
                        <weekdag value="2" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22637" code="307147007" codeSystem="2.16.840.1.113883.6.96" displayName="dinsdag"/>
                        <dagdeel value="3" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22638" code="3157002" codeSystem="2.16.840.1.113883.6.96" displayName="'s avonds"/>
                     </toedieningsschema>
                     <zo_nodig conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22639">
                        <criterium conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22640">
                           <code value="11" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22641" code="1387" codeSystem="2.16.840.1.113883.2.4.4.5" displayName="bij hoest"/>
                           <omschrijving conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22642" value="zo nodig omschrijving"/>
                        </criterium>
                        <maximale_dosering conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22643">
                           <aantal conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22644" value="60"/>
                           <eenheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22645" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" code="203" displayName="milliliter"/>
                           <tijdseenheid unit="dag" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22646" value="1"/>
                        </maximale_dosering>
                     </zo_nodig>
                     <toedieningssnelheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22648">
                        <waarde conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22649">
                           <min conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22650" value="7"/>
                           <vaste_waarde conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22651" value="8"/>
                           <max conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22652" value="9"/>
                        </waarde>
                        <eenheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22653" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="milliliter" code="203"/>
                        <tijdseenheid unit="minuut" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22654" value="2"/>
                     </toedieningssnelheid>
                     <toedieningsduur unit="minuut" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23142" value="10"/>
                  </dosering>
               </doseerinstructie>
            </gebruiksinstructie>
         </xsl:for-each>
-->
         <!-- 6.12 kent geen aanvullende informatie en toelichting in vrije tekst -->
         <!--<aanvullende_informatie value="16" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23284" code="16" codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.5.2.14.2053" displayName="Melding lareb"/>
         <toelichting conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22275" value="toelichting bij TA"/>-->
         <!-- MP 6.1x heeft wel een relatie naar het voorschrift (medicatieafspraak + verstrekkingsverzoek) maar geen relatie naar de bouwsteen medicatieafspraak. -->
         <!-- verplicht in MP 9 dus een nullFlavor -->
         <relatie_naar_medicatieafspraak conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22394">
            <identificatie conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22395" value="NI" root="'2.16.840.1.113883.5.1008'"/>
         </relatie_naar_medicatieafspraak>
      </toedieningsafspraak>

   </xsl:template>
   <xsl:template name="mp9-verstrekking-from-mp612">
      <xsl:param name="current-hl7-verstrekking" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-mbh"/>
      <verstrekking conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20270">
         <xsl:for-each select="./hl7:id[@extension]">
            <identificatie conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20271">
               <xsl:attribute name="root" select="./@root"/>
               <xsl:attribute name="value" select="./@extension"/>
            </identificatie>
         </xsl:for-each>
         <!-- 6.12 heeft geen echte verstrekkingsdatum -->
         <datum value="2018-04-18T00:00:00" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20272"/>
         <aanschrijfdatum value="2018-04-18T00:00:00" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22500"/>
         <verstrekker conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20858">
            <zorgaanbieder conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19791">
               <zorgaanbieder_identificatie_nummer value="12341234" root="1.2.3.999" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19792"/>
               <organisatie_naam value="verstrekker organisatienaam" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19793"/>
            </zorgaanbieder>
         </verstrekker>
         <verstrekte_hoeveelheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20923">
            <aantal value="300" unit="ml" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22601"/>
            <eenheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22602" code="203" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="milliliter"/>
         </verstrekte_hoeveelheid>
         <verstrekt_geneesmiddel conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22259">
            <product conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22260">
               <product_code conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22679" code="1234" codeSystem="2.16.840.1.113883.2.4.4.7" displayName="zie ta"/>
            </product>
         </verstrekt_geneesmiddel>
         <verbruiksduur value="20" unit="dag" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20924"/>
         <afleverlocatie value="bij de woonboot" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20925"/>
         <distributievorm value="1" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20927" code="1" codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.5.3.8" displayName="Geïndividualiseerd distributiesysteem"/>
         <aanvullende_informatie value="2" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23285" code="2" codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.5.2.14.2052" displayName="Recall"/>
         <toelichting value="Toelichting bij verstrekking" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22276"/>
         <relatie_naar_verstrekkingsverzoek conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22396">
            <identificatie value="MBH1-VV1" root="1.2.3.999" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22397"/>
         </relatie_naar_verstrekkingsverzoek>
      </verstrekking>

   </xsl:template>
   <xsl:template name="mp9-weekdag">
      <!-- mooier zou zijn om de weekdag uit te rekenen op basis van de datum -->
      <xsl:param name="hl7-phase-low"/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-toedieningsschema"/>
      <xsl:variable name="hl7-weekdag" select="substring($hl7-phase-low/@value, 1, 8)"/>
      <xsl:variable name="weekdag-xml-date" select="nf:formatHL72XMLDate($hl7-weekdag, 'dag')"/>
      <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'weekdag']/@type"/>
      <weekdag conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
         <xsl:choose>
            <xsl:when test="nf:day-of-week($weekdag-xml-date) = 1">
               <xsl:attribute name="code">307145004</xsl:attribute>
               <xsl:attribute name="displayName">maandag</xsl:attribute>
               <xsl:attribute name="codeSystem">2.16.840.1.113883.6.96</xsl:attribute>
               <xsl:attribute name="codeSystemName">SNOMED CT</xsl:attribute>
            </xsl:when>
            <xsl:when test="nf:day-of-week($weekdag-xml-date) = 2">
               <xsl:attribute name="code">307147007</xsl:attribute>
               <xsl:attribute name="displayName">dinsdag</xsl:attribute>
               <xsl:attribute name="codeSystem">2.16.840.1.113883.6.96</xsl:attribute>
               <xsl:attribute name="codeSystemName">SNOMED CT</xsl:attribute>
            </xsl:when>
            <xsl:when test="nf:day-of-week($weekdag-xml-date) = 3">
               <xsl:attribute name="code">307148002</xsl:attribute>
               <xsl:attribute name="displayName">woensdag</xsl:attribute>
               <xsl:attribute name="codeSystem">2.16.840.1.113883.6.96</xsl:attribute>
               <xsl:attribute name="codeSystemName">SNOMED CT</xsl:attribute>
            </xsl:when>
            <xsl:when test="nf:day-of-week($weekdag-xml-date) = 4">
               <xsl:attribute name="code">307149005</xsl:attribute>
               <xsl:attribute name="displayName">donderdag</xsl:attribute>
               <xsl:attribute name="codeSystem">2.16.840.1.113883.6.96</xsl:attribute>
               <xsl:attribute name="codeSystemName">SNOMED CT</xsl:attribute>
            </xsl:when>
            <xsl:when test="nf:day-of-week($weekdag-xml-date) = 5">
               <xsl:attribute name="code">307150005</xsl:attribute>
               <xsl:attribute name="displayName">vrijdag</xsl:attribute>
               <xsl:attribute name="codeSystem">2.16.840.1.113883.6.96</xsl:attribute>
               <xsl:attribute name="codeSystemName">SNOMED CT</xsl:attribute>
            </xsl:when>
            <xsl:when test="nf:day-of-week($weekdag-xml-date) = 6">
               <xsl:attribute name="code">307151009</xsl:attribute>
               <xsl:attribute name="displayName">zaterdag</xsl:attribute>
               <xsl:attribute name="codeSystem">2.16.840.1.113883.6.96</xsl:attribute>
               <xsl:attribute name="codeSystemName">SNOMED CT</xsl:attribute>
            </xsl:when>
            <xsl:when test="nf:day-of-week($weekdag-xml-date) = 0">
               <xsl:attribute name="code">307146003</xsl:attribute>
               <xsl:attribute name="displayName">zondag</xsl:attribute>
               <xsl:attribute name="codeSystem">2.16.840.1.113883.6.96</xsl:attribute>
               <xsl:attribute name="codeSystemName">SNOMED CT</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="nullFlavor">OTH</xsl:attribute>
               <originalText>Unable to convert input ('<xsl:value-of select="$hl7-weekdag"/>') to weekday.</originalText>
            </xsl:otherwise>
         </xsl:choose>
      </weekdag>
   </xsl:template>
   <xsl:template name="mp9-zorgaanbieder">
      <xsl:param name="hl7-current-organization"/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-parent-of-zorgaanbieder"/>
      <xsl:variable name="zorgaanbieder2-complexType" select="$xsd-parent-of-zorgaanbieder//xs:element[@name = 'zorgaanbieder']/@type"/>
      <xsl:variable name="xsd-zorgaanbieder2" select="$xsd-ada//xs:complexType[@name = $zorgaanbieder2-complexType]"/>
      <zorgaanbieder conceptId="{$xsd-zorgaanbieder2/xs:attribute[@name='conceptId']/@fixed}">
         <xsl:for-each select="./hl7:id">
            <xsl:variable name="xsd-complexType" select="$xsd-zorgaanbieder2//xs:element[@name = 'zorgaanbieder_identificatie_nummer']/@type"/>
            <zorgaanbieder_identificatie_nummer value="{./@extension}" root="{./@root}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
         </xsl:for-each>
         <!-- organisatienaam has 1..1 R in MP 9 ADA transactions, but is not always present in HL7 input messages.  -->
         <!-- fill with nullFlavor if necessary -->
         <xsl:variable name="xsd-complexType" select="$xsd-zorgaanbieder2//xs:element[@name = 'organisatie_naam']/@type"/>
         <organisatie_naam conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
            <xsl:choose>
               <xsl:when test="./hl7:name">
                  <xsl:attribute name="value" select="./hl7:name/text()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:attribute name="nullFlavor">NI</xsl:attribute>
               </xsl:otherwise>
            </xsl:choose>
         </organisatie_naam>
      </zorgaanbieder>
   </xsl:template>
   <!-- Medication Kind 6.12 to ADA 9 -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.106_20130521000000">
      <xsl:param name="product-hl7" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-geneesmiddel"/>
      <xsl:variable name="xsd-product-complexType" select="$xsd-geneesmiddel//xs:element[@name = 'product']/@type"/>
      <xsl:variable name="xsd-product" select="$xsd-ada//xs:complexType[@name = $xsd-product-complexType]"/>
      <product conceptId="{$xsd-product/xs:attribute[@name='conceptId']/@fixed}">
         <xsl:for-each select="./hl7:code[@code or @nullFlavor]">
            <xsl:variable name="xsd-complexType" select="$xsd-product//xs:element[@name = 'product_code']/@type"/>
            <product_code conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
               <!-- Let op! Er is (nog?) geen ondersteuning voor optionele translations... -->
               <xsl:call-template name="mp9-code-attribs">
                  <xsl:with-param name="current-hl7-code" select="."/>
               </xsl:call-template>
            </product_code>
         </xsl:for-each>
         <xsl:for-each select=".[hl7:code[@nullFlavor]] | .[not(hl7:code)]">
            <xsl:variable name="xsd-product_specificatie-complexType" select="$xsd-product//xs:element[@name = 'product_specificatie']/@type"/>
            <xsl:variable name="xsd-product_specificatie" select="$xsd-ada//xs:complexType[@name = $xsd-product_specificatie-complexType]"/>
            <product_specificatie conceptId="{$xsd-product_specificatie/xs:attribute[@name='conceptId']/@fixed}">
               <!-- product_naam -->
               <xsl:for-each select="./hl7:code/hl7:originalText">
                  <xsl:variable name="xsd-complexType" select="$xsd-product_specificatie//xs:element[@name = 'product_naam']/@type"/>
                  <product_naam value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
               </xsl:for-each>
               <!-- omschrijving -->
               <xsl:for-each select="./hl7:desc">
                  <xsl:variable name="xsd-complexType" select="$xsd-product_specificatie//xs:element[@name = 'omschrijving']/@type"/>
                  <omschrijving value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
               </xsl:for-each>
               <!-- farmaceutische vorm -->
               <xsl:for-each select="./hl7:formCode">
                  <xsl:variable name="xsd-complexType" select="$xsd-product_specificatie//xs:element[@name = 'farmaceutische_vorm']/@type"/>
                  <farmaceutische_vorm conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                     <xsl:call-template name="mp9-code-attribs">
                        <xsl:with-param name="current-hl7-code" select="."/>
                     </xsl:call-template>
                  </farmaceutische_vorm>
               </xsl:for-each>
               <!-- ingredient -->
               <xsl:for-each select="./hl7:activeIngredient | ./hl7:otherIngredient">
                  <xsl:variable name="xsd-ingredient-complexType" select="$xsd-product_specificatie//xs:element[@name = 'ingredient']/@type"/>
                  <xsl:variable name="xsd-ingredient" select="$xsd-ada//xs:complexType[@name = $xsd-ingredient-complexType]"/>
                  <ingredient conceptId="{$xsd-ingredient/xs:attribute[@name='conceptId']/@fixed}">
                     <!-- sterkte -->
                     <xsl:for-each select="./hl7:quantity">
                        <xsl:variable name="xsd-sterkte-complexType" select="$xsd-ingredient//xs:element[@name = 'sterkte']/@type"/>
                        <xsl:variable name="xsd-sterkte" select="$xsd-ada//xs:complexType[@name = $xsd-sterkte-complexType]"/>
                        <sterkte conceptId="{$xsd-sterkte/xs:attribute[@name='conceptId']/@fixed}">
                           <!-- hoeveelheid_ingredient -->
                           <xsl:for-each select="./hl7:numerator[.//@value]">
                              <xsl:variable name="xsd-hoeveelheid_ingredient-complexType" select="$xsd-sterkte//xs:element[@name = 'hoeveelheid_ingredient']/@type"/>
                              <xsl:variable name="xsd-hoeveelheid_ingredient" select="$xsd-ada//xs:complexType[@name = $xsd-hoeveelheid_ingredient-complexType]"/>
                              <hoeveelheid_ingredient conceptId="{$xsd-hoeveelheid_ingredient/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:call-template name="mp-ingredient-waarde-en-eenheid">
                                    <xsl:with-param name="hl7-num-or-denom" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-hoeveelheid" select="$xsd-hoeveelheid_ingredient"/>
                                 </xsl:call-template>
                              </hoeveelheid_ingredient>
                           </xsl:for-each>
                           <!-- hoeveelheid_product  -->
                           <xsl:for-each select="./hl7:denominator[.//@value]">
                              <xsl:variable name="xsd-hoeveelheid_product-complexType" select="$xsd-sterkte//xs:element[@name = 'hoeveelheid_product']/@type"/>
                              <xsl:variable name="xsd-hoeveelheid_product" select="$xsd-ada//xs:complexType[@name = $xsd-hoeveelheid_product-complexType]"/>
                              <hoeveelheid_product conceptId="{$xsd-hoeveelheid_product/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:call-template name="mp-ingredient-waarde-en-eenheid">
                                    <xsl:with-param name="hl7-num-or-denom" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-hoeveelheid" select="$xsd-hoeveelheid_product"/>
                                 </xsl:call-template>
                              </hoeveelheid_product>
                           </xsl:for-each>
                        </sterkte>
                     </xsl:for-each>
                     <!-- ingredient_code -->
                     <xsl:for-each select="./(hl7:activeIngredientMaterialKind | ./hl7:ingredientMaterialKind)/hl7:code">
                        <xsl:variable name="xsd-complexType" select="$xsd-ingredient//xs:element[@name = 'ingredient_code']/@type"/>
                        <ingredient_code conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                           <xsl:call-template name="mp9-code-attribs">
                              <xsl:with-param name="current-hl7-code" select="."/>
                           </xsl:call-template>
                        </ingredient_code>
                     </xsl:for-each>
                  </ingredient>
               </xsl:for-each>
            </product_specificatie>
         </xsl:for-each>
      </product>
   </xsl:template>
   <!-- Medication Dispense Event 6.12 -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.110_20130521000000">
      <xsl:param name="current-dispense-event" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-mbh"/>
      <medicamenteuze_behandeling conceptId="{$xsd-mbh/xs:attribute[@name='conceptId']/@fixed}">
         <!-- mbh id is not known in 6.12. We have to make something up -->
         <xsl:for-each select="$current-dispense-event/hl7:id[@extension]">
            <xsl:variable name="identificatie-complexType" select="$xsd-mbh//xs:element[@name = 'identificatie']/@type"/>
            <identificatie value="{concat('MedBehConverted_', ./@extension)}" root="{./@root}" conceptId="{$xsd-ada//xs:complexType[@name=$identificatie-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
         </xsl:for-each>
         <xsl:variable name="IVL_TS-gebruiksperiode" select="$current-dispense-event//hl7:medicationAdministrationRequest//*[(local-name-from-QName(resolve-QName(@xsi:type, .)) = 'IVL_TS' and namespace-uri-from-QName(resolve-QName(@xsi:type, .)) = 'urn:hl7-org:v3')]"/>
         <xsl:call-template name="mp9-toedieningsafspraak-from-mp612">
            <xsl:with-param name="current-dispense-event" select="$current-dispense-event"/>
            <xsl:with-param name="IVL_TS" select="$IVL_TS-gebruiksperiode"/>
            <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
            <xsl:with-param name="xsd-mbh" select="$xsd-mbh"/>
         </xsl:call-template>
         <xsl:call-template name="mp9-verstrekking-from-mp612">
            <xsl:with-param name="current-hl7-verstrekking" select="."/>
            <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
            <xsl:with-param name="xsd-mbh" select="$xsd-mbh"/>
         </xsl:call-template>
      </medicamenteuze_behandeling>
   </xsl:template>
   <!-- PatientNL in verstrekking 6.12 -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.816_20130521000000">
      <xsl:variable name="current-patient" select="."/>
      <patient conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19798">
         <xsl:for-each select="$current-patient/hl7:Person/hl7:name">
            <xsl:call-template name="mp9-naamgegevens">
               <xsl:with-param name="current-hl7-name" select="."/>
            </xsl:call-template>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:id">
            <patient_identificatienummer conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19829">
               <xsl:attribute name="root" select="./@root"/>
               <xsl:attribute name="value" select="./@extension"/>
            </patient_identificatienummer>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:Person/hl7:birthTime[@value]">
            <geboortedatum conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19830">
               <xsl:variable name="precision" select="nf:determine_date_precision(./@value)"/>
               <xsl:attribute name="value" select="nf:formatHL72XMLDate(./@value, $precision)"/>
            </geboortedatum>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:Person/hl7:administrativeGenderCode">
            <xsl:call-template name="mp9-geslacht">
               <xsl:with-param name="current-administrativeGenderCode" select="."/>
            </xsl:call-template>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:Person/hl7:multipleBirthInd[@value]">
            <meerling_indicator conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19832">
               <xsl:attribute name="value" select="./@value"/>
            </meerling_indicator>
         </xsl:for-each>
      </patient>
   </xsl:template>
   <!-- MP 9.0 CDA Author Participation -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9066_20160615212337">
      <xsl:param name="author-hl7" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-auteur"/>

      <xsl:for-each select="$author-hl7/hl7:assignedAuthor">
         <xsl:variable name="zorgverlener-complexType" select="$xsd-auteur//xs:element[@name = 'zorgverlener']/@type"/>
         <xsl:variable name="xsd-zorgverlener" select="$xsd-ada//xs:complexType[@name = $zorgverlener-complexType]"/>
         <zorgverlener conceptId="{$xsd-zorgverlener/xs:attribute[@name='conceptId']/@fixed}">
            <xsl:for-each select="./hl7:id">
               <xsl:variable name="xsd-complexType" select="$xsd-zorgverlener//xs:element[@name = 'zorgverlener_identificatie_nummer']/@type"/>
               <zorgverlener_identificatie_nummer value="{./@extension}" root="{./@root}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
            </xsl:for-each>
            <xsl:for-each select="./hl7:assignedPerson/hl7:name">
               <xsl:variable name="zorgverlener_naam-complexType" select="$xsd-zorgverlener//xs:element[@name = 'zorgverlener_naam']/@type"/>
               <xsl:variable name="xsd-zorgverlener_naam" select="$xsd-ada//xs:complexType[@name = $zorgverlener_naam-complexType]"/>
               <zorgverlener_naam conceptId="{$xsd-zorgverlener_naam/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:variable name="naamgegevens-complexType" select="$xsd-zorgverlener_naam//xs:element[@name = 'naamgegevens']/@type"/>
                  <xsl:variable name="xsd-naamgegevens" select="$xsd-ada//xs:complexType[@name = $naamgegevens-complexType]"/>
                  <naamgegevens conceptId="{$xsd-naamgegevens/xs:attribute[@name='conceptId']/@fixed}">
                     <!-- ongestructureerde_naam -->
                     <xsl:for-each select=".[text()][not(child::*)]">
                        <xsl:variable name="xsd-complexType" select="$xsd-naamgegevens//xs:element[@name = 'ongestructureerde_naam']/@type"/>
                        <ongestructureerde_naam conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                           <xsl:attribute name="value">
                              <xsl:value-of select="."/>
                           </xsl:attribute>
                        </ongestructureerde_naam>
                        <!-- achternaam is 1..1R, die vullen we dan maar even met een nullFlavor vanwege ada xsd foutmeldingen -->
                        <xsl:variable name="geslachtsnaam-complexType" select="$xsd-naamgegevens//xs:element[@name = 'geslachtsnaam']/@type"/>
                        <xsl:variable name="xsd-geslachtsnaam" select="$xsd-ada//xs:complexType[@name = $geslachtsnaam-complexType]"/>
                        <geslachtsnaam conceptId="{$xsd-geslachtsnaam/xs:attribute[@name='conceptId']/@fixed}">
                           <xsl:variable name="xsd-complexType" select="$xsd-geslachtsnaam//xs:element[@name = 'achternaam']/@type"/>
                           <achternaam nullFlavor="NI" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                        </geslachtsnaam>
                     </xsl:for-each>
                     <xsl:for-each select="./hl7:given[contains(@qualifier, 'BR') or not(@qualifier)]">
                        <xsl:variable name="xsd-complexType" select="$xsd-naamgegevens//xs:element[@name = 'voornamen']/@type"/>
                        <voornamen value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                     </xsl:for-each>
                     <xsl:for-each select="./hl7:given[@qualifier = 'IN']">
                        <!-- in HL7 mogen de initialen van officiële voornamen niet herhaald / gedupliceerd worden in het initialen veld -->
                        <!-- in de zib moeten de initialen juist compleet zijn, dus de initialen hier toevoegen van de officiële voornamen -->
                        <xsl:variable name="initialen_concatted">
                           <xsl:for-each select="./hl7:given[contains(@qualifier, 'BR') or not(@qualifier)]">
                              <xsl:for-each select="tokenize(., ' ')">
                                 <xsl:value-of select="concat(substring(., 1, 1), '.')"/>
                              </xsl:for-each>
                           </xsl:for-each>
                           <xsl:for-each select="./hl7:given[@qualifier = 'IN']">
                              <xsl:value-of select="./text()"/>
                           </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="xsd-complexType" select="$xsd-naamgegevens//xs:element[@name = 'initialen']/@type"/>
                        <initialen value="{$initialen_concatted}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                     </xsl:for-each>
                     <xsl:for-each select="./hl7:family">
                        <xsl:variable name="geslachtsnaam-complexType" select="$xsd-naamgegevens//xs:element[@name = 'geslachtsnaam']/@type"/>
                        <xsl:variable name="xsd-geslachtsnaam" select="$xsd-ada//xs:complexType[@name = $geslachtsnaam-complexType]"/>
                        <geslachtsnaam conceptId="{$xsd-geslachtsnaam/xs:attribute[@name='conceptId']/@fixed}">
                           <xsl:for-each select="./preceding-sibling::hl7:prefix[@qualifier = 'VV'][position() = 1]">
                              <xsl:variable name="xsd-complexType" select="$xsd-geslachtsnaam//xs:element[@name = 'voorvoegsels']/@type"/>
                              <voorvoegsels value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                           </xsl:for-each>
                           <xsl:variable name="xsd-complexType" select="$xsd-geslachtsnaam//xs:element[@name = 'achternaam']/@type"/>
                           <achternaam value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
                        </geslachtsnaam>
                     </xsl:for-each>
                  </naamgegevens>
               </zorgverlener_naam>
            </xsl:for-each>
            <!-- specialisme -->
            <xsl:for-each select="./hl7:code">
               <xsl:variable name="xsd-complexType" select="$xsd-zorgverlener//xs:element[@name = 'specialisme']/@type"/>
               <specialisme conceptId="{$xsd-ada//xs:complexType[@name=$xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </specialisme>
            </xsl:for-each>
            <xsl:for-each select="./hl7:representedOrganization">
               <xsl:variable name="zorgaanbieder-complexType" select="$xsd-zorgverlener//xs:element[@name = 'zorgaanbieder']/@type"/>
               <xsl:variable name="xsd-zorgaanbieder" select="$xsd-ada//xs:complexType[@name = $zorgaanbieder-complexType]"/>
               <zorgaanbieder conceptId="{$xsd-zorgaanbieder/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="mp9-zorgaanbieder">
                     <xsl:with-param name="hl7-current-organization" select="."/>
                     <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                     <xsl:with-param name="xsd-parent-of-zorgaanbieder" select="$xsd-zorgaanbieder"/>
                  </xsl:call-template>
               </zorgaanbieder>
            </xsl:for-each>
         </zorgverlener>
      </xsl:for-each>
   </xsl:template>

   <!-- MP 9.0 MP CDA Medication Information -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9070_20160618193427">
      <xsl:param name="product-hl7" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-geneesmiddel"/>
      <xsl:variable name="xsd-product-complexType" select="$xsd-geneesmiddel//xs:element[@name = 'product']/@type"/>
      <xsl:variable name="xsd-product" select="$xsd-ada//xs:complexType[@name = $xsd-product-complexType]"/>
      <product conceptId="{$xsd-product/xs:attribute[@name='conceptId']/@fixed}">
         <xsl:variable name="xsd-complexType" select="$xsd-product//xs:element[@name = 'product_code']/@type"/>
         <product_code conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
            <xsl:for-each select="./hl7:code">
               <!-- Let op! Er is (nog?) geen ondersteuning voor optionele translations... -->
               <xsl:call-template name="mp9-code-attribs">
                  <xsl:with-param name="current-hl7-code" select="."/>
               </xsl:call-template>
            </xsl:for-each>
         </product_code>
         <xsl:for-each select=".[hl7:code[@nullFlavor]] | .[not(hl7:code)]">
            <xsl:variable name="xsd-product_specificatie-complexType" select="$xsd-product//xs:element[@name = 'product_specificatie']/@type"/>
            <xsl:variable name="xsd-product_specificatie" select="$xsd-ada//xs:complexType[@name = $xsd-product_specificatie-complexType]"/>
            <product_specificatie conceptId="{$xsd-product_specificatie/xs:attribute[@name='conceptId']/@fixed}">
               <!-- naam -->
               <xsl:for-each select="./hl7:name">
                  <xsl:variable name="xsd-complexType" select="$xsd-product_specificatie//xs:element[@name = 'product_naam']/@type"/>
                  <product_naam value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
               </xsl:for-each>
               <!-- omschrijving -->
               <xsl:for-each select="./pharm:desc">
                  <xsl:variable name="xsd-complexType" select="$xsd-product_specificatie//xs:element[@name = 'omschrijving']/@type"/>
                  <omschrijving value="{./text()}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
               </xsl:for-each>
               <!-- farmaceutische vorm -->
               <xsl:for-each select="./pharm:formCode">
                  <xsl:variable name="xsd-complexType" select="$xsd-product_specificatie//xs:element[@name = 'farmaceutische_vorm']/@type"/>
                  <farmaceutische_vorm conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                     <xsl:call-template name="mp9-code-attribs">
                        <xsl:with-param name="current-hl7-code" select="."/>
                     </xsl:call-template>
                  </farmaceutische_vorm>
               </xsl:for-each>
               <!-- ingredient -->
               <xsl:for-each select="./pharm:ingredient">
                  <xsl:variable name="xsd-ingredient-complexType" select="$xsd-product_specificatie//xs:element[@name = 'ingredient']/@type"/>
                  <xsl:variable name="xsd-ingredient" select="$xsd-ada//xs:complexType[@name = $xsd-ingredient-complexType]"/>
                  <ingredient conceptId="{$xsd-ingredient/xs:attribute[@name='conceptId']/@fixed}">
                     <!-- sterkte -->
                     <xsl:for-each select="./pharm:quantity">
                        <xsl:variable name="xsd-sterkte-complexType" select="$xsd-ingredient//xs:element[@name = 'sterkte']/@type"/>
                        <xsl:variable name="xsd-sterkte" select="$xsd-ada//xs:complexType[@name = $xsd-sterkte-complexType]"/>
                        <sterkte conceptId="{$xsd-sterkte/xs:attribute[@name='conceptId']/@fixed}">
                           <!-- hoeveelheid_ingredient -->
                           <xsl:for-each select="./hl7:numerator[.//@value]">
                              <xsl:variable name="xsd-hoeveelheid_ingredient-complexType" select="$xsd-sterkte//xs:element[@name = 'hoeveelheid_ingredient']/@type"/>
                              <xsl:variable name="xsd-hoeveelheid_ingredient" select="$xsd-ada//xs:complexType[@name = $xsd-hoeveelheid_ingredient-complexType]"/>
                              <hoeveelheid_ingredient conceptId="{$xsd-hoeveelheid_ingredient/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:call-template name="mp-ingredient-waarde-en-eenheid">
                                    <xsl:with-param name="hl7-num-or-denom" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-hoeveelheid" select="$xsd-hoeveelheid_ingredient"/>
                                 </xsl:call-template>
                              </hoeveelheid_ingredient>
                           </xsl:for-each>
                           <!-- hoeveelheid_product  -->
                           <xsl:for-each select="./hl7:denominator[.//@value]">
                              <xsl:variable name="xsd-hoeveelheid_product-complexType" select="$xsd-sterkte//xs:element[@name = 'hoeveelheid_product']/@type"/>
                              <xsl:variable name="xsd-hoeveelheid_product" select="$xsd-ada//xs:complexType[@name = $xsd-hoeveelheid_product-complexType]"/>
                              <hoeveelheid_product conceptId="{$xsd-hoeveelheid_product/xs:attribute[@name='conceptId']/@fixed}">
                                 <xsl:call-template name="mp-ingredient-waarde-en-eenheid">
                                    <xsl:with-param name="hl7-num-or-denom" select="."/>
                                    <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                                    <xsl:with-param name="xsd-hoeveelheid" select="$xsd-hoeveelheid_product"/>
                                 </xsl:call-template>
                              </hoeveelheid_product>
                           </xsl:for-each>
                        </sterkte>
                     </xsl:for-each>
                     <!-- ingredient_code -->
                     <xsl:for-each select="./pharm:ingredient/pharm:code">
                        <xsl:variable name="xsd-complexType" select="$xsd-ingredient//xs:element[@name = 'ingredient_code']/@type"/>
                        <ingredient_code conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}">
                           <xsl:call-template name="mp9-code-attribs">
                              <xsl:with-param name="current-hl7-code" select="."/>
                           </xsl:call-template>
                        </ingredient_code>
                     </xsl:for-each>
                  </ingredient>
               </xsl:for-each>
            </product_specificatie>
         </xsl:for-each>
      </product>
   </xsl:template>

   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9155_20160727135123_only_phase_low">
      <xsl:param name="current_IVL" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-toedieningsschema"/>
      <xsl:for-each select="$current_IVL/hl7nl:phase/hl7nl:low">
         <!-- toedientijd indien van toepassing -->
         <xsl:if test="string-length(./@value) > 8">
            <xsl:variable name="xsd-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'toedientijd']/@type"/>
            <toedientijd value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./@value), nf:determine_date_precision(./@value))}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
         </xsl:if>
         <xsl:call-template name="mp9-weekdag">
            <xsl:with-param name="hl7-phase-low" select="."/>
            <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
            <xsl:with-param name="xsd-toedieningsschema" select="$xsd-toedieningsschema"/>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>

   <!-- HL7NL Frequency -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9162_20161110120339">
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-toedieningsschema"/>

      <xsl:variable name="xsd-frequentie-complexType" select="$xsd-toedieningsschema//xs:element[@name = 'frequentie']/@type"/>
      <xsl:variable name="xsd-frequentie" select="$xsd-ada//xs:complexType[@name = $xsd-frequentie-complexType]"/>
      <frequentie conceptId="{$xsd-frequentie/xs:attribute[@name='conceptId']/@fixed}">
         <xsl:for-each select="./hl7nl:frequency/hl7nl:numerator">
            <xsl:variable name="xsd-aantal-complexType" select="$xsd-frequentie//xs:element[@name = 'aantal']/@type"/>
            <xsl:variable name="xsd-aantal" select="$xsd-ada//xs:complexType[@name = $xsd-aantal-complexType]"/>
            <aantal conceptId="{$xsd-aantal/xs:attribute[@name='conceptId']/@fixed}">
               <xsl:for-each select=".//hl7nl:low[@value]">
                  <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'min']/@type"/>
                  <min value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
               </xsl:for-each>
               <xsl:if test=".[@value]">
                  <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'vaste_waarde']/@type"/>
                  <vaste_waarde value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
               </xsl:if>
               <xsl:for-each select=".//hl7nl:high[@value]">
                  <xsl:variable name="xsd-complexType" select="$xsd-aantal//xs:element[@name = 'max']/@type"/>
                  <max value="{./@value}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
               </xsl:for-each>
            </aantal>
         </xsl:for-each>
         <xsl:for-each select="./hl7nl:frequency/hl7nl:denominator">
            <xsl:variable name="xsd-complexType" select="$xsd-frequentie//xs:element[@name = 'tijdseenheid']/@type"/>
            <tijdseenheid value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="{$xsd-ada//xs:complexType[@name = $xsd-complexType]/xs:attribute[@name='conceptId']/@fixed}"/>
         </xsl:for-each>
      </frequentie>

   </xsl:template>
   <!-- Medicatieafspraak MP 9.0 Inhoud -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9201_20180419121646">
      <xsl:param name="ma_hl7_90" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-mbh"/>
      <xsl:variable name="ma-complexType" select="$xsd-mbh//xs:element[@name = 'medicatieafspraak']/@type"/>
      <xsl:variable name="xsd-ma" select="$xsd-ada//xs:complexType[@name = $ma-complexType]"/>
      <!-- medicatieafspraak -->
      <xsl:for-each select="$ma_hl7_90">
         <medicatieafspraak conceptId="{$xsd-ma/xs:attribute[@name='conceptId']/@fixed}">
            <xsl:variable name="IVL_TS" select="./hl7:effectiveTime[@xsi:type = 'IVL_TS']"/>
            <xsl:for-each select="$IVL_TS/hl7:low">
               <xsl:call-template name="mp9-gebruiksperiode-start">
                  <xsl:with-param name="inputValue" select="./@value"/>
                  <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                  <xsl:with-param name="xsd-comp" select="$xsd-ma"/>
               </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="$IVL_TS/hl7:high">
               <xsl:call-template name="mp9-gebruiksperiode-eind">
                  <xsl:with-param name="inputValue" select="./@value"/>
                  <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                  <xsl:with-param name="xsd-comp" select="$xsd-ma"/>
               </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="./hl7:id">
               <identificatie value="{./@extension}" root="{./@root}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19758"/>
            </xsl:for-each>
            <xsl:for-each select="./hl7:author/hl7:time">
               <afspraakdatum value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./@value), nf:determine_date_precision(./@value))}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19757"/>
            </xsl:for-each>
            <xsl:for-each select="$IVL_TS/hl7:width">
               <gebruiksperiode value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19936"/>
            </xsl:for-each>
            <xsl:for-each select="./hl7:statusCode">
               <geannuleerd_indicator value="{./@code='nullified'}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23033"/>
            </xsl:for-each>
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9067']/hl7:value">
               <stoptype conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19954">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </stoptype>
            </xsl:for-each>
            <!-- relatie_naar_afspraak_of_gebruik -->
            <!-- relatie_naar ma -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9086']/hl7:id">
               <!-- medicatieafspraak -->
               <relatie_naar_afspraak_of_gebruik conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23238">
                  <identificatie root="{./@root}" value="{./@extension}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23239"/>
               </relatie_naar_afspraak_of_gebruik>
            </xsl:for-each>
            <!-- relatie_naar ta -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9101']/hl7:id">
               <!-- toedieningsafspraak -->
               <relatie_naar_afspraak_of_gebruik conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23238">
                  <identificatie_23288 root="{./@root}" value="{./@extension}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23288"/>
               </relatie_naar_afspraak_of_gebruik>
            </xsl:for-each>
            <!-- relatie_naar gb -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9176']/hl7:id">
               <!-- medicatiegebruik -->
               <relatie_naar_afspraak_of_gebruik conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23238">
                  <identificatie_23289 root="{./@root}" value="{./@extension}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23289"/>
               </relatie_naar_afspraak_of_gebruik>
            </xsl:for-each>
            <!-- voorschrijver -->
            <xsl:variable name="voorschrijver-complexType" select="$xsd-ma//xs:element[@name = 'voorschrijver']/@type"/>
            <xsl:variable name="xsd-voorschrijver" select="$xsd-ada//xs:complexType[@name = $voorschrijver-complexType]"/>
            <voorschrijver conceptId="{$xsd-voorschrijver/xs:attribute[@name='conceptId']/@fixed}">
               <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9066_20160615212337">
                  <xsl:with-param name="author-hl7" select="./hl7:author"/>
                  <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                  <xsl:with-param name="xsd-auteur" select="$xsd-voorschrijver"/>
               </xsl:call-template>
            </voorschrijver>
            <!-- reden afspraak -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9068']/hl7:value">
               <reden_afspraak conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22094">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </reden_afspraak>
            </xsl:for-each>
            <!-- reden van voorschrijven -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9160']/hl7:value">
               <reden_van_voorschrijven conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23133">
                  <probleem conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23134">
                     <probleem_naam conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23136">
                        <xsl:call-template name="mp9-code-attribs">
                           <xsl:with-param name="current-hl7-code" select="."/>
                        </xsl:call-template>
                     </probleem_naam>
                  </probleem>
               </reden_van_voorschrijven>
            </xsl:for-each>
            <!-- afgesproken_geneesmiddel -->
            <xsl:for-each select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial">
               <xsl:variable name="xsd-afgesproken_geneesmiddel-complexType" select="$xsd-ma//xs:element[@name = 'afgesproken_geneesmiddel']/@type"/>
               <xsl:variable name="xsd-afgesproken_geneesmiddel" select="$xsd-ada//xs:complexType[@name = $xsd-afgesproken_geneesmiddel-complexType]"/>
               <afgesproken_geneesmiddel conceptId="{$xsd-afgesproken_geneesmiddel/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9070_20160618193427">
                     <xsl:with-param name="product-hl7" select="."/>
                     <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                     <xsl:with-param name="xsd-geneesmiddel" select="$xsd-afgesproken_geneesmiddel"/>
                  </xsl:call-template>
               </afgesproken_geneesmiddel>
            </xsl:for-each>
            <!-- gebruiksinstructie -->
            <xsl:call-template name="mp9-gebruiksinstructie-from-mp9">
               <xsl:with-param name="hl7-comp" select="."/>
               <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
               <xsl:with-param name="xsd-comp" select="$xsd-ma"/>
            </xsl:call-template>
            <!-- lichaamslengte  -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9122']/hl7:value">
               <lichaamslengte conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23023">
                  <lengte_waarde value="{./@value}" unit="{nf:convertUnit_UCUM2ADA(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23024"> </lengte_waarde>
               </lichaamslengte>
            </xsl:for-each>
            <!-- lichaamsgewicht  -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9123']/hl7:value">
               <lichaamsgewicht conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23028">
                  <gewicht_waarde value="{./@value}" unit="{nf:convertUnit_UCUM2ADA(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23029"/>
               </lichaamsgewicht>
            </xsl:for-each>
            <!-- aanvullende_informatie -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9177']/hl7:value">
               <aanvullende_informatie conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23283">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </aanvullende_informatie>
            </xsl:for-each>
            <!-- toelichting -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9069']/hl7:text">
               <toelichting value="{./text()}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22273"/>
            </xsl:for-each>
         </medicatieafspraak>
      </xsl:for-each>
   </xsl:template>
   <!-- Medicatieafspraak MP 9.0 -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9216_20180423130413">
      <xsl:param name="ma_hl7_90" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-mbh"/>
      <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9201_20180419121646">
         <xsl:with-param name="ma_hl7_90" select="$ma_hl7_90"/>
         <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
         <xsl:with-param name="xsd-mbh" select="$xsd-mbh"/>
      </xsl:call-template>
   </xsl:template>
   <!-- Verstrekkingsverzoek MP 9.0 -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9231_20180423130413">
      <xsl:param name="vv_hl7_90" select="."/>
      <xsl:param name="xsd-ada"/>
      <xsl:param name="xsd-mbh"/>
      <xsl:variable name="vv-complexType" select="$xsd-mbh//xs:element[@name = 'verstrekkingsverzoek']/@type"/>
      <xsl:variable name="xsd-vv" select="$xsd-ada//xs:complexType[@name = $vv-complexType]"/>
      <!-- verstrekkingsverzoek  -->
      <xsl:for-each select="$vv_hl7_90">
         <verstrekkingsverzoek conceptId="{$xsd-vv/xs:attribute[@name='conceptId']/@fixed}">
            <!-- identificatie -->
            <xsl:for-each select="./hl7:id">
               <identificatie value="{./@extension}" root="{./@root}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22003"/>
            </xsl:for-each>
            <!-- datum -->
            <xsl:for-each select="./hl7:author/hl7:time">
               <datum value="{nf:formatHL72XMLDate(nf:appendDate2DateOrTime(./@value), nf:determine_date_precision(./@value))}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20060"/>
            </xsl:for-each>
            <!-- auteur -->
            <xsl:variable name="auteur-complexType" select="$xsd-vv//xs:element[@name = 'auteur']/@type"/>
            <xsl:variable name="xsd-auteur" select="$xsd-ada//xs:complexType[@name = $auteur-complexType]"/>
            <auteur conceptId="{$xsd-auteur/xs:attribute[@name='conceptId']/@fixed}">
               <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9066_20160615212337">
                  <xsl:with-param name="author-hl7" select="./hl7:author"/>
                  <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                  <xsl:with-param name="xsd-auteur" select="$xsd-auteur"/>
               </xsl:call-template>
            </auteur>
            <!-- te_verstrekken_hoeveelheid -->
            <xsl:for-each select="./hl7:quantity">
               <te_verstrekken_hoeveelheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19964">
                  <xsl:for-each select="./hl7:translation[@codeSystem = '2.16.840.1.113883.2.4.4.1.900.2']">
                     <aantal value="{./@value}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22599"/>
                     <eenheid conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22600">
                        <xsl:call-template name="mp9-code-attribs">
                           <xsl:with-param name="current-hl7-code" select="."/>
                        </xsl:call-template>
                     </eenheid>
                  </xsl:for-each>
               </te_verstrekken_hoeveelheid>
            </xsl:for-each>
            <!-- aantal_herhalingen -->
            <xsl:for-each select="./hl7:repeatNumber">
               <aantal_herhalingen value="{number(./@value)-1}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22120"/>
            </xsl:for-each>
            <!-- te_verstrekken_geneesmiddel  -->
            <xsl:for-each select="./hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial">
               <xsl:variable name="xsd-te_verstrekken_geneesmiddel-complexType" select="$xsd-vv//xs:element[@name = 'te_verstrekken_geneesmiddel']/@type"/>
               <xsl:variable name="xsd-te_verstrekken_geneesmiddel" select="$xsd-ada//xs:complexType[@name = $xsd-te_verstrekken_geneesmiddel-complexType]"/>
               <te_verstrekken_geneesmiddel conceptId="{$xsd-te_verstrekken_geneesmiddel/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9070_20160618193427">
                     <xsl:with-param name="product-hl7" select="."/>
                     <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                     <xsl:with-param name="xsd-geneesmiddel" select="$xsd-te_verstrekken_geneesmiddel"/>
                  </xsl:call-template>
               </te_verstrekken_geneesmiddel>
            </xsl:for-each>
            <!-- verbruiksperiode -->
            <xsl:for-each select="./hl7:expectedUseTime/hl7:width">
               <verbruiksperiode conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20062">
                  <duur value="{./@value}" unit="{nf:convertTime_UCUM2ADA_unit(./@unit)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20065"/>
               </verbruiksperiode>
            </xsl:for-each>
            <xsl:for-each select="./hl7:performer/hl7:assignedEntity/hl7:representedOrganization">
               <xsl:variable name="xsd-beoogd_verstrekker-complexType" select="$xsd-vv//xs:element[@name = 'beoogd_verstrekker']/@type"/>
               <xsl:variable name="xsd-beoogd_verstrekker" select="$xsd-ada//xs:complexType[@name = $xsd-beoogd_verstrekker-complexType]"/>
               <beoogd_verstrekker conceptId="{$xsd-beoogd_verstrekker/xs:attribute[@name='conceptId']/@fixed}">
                  <xsl:call-template name="mp9-zorgaanbieder">
                     <xsl:with-param name="hl7-current-organization" select="."/>
                     <xsl:with-param name="xsd-ada" select="$xsd-ada"/>
                     <xsl:with-param name="xsd-parent-of-zorgaanbieder" select="$xsd-beoogd_verstrekker"/>
                  </xsl:call-template>
               </beoogd_verstrekker>
            </xsl:for-each>
            <xsl:for-each select="./hl7:participant[@typeCode = 'DST']/hl7:participantRole[@classCode = 'SDLOC']/hl7:addr">
               <xsl:variable name="concatted_text">
                  <xsl:for-each select="./*">
                     <xsl:value-of select="concat(./text(), ' ')"/>
                  </xsl:for-each>
               </xsl:variable>
               <afleverlocatie value="{normalize-space($concatted_text)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.20068"/>
            </xsl:for-each>
            <!-- aanvullende_wensen -->
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9093']/hl7:code">
               <aanvullende_wensen conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22759">
                  <xsl:call-template name="mp9-code-attribs">
                     <xsl:with-param name="current-hl7-code" select="."/>
                  </xsl:call-template>
               </aanvullende_wensen>
            </xsl:for-each>
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9069']/hl7:text">
               <toelichting value="{./text()}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.22274"/>
            </xsl:for-each>
            <xsl:for-each select="./hl7:entryRelationship/*[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9086']/hl7:id">
               <relatie_naar_medicatieafspraak conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23286">
                  <identificatie value="{./@extension}" root="{./@root}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.23287"/>
               </relatie_naar_medicatieafspraak>
            </xsl:for-each>
         </verstrekkingsverzoek>
      </xsl:for-each>
   </xsl:template>
   <!-- PatientNL in voorschrift 9.0.x -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.3_20170602000000">
      <xsl:param name="current-patient" select="."/>
      <patient conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19798">
         <xsl:for-each select="$current-patient/hl7:patient/hl7:name">
            <xsl:call-template name="mp9-naamgegevens">
               <xsl:with-param name="current-hl7-name" select="."/>
            </xsl:call-template>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:id">
            <patient_identificatienummer conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19829">
               <xsl:attribute name="root" select="./@root"/>
               <xsl:attribute name="value" select="./@extension"/>
            </patient_identificatienummer>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:patient/hl7:birthTime[@value]">
            <geboortedatum conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19830">
               <xsl:variable name="precision" select="nf:determine_date_precision(./@value)"/>
               <xsl:attribute name="value" select="nf:formatHL72XMLDate(./@value, $precision)"/>
            </geboortedatum>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:patient/hl7:administrativeGenderCode">
            <xsl:call-template name="mp9-geslacht">
               <xsl:with-param name="current-administrativeGenderCode" select="."/>
            </xsl:call-template>
         </xsl:for-each>
         <xsl:for-each select="$current-patient/hl7:patient/sdtc:multipleBirthInd[@value]">
            <meerling_indicator conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.3.19832">
               <xsl:attribute name="value" select="./@value"/>
            </meerling_indicator>
         </xsl:for-each>
      </patient>
   </xsl:template>
   <!-- helper stuff -->
   <xsl:template name="chooseOperatorAttrib">
      <xsl:param name="operator"/>
      <xsl:choose>
         <xsl:when test="$operator = 'A' or $operator = 'I'">
            <xsl:attribute name="operator" select="$operator"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- geen attribuut opnemen -->
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="make_UCUM2Gstandard_translation">
      <!-- Produceert een regel met de <translation> van a UCUM unit naar de G-standaard -->
      <xsl:param name="UCUMvalue"/>
      <xsl:param name="UCUMunit"/>
      <xsl:choose>
         <xsl:when test="$UCUMunit eq 'ug'">
            <translation value="{$UCUMvalue}" code="252" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Microgram"/>
         </xsl:when>
         <xsl:when test="$UCUMunit eq 'mg'">
            <translation value="{$UCUMvalue}" code="229" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Milligram"/>
         </xsl:when>
         <xsl:when test="$UCUMunit eq 'g'">
            <translation value="{$UCUMvalue}" code="215" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Gram"/>
         </xsl:when>
         <xsl:when test="$UCUMunit eq 'ul'">
            <translation value="{$UCUMvalue}" code="254" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Microliter"/>
         </xsl:when>
         <xsl:when test="$UCUMunit eq 'ml'">
            <translation value="{$UCUMvalue}" code="233" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Milliliter"/>
         </xsl:when>
         <xsl:when test="$UCUMunit eq 'l'">
            <translation value="{$UCUMvalue}" code="222" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Liter"/>
         </xsl:when>
         <xsl:when test="$UCUMunit eq '[drp]'">
            <translation value="{$UCUMvalue}" code="303" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Druppel"/>
         </xsl:when>
         <!--
            Tablespoons en teaspoons zijn geschrapt uit de lijst units omdat ze niet nauwkeurig zijn. 
         <xsl:when test="$UCUMunit eq '[tsp_us]'">
            <translation value="{$UCUMvalue * 5}" code="233" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Milliliter"/>
         </xsl:when>
         <xsl:when test="$UCUMunit eq '[tbs_us]'">
            <translation value="{$UCUMvalue * 15}" code="233" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Milliliter"/> 
         </xsl:when>
         -->
         <xsl:when test="$UCUMunit eq '[iU]'">
            <translation value="{$UCUMvalue}" code="217" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Internat.eenh."/>
         </xsl:when>
         <xsl:when test="($UCUMunit eq '1')">
            <translation value="{$UCUMvalue}" code="245" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="stuk"/>
         </xsl:when>
         <xsl:when test="(lower-case($UCUMunit) eq 'eenheid')">
            <translation value="{$UCUMvalue}" code="211" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="Eenheid"/>
         </xsl:when>
         <xsl:when test="(lower-case($UCUMunit) eq 'dosis')">
            <translation value="{$UCUMvalue}" code="208" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="dosis"/>
         </xsl:when>
         <xsl:otherwise>
            <translation value="{$UCUMvalue}" code="0" codeSystem="2.16.840.1.113883.2.4.4.1.900.2" displayName="niet ondersteunde UCUM eenheid: {$UCUMunit}"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="UCUM2GstdBasiseenheid">
      <xsl:param name="UCUM"/>

      <xsl:variable name="gstd-code">
         <xsl:choose>
            <xsl:when test="string-length($UCUM) > 0">
               <xsl:choose>
                  <xsl:when test="$UCUM = 'cm'">205</xsl:when>
                  <xsl:when test="$UCUM = 'g'">215</xsl:when>
                  <xsl:when test="$UCUM = '[iU]'">217</xsl:when>
                  <xsl:when test="$UCUM = 'kg'">219</xsl:when>
                  <xsl:when test="$UCUM = 'l'">222</xsl:when>
                  <xsl:when test="$UCUM = 'mg'">229</xsl:when>
                  <xsl:when test="$UCUM = 'ml'">233</xsl:when>
                  <xsl:when test="$UCUM = 'mm'">234</xsl:when>
                  <xsl:when test="$UCUM = '1'">245</xsl:when>
                  <xsl:when test="$UCUM = 'ug'">252</xsl:when>
                  <xsl:when test="$UCUM = 'ul'">254</xsl:when>
                  <xsl:when test="$UCUM = '[drp]'">303</xsl:when>
                  <xsl:otherwise>Not supported UCUM eenheid, cannot convert to G-standaard basiseenheid: <xsl:value-of select="$UCUM"/></xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <!-- geen waarde meegekregen --> UCUM is an empty string. Not supported to convert to G-standaard basiseenheid. </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="gstd-displayname">
         <xsl:choose>
            <xsl:when test="string-length($UCUM) > 0">
               <xsl:choose>
                  <xsl:when test="$UCUM = 'cm'">centimeter</xsl:when>
                  <xsl:when test="$UCUM = 'g'">gram</xsl:when>
                  <xsl:when test="$UCUM = '[iU]'">internationale eenheid</xsl:when>
                  <xsl:when test="$UCUM = 'kg'">kilogram</xsl:when>
                  <xsl:when test="$UCUM = 'l'">liter</xsl:when>
                  <xsl:when test="$UCUM = 'mg'">milligram</xsl:when>
                  <xsl:when test="$UCUM = 'ml'">milliliter</xsl:when>
                  <xsl:when test="$UCUM = 'mm'">millimeter</xsl:when>
                  <xsl:when test="$UCUM = '1'">stuk</xsl:when>
                  <xsl:when test="$UCUM = 'ug'">microgram</xsl:when>
                  <xsl:when test="$UCUM = 'ul'">microliter</xsl:when>
                  <xsl:when test="$UCUM = '[drp]'">druppel</xsl:when>
                  <xsl:otherwise>Not supported UCUM eenheid, cannot convert to G-standaard basiseenheid: <xsl:value-of select="$UCUM"/></xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <!-- geen waarde meegekregen --> UCUM is an empty string. Not supported to convert to G-standaard basiseenheid. </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="code" select="$gstd-code"/>
      <xsl:attribute name="codeSystem" select="'2.16.840.1.113883.2.4.4.1.900.2'"/>
      <xsl:attribute name="displayName" select="$gstd-displayname"/>
   </xsl:template>
   <xsl:function name="nf:convertGstdBasiseenheid2UCUM" as="xs:string">
      <xsl:param name="GstdBasiseenheid_code" as="xs:string"/>

      <xsl:choose>
         <xsl:when test="$GstdBasiseenheid_code castable as xs:int">
            <xsl:choose>
               <xsl:when test="$GstdBasiseenheid_code = '205'">cm</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '208'">1</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '211'">1</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '215'">g</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '217'">[iU]</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '219'">kg</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '222'">l</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '229'">mg</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '233'">ml</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '234'">mm</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '245'">1</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '252'">ug</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '254'">ul</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '303'">[drp]</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '345'">1</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '490'">1</xsl:when>
               <xsl:when test="$GstdBasiseenheid_code = '500'">1</xsl:when>
               <xsl:otherwise>Not supported G-standaard basiseenheid: <xsl:value-of select="$GstdBasiseenheid_code"/></xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <!-- geen integer meegekregen --> G-standaard code is not an integer. Not supported G-standaard basiseenheid: "<xsl:value-of select="$GstdBasiseenheid_code"/>". </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$GstdBasiseenheid_code castable as xs:int"> </xsl:if>
   </xsl:function>
   <xsl:function name="nf:convertUnit_UCUM2ADA" as="xs:string">
      <xsl:param name="UCUMunit" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="lower-case($UCUMunit) eq 'g'">g</xsl:when>
         <xsl:when test="lower-case($UCUMunit) eq 'kg'">kg</xsl:when>
         <xsl:when test="lower-case($UCUMunit) eq 'cm'">cm</xsl:when>
         <xsl:when test="lower-case($UCUMunit) eq 'm'">m</xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$UCUMunit"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="nf:convertTime_UCUM2ADA_unit" as="xs:string?">
      <xsl:param name="UCUM-time" as="xs:string?"/>
      <xsl:if test="$UCUM-time">
         <xsl:choose>
            <xsl:when test="$UCUM-time = 's'">seconde</xsl:when>
            <xsl:when test="$UCUM-time = 'min'">minuut</xsl:when>
            <xsl:when test="$UCUM-time = 'h'">uur</xsl:when>
            <xsl:when test="$UCUM-time = 'd'">dag</xsl:when>
            <xsl:when test="$UCUM-time = 'wk'">week</xsl:when>
            <xsl:when test="$UCUM-time = 'mo'">maand</xsl:when>
            <xsl:when test="$UCUM-time = 'a'">jaar</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="concat('onbekende tijdseenheid: ', $UCUM-time)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:function>
   <xsl:function name="nf:determine_date_precision">
      <xsl:param name="input-hl7-date"/>
      <xsl:choose>
         <xsl:when test="string-length($input-hl7-date) &lt;= 8">day</xsl:when>
         <xsl:when test="string-length($input-hl7-date) > 8">second</xsl:when>
         <xsl:otherwise>not_supported</xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="nf:day-of-week" as="xs:integer?">
      <!-- courtesy to http://www.xsltfunctions.com/xsl/functx_day-of-week.html -->
      <xsl:param name="date" as="xs:anyAtomicType?"/>
      <xsl:sequence select="
            if (empty($date))
            then
               ()
            else
               xs:integer((xs:date($date) - xs:date('1901-01-06'))
               div xs:dayTimeDuration('P1D')) mod 7
            "/>
   </xsl:function>
   <!-- copy an element with all of it's contents in comments -->
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
   <!-- copy without comments -->
   <xsl:template name="copyWithoutComments">
      <xsl:copy>
         <xsl:for-each select="@* | *">
            <xsl:call-template name="copyWithoutComments"/>
         </xsl:for-each>
      </xsl:copy>
   </xsl:template>

</xsl:stylesheet>
