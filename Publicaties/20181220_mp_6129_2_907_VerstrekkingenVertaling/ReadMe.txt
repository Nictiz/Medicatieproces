Copyright © Nictiz

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html

===================================================================================================================================
Introduction
===================================================================================================================================

This publication has some conversion xslt's which convert a MP 6.12 'medicatieverstrekkingenlijst' to a generic 'ADA'-format for the 9.0.7 transaction beschikbaarstellen_verstrekkingenvertaling (hl7_2_ada\mp\6.12.9\opleveren_verstrekkingenlijst).
This publication also has some conversion xslt's which convert this generic 'ADA'-format to MP FHIR Resources (ada_2_fhir\mp\9.0.7\beschikbaarstellen_verstrekkingenvertaling).

Combining the two conversions above gives you a 6.12 to MP 9.0.7 FHIR conversion.

Please note that this conversion has not been tested with elaborate production-like data. It should not be applied in a real production situation before thorough testing.

The 'simple dataset xml format' is based on ADA format, more information about ADA can be found here:
https://www.art-decor.org/mediawiki/index.php/ADA_Walkthrough. It is not necessary to read all this to use the conversion xslt's. 
The xsd of the ada format is included in the folder "ada_schemas".

The ADA user front-end (where ada instances can be created using a GUI) for mp-mp907 can be found here: 
https://decor.nictiz.nl/art-decor/ada-data/projects/mp-mp907/views/medicatieproces_907_index.xhtml.

A complete empty xml instance in the ada format is included in the folder "ada_new".

===================================================================================================================================
hl7_2_ada\mp\6.12.9\opleveren_verstrekkingenlijst
===================================================================================================================================
This is a preliminary version of converting Beschikbaarstellen verstrekkingenlijst 6.12 payload to a relatively simple dataset xml format (based on functional definition of a MP 9 beschikbaarstellen medicatiegegevens transaction). It is based on the publication https://decor.nictiz.nl/medicatieproces/mp-html-20181220T121121/project.html.

The folder "payload" contains the stylesheet that does the conversion for the payload: "opleveren_verstrekkingenlijst_612_to_ada_vv.xsl"
This xslt uses the "../../../hl7_2_ada_mp_include.xsl" which is meant to be reused by other/different transactions and/or standard versions (such as 'sturen voorschrift' or 'medicatieoverzicht' or MP-9 CDA or MP-9 FHIR formats).
The hl7_2_ada_mp_include.xsl uses in its turn the ../hl7/hl7_2_ada_hl7_include.xsl which contains some hl7-specific stuff that can be reused over different domains (such as Geboortezorg and Ketenzorg).
The hl7_2_ada_hl7_include.xsl uses in its turn the ../../util/constants.xsl and ../../util/uuid.xsl which contains some generic stuff that can be reused over different types of conversions (ada_2_hl7, ada_2_fhir, hl7_2_ada, et cetera) and domains (such as Geboortezorg and Ketenzorg).

The folder 'hl7_instance' contains sample hl7 instance files. The folder ada_instance contains the result of the conversion for these sample files.

===================================================================================================================================
ada_2_fhir\mp\9.0.7\beschikbaarstellen_verstrekkingenvertaling
===================================================================================================================================

This is a preliminary version of converting Beschikbaarstellen verstrekkingenvertaling ada format to a FHIR Bundle. It is based on the publication https://decor.nictiz.nl/medicatieproces/mp-html-20181220T121121/project.html and the MedMij publication https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2018.06_Ontwerpen, use case Medicatiegegevens - Verstrekkingenvertaling.

The folder "payload" contains the stylesheet that does the conversion for the payload: "beschikbaarstellen_verstrekkingenvertaling_2_fhir.xsl"
This xslt uses the "../../../2_fhir_mp_include.xsl" which is meant to be reused by other/different transactions and/or standard versions (such as 'sturen voorschrift' or 'medicatieoverzicht' or MP-9 FHIR formats).
The 2_fhir_mp_include.xsl uses in its turn the ../fhir/2_fhir_fhir_include.xsl which contains some fhir-specific stuff that can be reused over different domains (such as Geboortezorg and Ketenzorg).
The 2_fhir_mp_include.xsl uses in its turn the ../../util/constants.xsl, ../../util/datetime.xsl, ../../util/uuid.xsl  which contains some generic stuff that can be reused over different types of conversions (ada_2_hl7, ada_2_fhir, hl7_2_ada, et cetera) and domains (such as Geboortezorg and Ketenzorg).

The folder 'ada_instance' contains sample ada instance files. The folder hl7_instance contains the result of the conversion for these sample files.

