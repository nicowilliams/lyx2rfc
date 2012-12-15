<?xml version="1.0" encoding="UTF-8"?>

<!-- This is an XSL template for converting xml2rfc XML into LyX .lyx
     format.  THIS IS NOT EVEN REMOTELY FUNCTIONAL - it's just the
     beginnings of a sketch for such a thing.  The goal is to be able to
     import xml2rfc docs into LyX, edit them with LyX, then export again
     to xml2rfc using the lyx2rfc tool (and lyxhtml2xml2rfc.xsl XSL).
     -->

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
    exclude-result-prefixes="rfc"
    >

<!-- 
    This XSLT stylesheet applies to xml2rfc XML and converts to LyX
    native format.
-->

<xsl:variable name="months">
    <m>January</m><m>February</m><m>March</m><m>April</m>
    <m>May</m><m>June</m><m>July</m><m>August</m>
    <m>September</m><m>October</m><m>November</m><m>December</m>
</xsl:variable>

<xsl:output method="text" omit-xml-declaration="yes"/>

<xsl:template match="/">
    <!-- Emit boilerplate -->
    <xsl:call-template name="lyxBoilerPlate"/>

    <!-- Emit the LyX file -->
    <xsl:apply-templates select="rfc"/>
</xsl:template>

<xsl:template match="rfc">
    <xsl:apply-templates select="front"/>
    <xsl:apply-templates select="middle"/>
    <xsl:apply-templates select="back"/>
</xsl:template>

<xsl:template match="front">
    <xsl:apply-templates select="title"/>
    <!-- Emit processing instructions -->
    <!-- XXX implement -->
    <xsl:apply-templates select="author"/>
    <xsl:apply-templates select="area"/>
    <xsl:apply-templates select="keyword"/>
    <xsl:apply-templates select="abstract"/>
</xsl:template>

<xsl:template match="middle">
    <xsl:apply-templates select="section" mode="H2"/>
</xsl:template>

<xsl:template match="back">
    <xsl:apply-templates select="references"/>
    <xsl:apply-templates select="section" mode="notRefs"/>
</xsl:template>

<xsl:template match="section" mode="notRefs">
    <!-- Level of section -->
    <xsl:param name="h" select="'Section'"/>
    <!-- Output \begin_layout $h <CRLF> @title <CRLF> \end_layout -->
    <xsl:call-template name="begin_layout">
        <xsl:with-param name="layout" select="Section"/>
        <xsl:with-param name="content" select="@title"/>
    </xsl:call-template>

    <!-- Get section contents -->
    <xsl:call-template name="sectionBody"/>
    <!-- Recurse to get subsections -->
    <xsl:apply-templates select="section" mode="notRefs">
        <!-- Make $h into "Sub" + $h, like "Section" into "Subsection",
             and "Subsection" into "Subsubsection" -->
        <xsl:with-param name="h" select="concat('Sub', 's', substring-after($h, 'S'))">
    </xsl:apply-templates>
</xsl:template>

<xsl:template name="begin_layout">
    <xsl:param name="layout"/>
    <xsl:param name="contents"/>
    <xsl:text>&#xA;\begin_layout </xsl:text>
    <xsl:value-of select="$layout"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:value-of select="$contents"/>
    <xsl:text>&#xA;\end_layout </xsl:text>
</xsl:template>

<xsl:template name="sectionBody">
    <xsl:apply-templates select="*[name() = 't' or name() = 'texttable']"/>
</xsl:template>

<xsl:template match="t">
    <!-- Apply templates to text() and other nodes, like <list>s and
         such -->
    <xsl:apply-templates/>
</xsl:template>

<!-- Paragraph bodies -->
<xsl:template match="//t/text()">
    <xsl:call-template name="begin_layout">
        <xsl:with-param name="layout" select="Standard"/>
        <xsl:with-param name="content" select="."/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="lyxBoilerPlate">
    <xsl:text>
#LyX 2.0 created this file. For more info see http://www.lyx.org/
\lyxformat 413
\begin_document
\begin_header
\textclass docbook
\use_default_options true
\maintain_unincluded_children false
\begin_local_layout
Format 31

InsetLayout Flex:PI_Strict
    LyXType Custom
    HTMLTag div
    LabelString PI_Strict
End

InsetLayout Flex:PI
    LyXType Custom
    HTMLTag div
    LabelString PI
End

InsetLayout Flex:PI_SymRefs
    LyXType Custom
    HTMLTag div
    LabelString PI_SymRefs
End

InsetLayout Flex:PI_SortRefs
    LyXType Custom
    HTMLTag div
    LabelString PI_SortRefs
End

InsetLayout Flex:PI_TOC
    LyXType Custom
    HTMLTag div
    LabelString PI_TOC
End

InsetLayout Flex:PI_TOCIndent
    LyXType Custom
    HTMLTag div
    LabelString PI_TOCIndent
End

InsetLayout Flex:PI_TOCDepth
    LyXType Custom
    HTMLTag div
    LabelString PI_TOCDepth
End

InsetLayout Flex:PI_TOCNarrow
    LyXType Custom
    HTMLTag div
    LabelString PI_TOCNarrow
End

InsetLayout Flex:PI_TOCCompact
    LyXType Custom
    HTMLTag div
    LabelString PI_TOCCompact
End

InsetLayout Flex:PI_TOCAppendix
    LyXType Custom
    HTMLTag div
    LabelString PI_TOCAppendix
End

InsetLayout Flex:DocName
    LyXType Custom
    HTMLTag div
    LabelString DocName
End

InsetLayout Flex:IntendedStatus
    LyXType Custom
    HTMLTag div
    LabelString IntendedStatus
End

InsetLayout Flex:Updates
    LyXType Custom
    HTMLTag div
    LabelString Updates
End

InsetLayout Flex:Obsoletes
    LyXType Custom
    HTMLTag div
    LabelString Obsoletes
End

InsetLayout Flex:SeriesNo
    LyXType Custom
    HTMLTag div
    LabelString SeriesNo
End

InsetLayout Flex:RFCNumber
    LyXType Custom
    HTMLTag div
    LabelString RFCNumber
End

InsetLayout Flex:IPR
    LyXType Custom
    HTMLTag div
    LabelString IPR
End

InsetLayout Flex:IETFArea
    LyXType Custom
    HTMLTag div
    LabelString IETFArea
End

InsetLayout Flex:IETFWorkingGroup
    LyXType Custom
    HTMLTag div
    LabelString IETFWorkingGroup
End

InsetLayout Flex:XML2RFCKeyword
    LyXType Custom
    HTMLTag div
    LabelString XML2RFCKeyword
End

InsetLayout Flex:TitleAbbrev
    LyXType Custom
    HTMLTag div
    LabelString TitleAbbrev
End

InsetLayout Flex:AuthorRole
    LyXType Custom
    HTMLTag div
    LabelString AuthRole
End

InsetLayout Flex:AuthorInitials
    LyXType Custom
    HTMLTag div
    LabelString AuthInitials
End

InsetLayout Flex:AuthorSurname
    LyXType Custom
    HTMLTag div
    LabelString AuthSurname
End

InsetLayout Flex:AuthorOrg
    LyXType Custom
    HTMLTag div
    LabelString AuthOrg
End

InsetLayout Flex:AuthorOrgAbbrev
    LyXType Custom
    HTMLTag div
    LabelString AuthOrgAbbrev
End

InsetLayout Flex:AuthorEmailAddr
    LyXType Custom
    HTMLTag div
    LabelString AuthEmailAddr
End

InsetLayout Flex:AuthorAddrStreet
    LyXType Custom
    HTMLTag div
    LabelString AuthAddrStreet
End

InsetLayout Flex:AuthorAddrCity
    LyXType Custom
    HTMLTag div
    LabelString AuthAddrCity
End

InsetLayout Flex:AuthorAddrRegion
    LyXType Custom
    HTMLTag div
    LabelString AuthAddrRegion
End

InsetLayout Flex:AuthorAddrCode
    LyXType Custom
    HTMLTag div
    LabelString AuthAddrCode
End

InsetLayout Flex:AuthorAddrCountry
    LyXType Custom
    HTMLTag div
    LabelString AuthAddrCountry
End

InsetLayout Flex:EntityXRef
    LyXType Custom
    HTMLTag div
    LabelString EntityXRef
End

InsetLayout Flex:BibXML
    LyXType Custom
    HTMLTag div
    LabelString BibXML
End
\end_local_layout
\language english
\language_package default
\inputencoding auto
\fontencoding global
\font_roman cmr
\font_sans cmss
\font_typewriter cmtt
\font_default_family ttdefault
\use_non_tex_fonts false
\font_sc false
\font_osf false
\font_sf_scale 100
\font_tt_scale 100

\graphics default
\default_output_format default
\output_sync 0
\bibtex_command default
\index_command default
\paperfontsize default
\spacing single
\use_hyperref false
\papersize default
\use_geometry false
\use_amsmath 1
\use_esint 1
\use_mhchem 1
\use_mathdots 1
\cite_engine basic
\use_bibtopic false
\use_indices false
\paperorientation portrait
\suppress_date false
\use_refstyle 1
\index Index
\shortcut idx
\color #008000
\end_index
\secnumdepth 3
\tocdepth 3
\paragraph_separation indent
\paragraph_indentation default
\quotes_language english
\papercolumns 1
\papersides 1
\paperpagestyle default
\tracking_changes false
\output_changes false
\html_math_output 0
\html_css_as_file 0
\html_be_strict false
\end_header

    </xsl:text>
</xsl:template>

</xsl:stylesheet>
