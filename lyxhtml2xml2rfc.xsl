<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE xsl:stylesheet [
        <!ENTITY nbsp "&#160;">
    ]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- 
    Version: 0.1
    (c) Cryptonector, LLC
-->

<!-- 
    This XSLT stylesheet applies to LyX native XHTML output and converts
    it into xml2rfc's input schema.
-->
<!--<xsl:import href="trim-simple.xsl"/>-->

<xsl:variable name="months">
    <m>January</m><m>February</m><m>March</m><m>April</m>
    <m>May</m><m>June</m><m>July</m><m>August</m>
    <m>September</m><m>October</m><m>November</m><m>December</m>
</xsl:variable>

<!-- XXX Add cdata-section-elements="artwork" so the CDATA for that is
     automatically generated! -->
<xsl:output method="xml" omit-xml-declaration="no"/>

<xsl:template match="/">
    <!-- Emit processing instructions -->
    <xsl:apply-templates select="//div[starts-with(@class, 'flex_pi_')]"/>
    <xsl:apply-templates select="//div[starts-with(@class, 'flex_pi')]"/>
    <!-- Emit the rfc element and its contents -->
    <xsl:apply-templates select="html"/>
</xsl:template>

<xsl:template match="html">
    <!-- Emit DOCTYPE -->
    <xsl:text>&#xA;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE rfc SYSTEM "rfc2629.dtd" [</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <!-- Emit XML ENTITY declarations for bibxml references -->
    <xsl:for-each select="//div[@class = 'bibliography']/div[@class = 'flex_referenceentity']">
        <xsl:text disable-output-escaping="yes">
            &lt;!ENTITY </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text disable-output-escaping="yes"> PUBLIC '' '</xsl:text>
        <xsl:value-of select="parent::div/a[ends-with(@href, '.xml')]/@href"/>
        <xsl:text disable-output-escaping="yes">'&gt;&#xA;</xsl:text>
    </xsl:for-each>
    <!-- Emit DOCTYPE close -->
    <xsl:text disable-output-escaping="yes">&#xA;]&gt;&#xA;</xsl:text>
    <xsl:element name="rfc">
        <xsl:attribute name="docName"><xsl:value-of
                select="normalize-space(body//div[@class='flex_docname']/div)"/>
        </xsl:attribute>
        <xsl:attribute name="ipr"><xsl:value-of
                select="normalize-space(body//div[@class='flex_ipr']/div)"/>
        </xsl:attribute>
        <!--<xsl:attribute name="category"><xsl:value-of
                select="normalize-space(body//div[@class='flex_intendedstatus']/div)"/>
        </xsl:attribute>-->

        <front>
            <!-- Grab the title -->
            <xsl:element name="title">
                <xsl:value-of select="./head/title"/>
            </xsl:element>
            <!-- Grab the authors -->
            <xsl:apply-templates select="//div[@class='author']/div[@class='author_item']"/>
            <!-- date -->
            <xsl:element name="date">
                <xsl:attribute name="month">
                    <xsl:value-of
                        select="$months/m[number(month-from-dateTime(current-dateTime()))]"/>
                </xsl:attribute>
                <xsl:attribute name="year">
                    <xsl:value-of
                        select="year-from-dateTime(current-dateTime())"/>
                </xsl:attribute>
            </xsl:element>
            <area><xsl:value-of select="normalize-space(.//div[@class='flex_ietfarea'])"/></area>
            <workgroup>NETWORK WORKING GROUP</workgroup>
            <keyword><xsl:value-of select="normalize-space(.//div[@class='flex_xml_rfckeyword'])"/></keyword>
            <!-- Grab the abstract -->
            <xsl:element name="abstract">
                <xsl:for-each select="//div[@class='abstract_item']">
                    <xsl:element name="t">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </front>
        <xsl:apply-templates select="body"/>
    </xsl:element>
</xsl:template>

<xsl:template match="body">
    <!-- Handle only top-level sections -->
    <xsl:element name="middle">
        <xsl:apply-templates
            select="h2[not(starts-with(normalize-space(text()[3]), 'References')) and
                        not(starts-with(normalize-space(text()[3]), 'Normative References')) and
                        not(starts-with(normalize-space(text()[3]), 'Informative References'))
                        and not(matches(span, '^[A-Z].*'))]"/>
    </xsl:element>
    <!-- Now back matter -->
    <xsl:element name="back">
        <xsl:apply-templates
            select="h2[starts-with(normalize-space(text()[3]), 'References') or
            starts-with(normalize-space(text()[3]), 'Normative References') or
            starts-with(normalize-space(text()[3]), 'Informative References')]"/>
        <xsl:apply-templates
            select="h2[matches(span, '^[A-Z].*') and
            not(starts-with(normalize-space(text()[3]), 'References')) and
            not(starts-with(normalize-space(text()[3]), 'Normative References')) and
            not(starts-with(normalize-space(text()[3]), 'Informative References'))]"/>
    </xsl:element>
</xsl:template>

<!-- We don't have any use for the style elements in xml2rfc -->
<xsl:template match="style"/>
<!-- XXX Remap this into a toc directive -->
<xsl:template match="div[@class='toc']"/>
<!-- Strip out things for the front matter that we handle above -->
<xsl:template match="h1[@class='title']"/>
<xsl:template match="div[@class='abstract']"/>

<!-- LyXHTML uses span elements for things we don't care about, like
     section numbering.  Also ignore the table of contents and
     automatically-generated anchors.  -->
<xsl:template match="span"/>
<xsl:template match="div[@class='toc']"/>
<xsl:template match="a[starts-with(@id, 'magicparlabel-')]"/>

<!-- Plain paragraphs -->
<xsl:template match="div[@class='standard']">
    <xsl:element name="t">
        <xsl:value-of select="string-join(text()/normalize-space(), ' ')"/>
        <!--<xsl:call-template name="trim">
            <xsl:with-param name="x" select="string-join(text())"/>
        </xsl:call-template>-->
        <xsl:apply-templates select="child::*[name() != 'table']"/><!-- Limit to 'a' elements! -->
    </xsl:element>
    <xsl:apply-templates select="child::table"/>
</xsl:template>

<!-- Lists! -->
<xsl:template match="ul">
    <xsl:element name="t">
        <list style="symbols">
            <xsl:apply-templates select="li"/>
        </list>
    </xsl:element>
</xsl:template>

<xsl:template match="ol">
    <xsl:element name="t">
        <list style="numbers">
            <xsl:apply-templates select="li"/>
        </list>
    </xsl:element>
</xsl:template>

<xsl:template match="li">
    <xsl:element name="t">
        <xsl:value-of select="."/>
        <!-- Multi-paragraph list items -->
        <xsl:for-each select="div[@class = 'standard']">
            <vspace blankLines='1'/>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:element>
</xsl:template>

<!-- Description lists -->
<xsl:template match="dl">
    <xsl:element name="t">
        <list style="hanging">
            <xsl:apply-templates select="dt"/>
        </list>
    </xsl:element>
</xsl:template>

<xsl:template match="dt">
    <xsl:element name="t">
        <xsl:attribute name="hangText">
            <xsl:value-of select="."/>
        </xsl:attribute>
        <!-- Grab the immediately following element, which should be a
             dd element, but we don't check that it is!  We should, but
             don't for not knowing how to ask for the first following
             sibling that is a dd element.  XXX add this check! -->
        <xsl:value-of select="(following-sibling::*)[1]"/>
    </xsl:element>
</xsl:template>

<!-- Figures -->
<xsl:template match="div[@class='float float-figure']">
    <xsl:element name="t">
        <xsl:element name="figure">
            <xsl:attribute name="anchor">
                <xsl:value-of select="div/a/@id"/>
            </xsl:attribute>
            <xsl:element name="artwork">
                <xsl:text disable-output-escaping='yes'>&lt;![CDATA[
    </xsl:text>
                <xsl:value-of select="div/pre"/>
                <xsl:text disable-output-escaping='yes'>
    ]]&gt;</xsl:text>
            </xsl:element>
            <xsl:element name="postamble">
                <xsl:value-of select="div/div[@class='float-caption float-caption-figure']"/>
            </xsl:element>
        </xsl:element>
    </xsl:element>
</xsl:template>

<!-- xrefs -->
<xsl:template match="a[@href and starts-with(@href, '#') and not(starts-with(@href, '#key-'))]"><!-- workaround for LyX bug -->
    <xsl:element name="xref">
        <xsl:attribute name="target">
            <xsl:value-of select="substring(./@href, 2)"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- erefs -->
<xsl:template match="a[@href and not(starts-with(@href, '#'))]">
    <xsl:element name="eref">
        <xsl:attribute name="target">
            <xsl:value-of select="./@href"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- Tables -->
<xsl:template match="table">
    <xsl:apply-templates select="tbody"/>
</xsl:template>

<xsl:template match="tbody">
    <xsl:element name="texttable">
        <xsl:for-each select='tr[position() = 1]/td/div'>
            <xsl:element name="ttcol">
                <!-- XXX add alignment and other options! -->
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="tr[position() > 1]/td/div">
            <xsl:element name="c">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:element>
</xsl:template>

<!-- Sections -->

<xsl:template match="h2[starts-with(@class, 'section') and
    not(starts-with(normalize-space(text()[3]), 'References')) and
    not(starts-with(normalize-space(text()[3]), 'Normative References')) and
    not(starts-with(normalize-space(text()[3]), 'InformativeReferences'))]">
    <xsl:element name="section">
        <xsl:attribute name="title">
            <xsl:value-of select="concat(normalize-space(text()[2]), normalize-space(text()[3]))"/>
        </xsl:attribute>
        <xsl:attribute name="anchor">
            <xsl:choose>
                <xsl:when test="string-length(a[not(starts-with(@id, 'magicparlabel-'))]/@id) > 0">
                    <xsl:value-of select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <!-- Some variables needed to help select sub-sets of following
             siblings (an "in sequence" operator would make this
             simpler, and would allow us to move this into a common,
             callable template) -->
        <xsl:variable name="num-siblings" select="count(following-sibling::*)"/>
        <xsl:variable name="next-hN"
            select="((following-sibling::*[contains(@class, 'section') and (name() = 'h2' or name() = 'h3' or name() = 'h4')]) |
            following-sibling::*[$num-siblings])[1]"/>
        <xsl:variable name="end-hN"
            select="((following-sibling::h2[contains(@class, 'section')]) |
            following-sibling::*[$num-siblings])[1]"/>

        <!-- Handle the contents of this section -->
        <xsl:for-each select="following-sibling::*[. &lt;&lt; $next-hN]">
            <!-- Debug xsl:text's and xsl:value-of's
            <xsl:text>
h2: handling section content node tag: </xsl:text>
            <xsl:value-of select="name()"/> -->
            <xsl:apply-templates select="."/>
        </xsl:for-each>

        <!-- Handle sub-sections of this section -->
        <xsl:apply-templates select="following-sibling::h3[. &lt;&lt; $end-hN]"/>
    </xsl:element>
</xsl:template>

<xsl:template match="h3[starts-with(@class, 'subsection')]">
    <xsl:element name="section">
        <xsl:attribute name="title">
            <xsl:value-of select="concat(normalize-space(text()[2]), normalize-space(text()[3]))"/>
        </xsl:attribute>
        <xsl:attribute name="anchor">
            <xsl:choose>
                <xsl:when test="string-length(a[not(starts-with(@id, 'magicparlabel-'))]/@id) > 0">
                    <xsl:value-of select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <xsl:variable name="num-siblings" select="count(following-sibling::*)"/>
        <xsl:variable name="next-hN"
            select="((following-sibling::*[contains(@class, 'section') and (name() = 'h2' or name() = 'h3' or name() = 'h4')]) |
            following-sibling::*[$num-siblings])[1]"/>
        <xsl:variable name="end-hN"
            select="((following-sibling::*[contains(@class, 'section') and (name() = 'h2' or name() = 'h3')]) |
            following-sibling::*[$num-siblings])[1]"/>

        <!-- Handle the contents of this section -->
        <xsl:for-each select="following-sibling::*[. &lt;&lt; $next-hN]">
            <!-- Debug xsl:text's and xsl:value-of's
            <xsl:text>
h3: handling section content node tag: </xsl:text>
            <xsl:value-of select="name()"/> -->
            <xsl:apply-templates select="."/>
        </xsl:for-each>

        <!-- Handle sub-sections of this section -->
        <xsl:apply-templates select="following-sibling::h4[. &lt;&lt; $end-hN]"/>
    </xsl:element>
</xsl:template>

<xsl:template match="h4[starts-with(@class, 'subsubsection')]">
    <xsl:element name="section">
        <xsl:attribute name="title">
            <xsl:value-of select="concat(normalize-space(text()[2]), normalize-space(text()[3]))"/>
        </xsl:attribute>
        <xsl:attribute name="anchor">
            <xsl:choose>
                <xsl:when test="string-length(a[not(starts-with(@id, 'magicparlabel-'))]/@id) > 0">
                    <xsl:value-of select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <xsl:variable name="num-siblings" select="count(following-sibling::*)"/>
        <xsl:variable name="next-hN"
            select="((following-sibling::*[contains(@class, 'section') and (name() = 'h2' or name() = 'h3' or name() = 'h4')]) |
            following-sibling::*[$num-siblings])[1]"/>
        <xsl:variable name="end-hN"
            select="((following-sibling::*[contains(@class, 'section') and (name() = 'h2' or name() = 'h3' or name() = 'h4')]) |
            following-sibling::*[$num-siblings])[1]"/>

        <!-- Handle the contents of this section -->
        <xsl:for-each select="following-sibling::*[. &lt;&lt; $next-hN]">
            <!-- Debug xsl:text's and xsl:value-of's
            <xsl:text>
h4: handling section content node tag: </xsl:text>
            <xsl:value-of select="name()"/> -->
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:element>
</xsl:template>

<!-- References -->

<xsl:template match="h2[starts-with(normalize-space(text()[3]), 'References') or
            starts-with(normalize-space(text()[3]), 'Normative References') or
            starts-with(normalize-space(text()[3]), 'Informative References')]">
    <xsl:element name="references">
        <xsl:attribute name="title">
            <xsl:value-of select="concat(normalize-space(text()[2]), normalize-space(text()[3]))"/>
        </xsl:attribute>
        <!--
        <xsl:attribute name="anchor">
            <xsl:choose>
                <xsl:when test="string-length(a[not(starts-with(@id, 'magicparlabel-'))]/@id) > 0">
                    <xsl:value-of select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        -->

        <xsl:variable name="num-siblings" select="count(following-sibling::*)"/>
        <xsl:variable name="next-hN"
            select="((following-sibling::*[contains(@class, 'section') and (name() = 'h2' or name() = 'h3' or name() = 'h4')]) |
            following-sibling::*[$num-siblings])[1]"/>
        <xsl:variable name="end-hN"
            select="((following-sibling::h2[contains(@class, 'section')]) |
            following-sibling::*[$num-siblings])[1]"/>

        <!-- Handle the contents of this section -->
        <xsl:for-each select="following-sibling::div[@class = 'bibliography' and . &lt;&lt; $next-hN]/div[@class = 'flex_referenceentity']">
            <xsl:apply-templates select="."/>
        </xsl:for-each>

        <!-- Sorry, no sub-sections for references, though there have
             been I-Ds and RFCs with such sub-sections.  Make this a
             TODO. -->
    </xsl:element>
</xsl:template>

<!-- Emit processing instructions -->
<xsl:template match="div[starts-with(@class, 'flex_pi_')]">
    <xsl:processing-instruction name="rfc">
        <xsl:value-of select="replace(@class, '^flex_pi_', '')"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>"</xsl:text>
    </xsl:processing-instruction>
</xsl:template>
<xsl:template match="div[@class = 'flex_pi']">
    <xsl:processing-instruction name="rfc">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:processing-instruction>
</xsl:template>

<!-- Emit references -->
<xsl:template match="div[@class = 'flex_referenceentity']">
    <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text disable-output-escaping="yes">;&#xA;</xsl:text>
</xsl:template>

<xsl:template match="div[@class='flex_authororg']">
    <xsl:element name='organization'>
        <xsl:choose>
            <xsl:when test="../div[@class = 'flex_authororgabbrev']">
                <xsl:attribute name="abbrev">
                    <xsl:value-of select="normalize-space(../div[@class = 'flex_authororgabbrev']/div)"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="normalize-space(div)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrstreet']">
    <xsl:element name='street'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrcity']">
    <xsl:element name='city'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrregion']">
    <xsl:element name='region'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrcode']">
    <xsl:element name='code'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrcountry']">
    <xsl:element name='postal'>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrstreet']"/>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrcity']"/>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrregion']"/>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrcode']"/>
        <xsl:element name="country">
            <xsl:value-of select="normalize-space(./div)"/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authorphone']">
    <xsl:element name='phone'>
        <xsl:value-of select="./div"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoruri']">
    <xsl:element name='uri'>
        <xsl:value-of select="./div"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoremailaddr']">
    <xsl:element name='email'>
        <xsl:value-of select="./div"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='author_item']">
    <!-- Author element -->
    <xsl:element name='author'>
        <!-- Initials and surname attributes and various sub-elements
             -->
        <xsl:attribute name="initials">
            <xsl:value-of select="normalize-space(./div[@class='flex_authorinitials']/div)"/>
        </xsl:attribute>
        <xsl:attribute name="surname">
            <xsl:value-of select="normalize-space(./div[@class='flex_authorsurname']/div)"/>
        </xsl:attribute>
        <xsl:attribute name="fullname">
            <xsl:value-of select="normalize-space(text()[2])"/>
        </xsl:attribute>
        <!-- Organization element -->
        <xsl:apply-templates select=".//div[@class='flex_authororg']"/>

        <!-- Address element -->
        <xsl:choose>
            <!-- Add an address element IFF there are either author
                 postal address elements, author phone number, author
                 URI, or author e-mail elements -->
            <xsl:when test=".//div[@class='flex_authoremailaddr'] |
                            .//div[@class='flex_authoruri'] |
                            .//div[@class='flex_authorphone'] |
                            .//div[@class='flex_authoraddrcountry']">
                <xsl:element name='address'>
                    <!-- Add a postal element IFF there's a country name -->
                    <xsl:apply-templates select=".//div[@class='flex_authoraddrcountry']"/>
                    <!-- Add phone, email, uri elements -->
                    <xsl:apply-templates select=".//div[@class='flex_authoremailaddr']"/>
                    <xsl:apply-templates select=".//div[@class='flex_authorphone']"/>
                    <xsl:apply-templates select=".//div[@class='flex_authoruri']"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>

    </xsl:element>
</xsl:template>

</xsl:stylesheet>
