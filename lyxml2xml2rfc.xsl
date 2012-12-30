<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    Version: 0.1
-->

<!--
    Copyright (c) 2012, Cryptonector, LLC.
    All rights reserved.
   
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
   
    - Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
   
    - Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the
      distribution.
   
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
    STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
    OF THE POSSIBILITY OF SUCH DAMAGE.
-->

<!DOCTYPE xsl:stylesheet [ ]>
<xsl:stylesheet version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="xml2rfc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:rfc="xml2rfc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:url="http://whatever/java/java.net.URLDecoder"
    xmlns:jxml="http://whatever/java/org.apache.commons.lang.StringEscapeUtils"
    exclude-result-prefixes="rfc"
    >

<!-- 
    This XSLT stylesheet applies to LyXML output and converts
    it into xml2rfc's input schema.
-->
<!--<xsl:import href="trim-simple.xsl"/>-->

<xsl:variable name="months">
    <m>January</m><m>February</m><m>March</m><m>April</m>
    <m>May</m><m>June</m><m>July</m><m>August</m>
    <m>September</m><m>October</m><m>November</m><m>December</m>
</xsl:variable>

<xsl:output method="xml" omit-xml-declaration="no"/>

<xsl:template match="/">
    <!-- Emit processing instructions -->
    <xsl:apply-templates select="//flex:PI"/>
    <xsl:apply-templates select="//*[starts-with(name(), 'flex:PI_')"/>

    <!-- Emit toc="yes" PI by default (but we could look for a 
         <inset:CommandInset CommandInset="toc" LatexCommand="tableofcontents">
         instead.
         -->
    <xsl:if test="not(//flex:PI_TOC) and
                  not(//flex:PI[starts-with(normalize-space(.), 'toc=')])">
        <xsl:processing-instruction name="rfc">
            <xsl:text>toc="yes"</xsl:text>
        </xsl:processing-instruction>
    </xsl:if>

    <!-- Emit symrefs="yes" PI by default -->
    <xsl:if test="not(//flex:PI_SymRefs) and
                  not(//flex:PI[starts-with(normalize-space(.), 'symrefs=')])">
        <xsl:processing-instruction name="rfc">
            <xsl:text>symrefs="yes"</xsl:text>
        </xsl:processing-instruction>
    </xsl:if>

    <!-- Emit the rfc element and its contents -->
    <xsl:apply-templates select="document"/>
</xsl:template>

<!-- Handle attributes of <rfc> -->
<!-- XXX Dang, we lose the case in custom inset names, so we must
     special-case docName and seriesNo :( -->
<xsl:template match="flex:DocName">
    <xsl:attribute name="docName"><xsl:value-of
            select="normalize-space(./layout:Plain)"/>
    </xsl:attribute>
</xsl:template>
<!-- XXX Should have used a custom inset name of Category -->
<xsl:template match="flex:IntendedStatus">
    <xsl:attribute name="category"><xsl:value-of
            select="normalize-space(./layout:Plain)"/>
    </xsl:attribute>
</xsl:template>
<xsl:template match="flex:SeriesNo">
    <xsl:attribute name="seriesNo"><xsl:value-of
            select="normalize-space(./layout:Plain)"/>
    </xsl:attribute>
</xsl:template>
<xsl:template match="flex:IPR or flex:Updates or flex:Obsoletes">
    <xsl:variable name="attrname" select="substring-after(local-name(), ':')"/>
    <xsl:attribute name="{$attrname}"><xsl:value-of
            select="normalize-space(./layout:Plain)"/>
    </xsl:attribute>
</xsl:template>

<xsl:template match="html">
    <!-- Emit DOCTYPE -->
    <xsl:text>&#xA;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE rfc SYSTEM "rfc2629.dtd" [</xsl:text>
    <xsl:text>&#xA;</xsl:text>

    <!-- Emit XML ENTITY declarations for bibxml references -->
    <xsl:for-each
        select="//flex:BibXML/layout:Plain/inset:CommandInset[@CommandInset='href' and not(starts-with(@target, 'file:'))]/@name">
        <!-- NOTE: For some reason moving this into templates causes the
             ENTITY generation to fail... -->
        <xsl:text disable-output-escaping="yes">
            &lt;!ENTITY </xsl:text>

        <!-- Entity name -->
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text disable-output-escaping="yes"> PUBLIC "" "</xsl:text>

        <!-- URL -->
        <xsl:value-of select="./@href"/>
        <xsl:text disable-output-escaping="yes">"&gt;&#xA;</xsl:text>
    </xsl:for-each>

    <!-- Emit XML ENTITY declarations for *local* bibxml references -->
    <xsl:for-each
        select="//flex:BibXML/layout:Plain/inset:CommandInset[starts-with(@target, 'file:')]/@name">
        <!-- NOTE: For some reason moving this into templates causes the
             ENTITY generation to fail... -->
        <xsl:text disable-output-escaping="yes">
            &lt;!ENTITY </xsl:text>

        <!-- Entity name -->
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text disable-output-escaping="yes"> SYSTEM "</xsl:text>

        <!-- URL -->
        <xsl:value-of select="url:decode(substring-after(./@href, 'file://'))"/>
        <xsl:text disable-output-escaping="yes">"&gt;&#xA;</xsl:text>
    </xsl:for-each>

    <!-- Emit DOCTYPE close -->
    <xsl:text disable-output-escaping="yes">&#xA;]&gt;&#xA;</xsl:text>

    <!-- Emit <rfc> element -->
    <xsl:element name="rfc">
        <!-- Handle attributes of <rfc> -->
        <xsl:apply-templates select="body//flex:*[matches(local-name(), '(DocName|IntendedStatus|IPR|Updates|Obsoletes|SeriesNo)')]"/>

        <!-- Emit <front> element -->
        <xsl:element name="front">
            <!-- Grab the title -->
            <xsl:element name="title">
                <!-- XXX Should we count() and make sure there's only
                     one flex:TitleAbbrev? -->
                <xsl:if test="//flex:TitleAbbrev">
                    <xsl:attribute name="abbrev"
                        select="normalize-space((//flex:TitleAbbrev)[0])"/>
                </xsl:if>
                <xsl:value-of select="./head/title"/>
            </xsl:element>

            <!-- Emit the <author> elements -->
            <xsl:apply-templates select="//layout:Author"/>

            <!-- Emit <date> -->
            <xsl:element name="date">
                <xsl:attribute name="month"
                    select="$months/rfc:m[number(month-from-dateTime(current-dateTime()))]"/>
                <xsl:attribute name="year"
                    select="year-from-dateTime(current-dateTime())"/>
            </xsl:element>

            <!-- Emit <area> and <workgroup> elements -->
            <xsl:apply-templates select=".//flex:[starts-with(local-name(), 'IETF')]"/>

            <!-- Emit <keyword> element -->
            <xsl:element name="keyword">
                <xsl:value-of select="normalize-space(.//flex:XML2RFCKeyword)"/>
            </xsl:element>

            <!-- Grab the abstract (should use apply-templates instead
                 of for-each...) -->
            <xsl:element name="abstract">
                <xsl:apply-templates select="//layout:Abstract"
                    mode="front"/>
            </xsl:element>
        </xsl:element>

        <!-- Process middle and back matter -->
        <xsl:apply-templates select="body"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:IETFArea">
    <xsl:element name="area">
        <xsl:value-of select="."/>
    </xsl:element>
</xsl:template>
<xsl:template match="flex:IETFWorkingGroup">
    <xsl:element name="workgroup">
        <xsl:value-of select="."/>
    </xsl:element>
</xsl:template>

<!-- Process middle and back matter -->
<xsl:template match="body">
    <!-- Middle matter (only top-level sections; the matching templates
         will recurse to get subsections and subsubsections). -->
    <xsl:element name="middle">
        <xsl:apply-templates select="h2[not(matches(span, '^[A-Z].*'))]" mode="midsect1"/>
    </xsl:element>

    <!-- Back matter -->
    <xsl:element name="back">

        <!-- References -->
        <xsl:apply-templates select="h2[not(matches(span, '^[A-Z].*'))]" mode="refsect1"/>

        <!-- Appendices, but don't include references since we've
             already handled those (just in case the references sections
             were made into appendices) -->
        <xsl:apply-templates
            select="h2[matches(span, '^[A-Z].*')]" mode="midsect1"/>
    </xsl:element>
</xsl:template>

<!-- We don't have any use for the style elements in xml2rfc -->
<xsl:template match="style"/>
<!-- xml2rfc has its own way of handling toc, see PIs -->
<xsl:template match="inset:CommandInset[@CommandInset='toc']"/>
<!-- Strip out things for the front matter that we handle above -->
<xsl:template match="layout:Title"/>
<xsl:template match="layout:Abstract"/>

<xsl:template match="layout:Abstract" mode="front">
    <xsl:element name="t">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<!-- Weird LyX quotes -->
<xsl:template match="Quotes[@Quotes='eld' or @Quotes='erd']">
    <xsl:text>"</xsl:text>
</xsl:template>

<!-- Plain paragraphs -->
<xsl:template match="layout:Standard">
    <xsl:choose>
        <xsl:when test="./inset:Tabular">
            <!-- Tables are generated inside an otherwise empty
                 layout:Standard.  We don't want to generate an
                 unnecessary <t></t> around the <texttable>.  -->
            <xsl:apply-templates select="./inset:Tabular/lyxtabular"/>
        </xsl:when>
        <xsl:when test="../layout:Enumerate or ../layout:Itemize or ../">
            <!-- Paragraphs in list items should generate vspace
                 elements but no t elements.  -->
                 <xsl:element name="vspace">
                     <xsl:attribute name="blankLines">1</xsl:attribute>
                 </xsl:element>
                 <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="t">
                <!-- Applies templates to the text() nodes and child elements in
                     order.  This is important.  Selecting the string-join() of
                     text() then applying templates to children would cause
                     <xref>s, <em>s, <a>s, and such to be added at the
                     end of the paragraphs, which would be incorrect.  -->
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Lists -->
<xsl:template match="layout:Itemize[not(preceding-sibling::layout:Itemize)]">
    <xsl:variable name="dot" value="."/>
    <!-- Put contiguous layout:Itemize elements into a bullet list -->
    <xsl:element name="list">
        <xsl:attribute name="style" select="symbols"/>
        <xsl:for-each-group
            select=". | following-sibling::layout:Itemize"
            group-adjacent="boolean(self::layout:Itemize) or boolean(self::deeper)">
            <xsl:if test="current-group()[1] is $dot">
                <xsl:apply-templates select="current-group()" mode="li">
            </xsl:if>
        </xsl:for-each-group>
    </xsl:element>
</xsl:template>
<xsl:template match="layout:Enumerate[not(preceding-sibling::layout:Enumerate)]">
    <xsl:variable name="dot" value="."/>
    <!-- Put contiguous layout:Enumerate elements into a numbered list -->
    <xsl:element name="list">
        <xsl:attribute name="style" select="numbers"/>
        <xsl:for-each-group
            select=". | following-sibling::layout:Enumerate"
            group-adjacent="boolean(self::layout:Enumerate) or boolean(self::deeper)">
            <xsl:if test="current-group()[1] is $dot">
                <xsl:apply-templates select="current-group()" mode="li">
            </xsl:if>
        </xsl:for-each-group>
    </xsl:element>
</xsl:template>
<xsl:template match="layout:Description[not(preceding-sibling::layout:Description)]">
    <xsl:variable name="dot" value="."/>
    <!-- Put contiguous layout:Enumerate elements into a numbered list -->
    <xsl:element name="list">
        <xsl:attribute name="style" select="hanging"/>
        <xsl:for-each-group
            select=". | following-sibling::layout:Description"
            group-adjacent="boolean(self::layout:Description) or boolean(self::deeper)">
            <xsl:if test="current-group()[1] is $dot">
                <xsl:apply-templates select="current-group()" mode="li">
            </xsl:if>
        </xsl:for-each-group>
    </xsl:element>
</xsl:template>
<xsl:template match="layout:deeper">
    <!-- There should only be list elements here.  If there's any
         standard layouts... they'll just screw things up.  As long as
         there's just list item child elements we'll get a nice nested
         list as a result of this. -->
    <xsl:apply-templates select="*"/>
</xsl:template>

<!-- List elements -->
<xsl:template mode="li" match="layout:*[local-name() = 'Itemize' or local-name = 'Enumerate']">
    <xsl:element name="t">
        <xsl:copy-of select="text()"/>
    </xsl:element>
</xsl:template>
<!-- Description lists require parsing out the freaking first text()
     node.  Argh.  This is really not satisfactory though.  -->
<xsl:template mode="li" match="layout:Description">
    <xsl:element name="t">
        <xsl:attribute name="hangText">
            <xsl:value-of select="substring-before(text()[1], ' ')"/>
        </xsl:attribute>
        <xsl:text><xsl:value-of select="substring-after(text()[1], ' ')"/></xsl:text>
        <xsl:copy-of select="(*|text()) except (text()[1])"/>
    </xsl:element>
</xsl:template>

<!-- XXX What was this about? XXX Remove? -->
<xsl:template match="text()[starts-with(., ']') or ends-with(., '[')]">
    <xsl:value-of select="replace(replace(., '\[$', ''), '^\]', '')"/>
</xsl:template>

<!-- crefs (editorial comments) -->
<xsl:template match="layout:RevisionRemark">
    <xsl:element name="t">
        <xsl:element name="cref">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<!-- xrefs to bibxml (citations) -->
<xsl:template match="flex:EntityXRef">
    <xsl:element name="xref">
        <xsl:attribute name="target">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- Emphasis (<spanx>) -->
<xsl:template match="em">
    <xsl:element name="spanx">
        <xsl:if test="emph">
            <xsl:attribute name="style" select="emph"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
    <xsl:text> </xsl:text>
</xsl:template>

<!-- Figures (we only really support ASCII figures) -->
<xsl:template match="inset:Float[@Float='figure']">
    <xsl:element name="t">
        <xsl:element name="figure">
            <xsl:attribute name="anchor"
                select="(./inset:CommandInset[@CommandInset='label']/@name)[1] or generate-id()"/>

            <xsl:attribute name="title"
                select="normalize-space(layout:Plain/inset:Caption/layout:Plain)"/>

            <!-- The actual figure.  No need to deal with escaping
                 (or, rather, treating the artwork as CDATA) because LyX
                 already takes care of it in its LyXHTML export
                 function.  -->
            <xsl:element name="artwork">
                <xsl:value-of select="div/pre"/>
            </xsl:element>
        </xsl:element>
    </xsl:element>
</xsl:template>

<!-- xrefs (internal cross-references) -->
<xsl:template match="a[@href and starts-with(@href, '#')]">
    <!-- We add a space here to avoid running this xref onto the end of
         the preceding text() node. -->
    <xsl:text> </xsl:text>
    <xsl:element name="xref">
        <xsl:attribute name="target">
            <xsl:value-of select="substring(./@href, 2)"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- erefs -->
<xsl:template match="inset:CommandInset[@CommandInset = 'ref']">
    <xsl:element name="eref">
        <xsl:attribute name="target">
            <xsl:value-of select="./@reference"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- Tables -->
<xsl:template match="table">
    <xsl:apply-templates select="tbody"/>
</xsl:template>
<xsl:template match="tbody">
    <xsl:element name="texttable">
        <!-- Anyways, so xml2rfc has no row element to contain column
             values, which is very strange and prevents one column value
             from spanning several columns, for example.  So first we
             generate column declarations (<ttcol> elements) for the
             columns (taken from the first row from the XHTML), then we
             generate column values (<c> elements) for all the <td>s
             from subsequent rows.  -->
        <!-- XXX This would probably be best done with apply-templates
             so that we can apply further templates as necessary. -->
        <xsl:for-each select='tr[position() = 1]/td/div'>
            <xsl:element name="ttcol">
                <xsl:apply-templates select="../@align"/>
                <!-- XXX Could this be an apply-templates?  Maybe...  -->
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="tr[position() > 1]/td/div">
            <xsl:element name="c">
                <!-- XXX Could this be an apply-templates?  Maybe...  -->
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:element>
</xsl:template>
<xsl:template match="@align">
    <xsl:attribute name="align">
        <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>

<!-- Sections -->

<xsl:template match="*[matches(local-name(), '^(Subsubs|Subs|S)ection')]" mode="midsect1">
    <xsl:variable name="cur_sect" select="current()"/>
    <xsl:if test="not(following-sibling::*[
            (preceding-sibling::*[matches(name(), '^(Subsubs|Subs|S)ection')])[last()] is $cur_sect
            ]/flex:BibXML or
            following-sibling::*[
            (preceding-sibling::*[matches(name(), '(Subsubs|Subs|S)ection')])[last()] is $cur_sect]/flex:EmbeddedBibXML)">
        <xsl:apply-templates select="current()" mode="midsect2"/>
    </xsl:if>
</xsl:template>

<xsl:template match="*[matches(name(), '^(Subsubs|Subs|S)ection') and ends-with(@class, 'section')]" mode="midsect2">

    <!-- N is the section depth -->
    <xsl:variable name="N" select="if (local-name() = 'Section') then 1
        else if (local-name() = 'Subsection') then 2 else 3"/>
    <xsl:variable name="thisSect" select="name()"/>
    <xsl:variable name="id" select="inset:CommandInset[@CommandInset='label']/@label"/>
    <!-- We refer to this <hN> in various XPath contexts below where
         current() will no longer be this <h2>, so we need to save it -->
    <xsl:variable name="cur_sect" select="current()"/>

    <xsl:element name="section">
        <!-- LyX sadly adds unnecessary newlines to section elements'
             text() nodes -->
        <xsl:attribute name="title"
            select="normalize-space(string-join(text(), ''))"/>

        <!-- Make sure there's an anchor -->
        <xsl:attribute name="anchor"
            select="if (string-length($id) > 0) then $id else generate-id()"/>

        <!-- Handle the contents of just this section.  Ask for all
             siblings of this <hN> where the nodes we're looking for are
             NOT hN, and their preceding <hN> is this one. -->
        <xsl:apply-templates
            select="(following-sibling::*[not(matches(name(), '^(Subsubs|Subs|S)ection')) and
                (preceding-sibling::*[matches(name(), '^(Subsubs|Subs|S)ection')])[last()] is $cur_sect])"/>

        <!-- Handle sub-sections of this section.  Ask for all sibling
             hNs of this hN where their preceding parent hN is
             this one.  -->
        <xsl:apply-templates
            select="following-sibling::*[matches(name(), '^(Subsubs|Subs|S)ection') and
                (preceding-sibling::*[name() = $thisSect])[last()] is $cur_sect and
                (substring-after(name(), 'h') cast as xs:integer = ($N + 1))
                ]"
            mode="midsect2"/>

    </xsl:element>
</xsl:template>

<!-- References -->

<xsl:template match="*[matches(name(), '^(Subsubs|Subs|S)ection') and ends-with(@class, 'section')]" mode="refsect1">
    <xsl:variable name="cur_sect" select="current()"/>
    <xsl:if test="following-sibling::layout:*[
            (preceding-sibling::*[matches(name(), '^(Subsubs|Subs|S)ection')])[last()] is $cur_sect
            ]/flex:BibXML or
            following-sibling::*[
            (preceding-sibling::*[matches(name(), '^(Subsubs|Subs|S)ection')])[last()] is $cur_sect
            ]/flex:EmbeddedBibXML">
        <xsl:apply-templates select="current()" mode="refsect2"/>
    </xsl:if>
</xsl:template>

<xsl:template match="*[matches(name(), '^(Subsubs|Subs|S)ection')]" mode="refsect2">

    <!-- N is the section depth -->
    <xsl:variable name="N" select="if (local-name() = 'Section') then 1
        else if (local-name() = 'Subsection') then 2 else 3"/>
    <xsl:variable name="thisSect" select="name()"/>
    <xsl:variable name="id" select="inset:CommandInset[@CommandInset='label']/@label"/>
    <xsl:variable name="cur_sect" select="current()"/>

    <xsl:element name="references">
        <xsl:attribute name="title"
            select="normalize-space(string-join(text(), ''))"/>
        <xsl:attribute name="anchor"
            select="if (string-length($id) > 0) then $id else generate-id()"/>

        <!-- Get the references -->
        <xsl:apply-templates
            select="(following-sibling::*[
                (preceding-sibling::*[matches(name(), '^h[0-9]')])[last()] is $cur_sect]/flex:BibXML/layout:Plain/inset:CommandInset)"/>
        <xsl:apply-templates
            select="(following-sibling::*[
                (preceding-sibling::*[matches(name(), '^h[0-9]')])[last()] is $cur_sect]/flex:EmbeddedBibXML)"/>

    </xsl:element>

    <!-- xml2rfc doesn't know support nested <references>, but that
         doesn't mean that we can't support nested references sections
         in LyX.  Note that this code is the same as for regular
         sections, except that it follows the <references> element. -->
    <xsl:apply-templates
        select="following-sibling::*[matches(name(), '^(Subsubs|Subs|S)ection') and
            (preceding-sibling::*[name() = $thisSect])[last()] is $cur_sect and
            (substring-after(name(), 'h') cast as xs:integer = ($N + 1))
            ]"
        mode="refsect2"/>
</xsl:template>

<!-- Emit processing instructions -->
<xsl:template match="flex:*[starts-with(local-name(), 'PI_')]">
    <xsl:processing-instruction name="rfc">
        <xsl:value-of select="replace(local-name(), '^PI_', '')"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>"</xsl:text>
    </xsl:processing-instruction>
</xsl:template>
<xsl:template match="flex:PI">
    <xsl:processing-instruction name="rfc">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:processing-instruction>
</xsl:template>

<!-- Emit references -->
<xsl:template
    match="inset:CommandInset[@CommandInset = 'href' and ends-with(@target, '.xml') and ../..[@local-name = 'BibXML']]">
    <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text disable-output-escaping="yes">;&#xA;</xsl:text>
</xsl:template>

<xsl:template
    match="flex:EmbeddedBibXML">
    <xsl:value-of disable-output-escaping="yes" select="./layout:Plain"/>
</xsl:template>

<!-- Author metadata templates (for the <author> elements) -->
<xsl:template match="flex:AuthorOrg">
    <xsl:element name='organization'>
        <xsl:choose>
            <xsl:when test="../flex:AuthorOrgAbbrev">
                <xsl:attribute name="abbrev">
                    <xsl:value-of select="normalize-space(../flex:AuthorOrgAbbrev/layout:Plain)"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="normalize-space(layout:Plain)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorAddrStreet">
    <xsl:element name='street'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorAddrCity">
    <xsl:element name='city'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorAddrRegion">
    <xsl:element name='region'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorAddrCode">
    <xsl:element name='code'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorAddrCountry">
    <!-- We don't want to have to nest insets for these things in LyX
         documents, but xml2rfc requires nesting, thus the use of ..
         here. -->
    <xsl:element name='postal'>
        <xsl:apply-templates select="../flex:AuthorAddrStreet"/>
        <xsl:apply-templates select="../flex:AuthorAddrCity"/>
        <xsl:apply-templates select="../flex:AuthorAddrRegion"/>
        <xsl:apply-templates select="../flex:AuthorAddrCode"/>
        <xsl:element name="country">
            <xsl:value-of select="normalize-space(./layout:Plain)"/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorPhone">
    <xsl:element name='phone'>
        <xsl:value-of select="normalize-space(./layout:Plain)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorURI">
    <xsl:element name='uri'>
        <xsl:value-of select="normalize-space(./layout:Plain)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="flex:AuthorEmailAddr">
    <xsl:element name='email'>
        <xsl:value-of select="normalize-space(./layout:Plain)"/>
    </xsl:element>
</xsl:template>

<!-- Process author data -->
<xsl:template match="layout:Author">
    <!-- Author element -->
    <xsl:element name='author'>
        <!-- Initials and surname attributes and various sub-elements...

             Try to be user-friendly by deriving the initials and
             surname from the fullname.

             XSLT conditionals are exceedingly verbose! :( -->
        <xsl:attribute name="initials">
            <xsl:choose>
                <xsl:when test="./flex:AuthorInitials/layout:Plain">
                    <xsl:value-of select="normalize-space(./flex:authorinitials/layout:Plain)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat(substring(normalize-space(string-join(text(), '')), 1, 1), '.')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="surname">
            <xsl:choose>
                <xsl:when test="./flex:authorsurname/layout:Plain">
                    <xsl:value-of select="normalize-space(./flex:authorsurname/layout:Plain)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="replace(normalize-space(normalize-space(string-join(text(), ''))), '^.* ', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="fullname">
            <xsl:value-of select="normalize-space(string-join(text(), ''))"/>
        </xsl:attribute>

        <!-- Organization element -->
        <xsl:apply-templates select=".//flex:authororg"/>

        <!-- Address element.  We try hard to avoid an empty address
             element.  It'd be so nice to have an attribute of
             xsl:element by which to say "don't output this element if
             it is empty"... :( -->
        <xsl:choose>
            <!-- Add an address element IFF there are either author
                 postal address elements, author phone number, author
                 URI, or author e-mail elements -->
            <xsl:when test=".//flex:AuthorEmailAddr |
                            .//flex:AuthorURI |
                            .//flex:AuthorPhone |
                            .//flex:AuthorAddrCountry">
                <xsl:element name='address'>
                    <!-- Add a postal element IFF there's a country name -->
                    <xsl:apply-templates select=".//flex:AuthorAddrCountry"/>
                    <!-- Add phone, email, uri elements -->
                    <xsl:apply-templates select=".//flex:AuthorEmailAddr"/>
                    <xsl:apply-templates select=".//flex:AuthorPhone"/>
                    <xsl:apply-templates select=".//flex:AuthorURI"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>

    </xsl:element>
</xsl:template>

</xsl:stylesheet>
