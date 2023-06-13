<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:x="com.elovirta.ooxml" version="2.0"
  exclude-result-prefixes="x xs"
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:cx="http://schemas.microsoft.com/office/drawing/2014/chartex"
  xmlns:cx1="http://schemas.microsoft.com/office/drawing/2015/9/8/chartex"
  xmlns:cx2="http://schemas.microsoft.com/office/drawing/2015/10/21/chartex"
  xmlns:cx3="http://schemas.microsoft.com/office/drawing/2016/5/9/chartex"
  xmlns:cx4="http://schemas.microsoft.com/office/drawing/2016/5/10/chartex"
  xmlns:cx5="http://schemas.microsoft.com/office/drawing/2016/5/11/chartex"
  xmlns:cx6="http://schemas.microsoft.com/office/drawing/2016/5/12/chartex"
  xmlns:cx7="http://schemas.microsoft.com/office/drawing/2016/5/13/chartex"
  xmlns:cx8="http://schemas.microsoft.com/office/drawing/2016/5/14/chartex"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:aink="http://schemas.microsoft.com/office/drawing/2016/ink"
  xmlns:am3d="http://schemas.microsoft.com/office/drawing/2017/model3d"
  xmlns:oel="http://schemas.microsoft.com/office/2019/extlst"
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
  xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
  xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
  xmlns:w16cex="http://schemas.microsoft.com/office/word/2018/wordml/cex"
  xmlns:w16cid="http://schemas.microsoft.com/office/word/2016/wordml/cid"
  xmlns:w16="http://schemas.microsoft.com/office/word/2018/wordml"
  xmlns:w16sdtdh="http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash"
  xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" w:val="D2E0657C">

  <xsl:import href="document.xsl"/>

  <xsl:variable name="doc" select="document(concat($template.dir, 'word/numbering.xml'))" as="document-node()?"/>

  <xsl:template match="/">
    <w:numbering>
      <xsl:for-each select="//@x:list-number">
        <xsl:choose>
          <xsl:when test="contains(../@class, ' topic/ol')">
            <xsl:call-template name="ol">
              <xsl:with-param name="number" select="."/>
              <xsl:with-param name="indent-start" select="xs:integer($indent-base)"/>
              <xsl:with-param name="intable" select="exists(ancestor::*[contains(@class, ' topic/entry ') or contains(@class, ' topic/stentry ') or contains(@class, ' topic/dlentry ') ])"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="ul">
              <xsl:with-param name="number" select="."/>
              <xsl:with-param name="indent-start" select="xs:integer($indent-base)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <!-- original numberings -->
      <xsl:copy-of select="$doc/w:numbering/w:abstractNum"/>
      <!-- list numbering -->
      <xsl:for-each select="//@x:list-number">
        <w:num w:numId="{.}">
          <w:abstractNumId w:val="{.}"/>
          <w:lvlOverride w:ilvl="0">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="1">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="2">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="3">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="4">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="5">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="6">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="7">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
          <w:lvlOverride w:ilvl="8">
            <w:startOverride w:val="1" />
          </w:lvlOverride>
        </w:num>
      </xsl:for-each>
      <!-- original numberings -->
      <xsl:copy-of select="$doc/w:numbering/w:num"/>
    </w:numbering>
  </xsl:template>
  
  <xsl:template name="ol">
    <xsl:param name="number" as="xs:string"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <xsl:param name="intable" as="xs:boolean"/>
    <xsl:apply-templates select="." mode="ol">
      <xsl:with-param name="number" select="$number"/>
      <xsl:with-param name="indent-start" select="$indent-start"/>
      <xsl:with-param name="intable" select="$intable"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="@* | node()" mode="ol">
    <xsl:param name="number"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <xsl:param name="intable" as="xs:boolean" select="false()"/>
    <w:abstractNum w:abstractNumId="{$number}">
      <xsl:choose>
        <xsl:when test="$intable">
          <xsl:for-each select="$doc/w:numbering/w:abstractNum[descendant::w:pStyle[@w:val='ItemStepinTable']]/*">
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$doc/w:numbering/w:abstractNum[descendant::w:pStyle[@w:val='Heading1']]/*">
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>     
    </w:abstractNum>
  </xsl:template>



  <!--xsl:template match="@* | node()" mode="ol">
    <xsl:param name="number"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <w:abstractNum w:abstractNumId="{$number}">
      <w:multiLevelType w:val="hybridMultilevel"/>
      <w:lvl w:ilvl="0">
        <w:start w:val="1"/>
        <w:numFmt w:val="decimal"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%1."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 1 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerLetter"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%2."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 2 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="2" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerRoman"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%3."/>
        <w:lvlJc w:val="right"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 3 * xs:integer($increment-base)}" w:hanging="180"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="3" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="decimal"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%4."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 4 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="4" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerLetter"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%5."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 5 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="5" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerRoman"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%6."/>
        <w:lvlJc w:val="right"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 6 * xs:integer($increment-base)}" w:hanging="180"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="6" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="decimal"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%7."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 7 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="7" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerLetter"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%8."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 8 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="8" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerRoman"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%9."/>
        <w:lvlJc w:val="right"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 9 * xs:integer($increment-base)}" w:hanging="180"/>
        </w:pPr>
      </w:lvl>
    </w:abstractNum>
  </xsl:template-->
  
  <xsl:template name="ul">
    <xsl:param name="number" as="xs:string"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <xsl:apply-templates select="." mode="ul">
      <xsl:with-param name="number" select="$number"/>
      <xsl:with-param name="indent-start" select="$indent-start"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="@* | node()" mode="ul">
    <xsl:param name="number"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <w:abstractNum w:abstractNumId="{$number}">
      <w:multiLevelType w:val="hybridMultilevel"/>
      <w:lvl w:ilvl="0">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 1 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="1" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="o"/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 2 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"
            w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="2" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 3 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Wingdings" w:hAnsi="Wingdings" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="3" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 4 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="4" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="o"/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 5 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"
            w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="5" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 6 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Wingdings" w:hAnsi="Wingdings" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="6" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 7 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="7" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="o"/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 8 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"
            w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="8" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 9 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Wingdings" w:hAnsi="Wingdings" w:hint="default"/>
        </w:rPr>
      </w:lvl>
    </w:abstractNum>
  </xsl:template>

</xsl:stylesheet>
