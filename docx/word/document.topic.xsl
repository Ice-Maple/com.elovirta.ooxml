<?xml version="1.0" encoding="UTF-8"?>
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
               xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
               xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
               xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
               xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
               xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
               xmlns:opentopic="http://www.idiominc.com/opentopic"
               xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
               xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main"
               xmlns:x="com.elovirta.ooxml"
               exclude-result-prefixes="x xs dita-ot opentopic opentopic-index ot-placeholder"
               version="2.0">

  <xsl:param name="image.dir"/>
  <!-- FIXME this should be xs:integer -->
  <xsl:param name="indent-base" as="xs:string?" select="string((x:get-style-indent('Normal'), 0)[1])"/>
  <!--xsl:param name="indent-base" as="xs:string?" select="string((x:get-style-indent('BodyText'), 0)[1])"/-->
  
  <!-- FIXME this should be xs:integer -->
  <xsl:param name="increment-base" select="'312'"/>

  <xsl:variable name="auto-number" select="true()" as="xs:boolean"/>

  <xsl:key name="id" match="*[@id]" use="@id"/>
  <xsl:key name="topic-id"
           match="*[@id][contains(@class, ' topic/topic ')] |
           ot-placeholder:*[@id]"
           use="@id"/>

  <!--xsl:template match="*[contains(@class, ' topic/entry ') or
    contains(@class, ' topic/stentry ') or
    contains(@class, ' topic/dt ') or
    contains(@class, ' topic/dd ')]"
    mode="block-style">
    <w:ind w:left="0"/>
  </xsl:template-->

  <xsl:template match="w:pgNumType" mode="body-section">
    <xsl:param name="overrides" as="attribute()*" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@* except @w:start" mode="#current"/>
      <xsl:if test="exists($overrides)">
        <xsl:copy-of select="$overrides"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="node() | @*" mode="body-section" priority="-10">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- block -->

  <xsl:template match="node()" mode="block-style" priority="-10">
    <xsl:apply-templates select="." mode="block-style.default"/>
  </xsl:template>
  
  <xsl:template match="node()" mode="block-style.default">
    <xsl:variable name="table_head" as="xs:boolean" select="exists(ancestor::*[contains(@class, ' topic/thead ') or contains(@class, ' topic/sthead ') or contains(@class, 'topic/dt ')])"/>
    <xsl:variable name="table_text" as="xs:boolean" select="exists(ancestor::*[contains(@class, ' topic/tbody ') or contains(@class, ' topic/strow ') or contains(@class, ' topic/dd ')])"/>
    <xsl:choose>
      <xsl:when test="$table_head">
        <w:pStyle w:val="TableHeading"/>
      </xsl:when>
      <xsl:when test="$table_text">
        <w:pStyle w:val="TableText"/>
      </xsl:when>
      <xsl:otherwise>
        <w:pStyle w:val="BodyText"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="body-section" as="element()*">
    <w:p>
      <w:pPr>
        <xsl:for-each select="$sectPr">
          <xsl:apply-templates select="." mode="body-section">
            <xsl:with-param name="overrides" as="attribute()*" select="()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </w:pPr>
    </w:p>
  </xsl:variable>

  <xsl:template match="*[contains(@class, ' topic/topic ')]" name="topic">
    <xsl:comment>Topic <xsl:value-of select="@id"/></xsl:comment>
    <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>    
    <xsl:apply-templates select="*[contains(@class, ' topic/shortdesc ')] | *[contains(@class, ' topic/abstract ')]"/>
    <xsl:apply-templates select="*[contains(@class, ' topic/body ')]"/>
    <xsl:apply-templates select="*[contains(@class, ' topic/related-links ')]"/>
    <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"/>
    <xsl:if test="empty(parent::*[contains(@class, ' topic/topic ')])">
      <xsl:copy-of select="$body-section"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/body ')]" name="body">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/bodydiv ')]" name="bodydiv">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/abstract ')]" name="abstract">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:variable name="bookmark-prefix.ref" select="'_Ref'" as="xs:string"/>
  <xsl:variable name="bookmark-prefix.toc" select="'_Toc'" as="xs:string"/>
  <xsl:variable name="bookmark-prefix.num" select="'_Num'" as="xs:string"/>
  <xsl:variable name="bookmark-prefix.note" select="'_Note'" as="xs:string"/>
  
  <xsl:function name="x:bookmark-name" as="xs:string">
    <xsl:param name="prefix" as="xs:string"/>
    <xsl:param name="node" as="element()"/>
    
    <xsl:variable name="name" select="concat($prefix, x:generate-id($node))"/>
    <xsl:if test="string-length($name) gt 40">
      <xsl:message terminate="yes">FATAL: Bookmark <xsl:value-of select="$name"/> longer than 40 characters</xsl:message>
    </xsl:if>
    <xsl:value-of select="$name"/>
  </xsl:function>
  
  <xsl:template name="start-bookmark">
    <xsl:param name="node" select=".[@id]" as="element()?"/>
    <xsl:param name="type" as="xs:string?" select="()"/>
    <xsl:comment>id <xsl:value-of select="$node/@id"/></xsl:comment>
    <xsl:if test="exists($node)">
      <w:bookmarkStart w:id="ref_{$type}{x:generate-id($node)}" w:name="{x:bookmark-name(concat($bookmark-prefix.ref, $type), $node)}"/>
      <w:bookmarkStart w:id="toc_{$type}{x:generate-id($node)}" w:name="{x:bookmark-name(concat($bookmark-prefix.toc, $type), $node)}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="end-bookmark">
    <xsl:param name="node" select=".[@id]" as="element()?"/>
    <xsl:param name="type" as="xs:string?" select="()"/>
    <xsl:if test="exists($node)">
      <w:bookmarkEnd w:id="ref_{$type}{x:generate-id($node)}"/>
      <w:bookmarkEnd w:id="toc_{$type}{x:generate-id($node)}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="start-bookmark-number">
    <xsl:param name="node" select=".[@id]" as="element()?"/>
    <xsl:param name="type" as="xs:string?" select="()"/>
    <xsl:if test="exists($node)">
      <w:bookmarkStart w:id="num_{$type}{x:generate-id($node)}" w:name="{x:bookmark-name(concat($bookmark-prefix.num, $type), $node)}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="end-bookmark-number">
    <xsl:param name="node" select=".[@id]" as="element()?"/>
    <xsl:param name="type" as="xs:string?" select="()"/>
    <xsl:if test="exists($node)">
      <w:bookmarkEnd w:id="num_{$type}{x:generate-id($node)}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/topic ')]/
    *[contains(@class, ' topic/title ')]"
    name="topic.title">
    <xsl:variable name="depth" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])" as="xs:integer"/>
    <xsl:if test="$depth eq 1">
      <w:p>
        <w:r>
          <w:br w:type="page"/>
        </w:r>
      </w:p>
    </xsl:if>
    <w:p>
      <w:pPr>
        <xsl:apply-templates select="." mode="block-style"/>
      </w:pPr>
      <!-- OXYGEN PATCH FOR EXM-43514-->
      <xsl:call-template name="start-bookmark-number">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <xsl:call-template name="start-bookmark">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <xsl:apply-templates select="." mode="numbering"/>
      <xsl:apply-templates/>
      <xsl:call-template name="end-bookmark">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <!-- OXYGEN PATCH FOR EXM-43514-->
      <xsl:call-template name="end-bookmark-number">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
    </w:p>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]" mode="block-style">
    <xsl:variable name="depth" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])" as="xs:integer"/>
    <w:pStyle w:val="Heading{$depth}"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]/
                        *[contains(@class, ' topic/title ')]"
                mode="numbering">
    <xsl:if test="$generate-header-number and exists(../@x:header-number)">
      <xsl:call-template name="start-bookmark-number">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <w:r>
        <w:t>
          <xsl:value-of select="../@x:header-number"/>
        </w:t>
      </w:r>
      <xsl:call-template name="end-bookmark-number">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <w:r>
        <w:tab/>
      </w:r>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')]" name="sectiondiv">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/section ')]" name="section">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/section ')]/*[contains(@class, ' topic/title ')] |
                       *[contains(@class, ' topic/example ')]/*[contains(@class, ' topic/title ')]"
                name="section.title">
    <xsl:param name="contents" as="node()*">
      <xsl:apply-templates/>
    </xsl:param>
    <xsl:param name="style">
      <xsl:apply-templates select="." mode="block-style"/>
    </xsl:param>
    <xsl:call-template name="start-bookmark">
      <xsl:with-param name="node" select=".." as="element()"/>
    </xsl:call-template>
    <w:p>
      <xsl:if test="exists($style)">
        <w:pPr>
          <xsl:copy-of select="$style"/>
        </w:pPr>  
      </xsl:if>
      <xsl:copy-of select="$contents"/>
    </w:p>
    <xsl:call-template name="end-bookmark">
      <xsl:with-param name="node" select=".." as="element()"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/section ')]/*[contains(@class, ' topic/title ')] |
                       *[contains(@class, ' topic/example ')]/*[contains(@class, ' topic/title ')]"
                mode="block-style"
                name="block-style-section.title"
                as="element()*">
    <w:pStyle w:val="Heading5"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/example ')]">
    <xsl:if test="empty(*[contains(@class, ' topic/title ')])">
     <xsl:call-template name="section.title">
       <xsl:with-param name="contents">
         <w:r>
           <w:t>
            <xsl:call-template name="getVariable">
              <xsl:with-param name="id" select="'task_example'"/>
            </xsl:call-template>
           </w:t>
         </w:r>
       </xsl:with-param>
       <xsl:with-param name="style">
         <xsl:call-template name="block-style-section.title"/>
       </xsl:with-param>
     </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/figgroup ')]" name="figgroup">
    <xsl:apply-templates select="*"/>
  </xsl:template>
    
  <xsl:template match="*[contains(@class, ' topic/fig ')]" name="fig">
    <xsl:if test="empty(*[contains(@class, ' topic/title ')])">
      <xsl:call-template name="start-bookmark"/>
    </xsl:if>
    <xsl:apply-templates select="*"/>
    <xsl:if test="empty(*[contains(@class, ' topic/title ')])">
      <xsl:call-template name="end-bookmark"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')]"
                name="fig.title">
    <w:p>
      <w:pPr>
        <xsl:apply-templates select="." mode="block-style"/>
      </w:pPr>
      <xsl:call-template name="start-bookmark">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <w:r>
        <w:t>
         <xsl:call-template name="getVariable">
           <xsl:with-param name="id" select="'Figure'"/>
         </xsl:call-template>
       </w:t>
      </w:r>
      <w:r>
        <w:t>
          <xsl:attribute name="xml:space">preserve</xsl:attribute>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'figure-number-separator'"/>
          </xsl:call-template>
        </w:t>
      </w:r>
      <xsl:call-template name="start-bookmark-number">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <xsl:variable name="number" as="xs:string">
        <xsl:number count="*[contains(@class, ' topic/fig ')]" level="any"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$auto-number">
          <w:fldSimple w:instr=" SEQ Figure \* ARABIC ">
            <w:r>
              <w:rPr>
                <w:noProof/>
              </w:rPr>
              <w:t>
                <xsl:copy-of select="$number"/>
              </w:t>
            </w:r>
          </w:fldSimple>
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <w:rPr>
              <w:noProof/>
            </w:rPr>
            <w:t>
              <xsl:copy-of select="$number"/>  
            </w:t>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="end-bookmark-number">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <xsl:call-template name="end-bookmark">
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <w:r>
        <w:t xml:space="preserve">: </w:t>
      </w:r>
      <xsl:apply-templates/>
    </w:p>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')]" mode="block-style">
    <w:pStyle w:val="Caption"/>
    <w:keepNext/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/shortdesc ')]" name="shortdesc">
    <xsl:call-template name="p"/>
  </xsl:template>
    
  <xsl:template name="check-table-entry">
    <xsl:variable name="styles" as="node()*">
      <xsl:apply-templates select="." mode="block-style"/>
    </xsl:variable>
    <xsl:if test="exists($styles)">
      <w:pPr>
        <xsl:copy-of select="$styles"/>
      </w:pPr>
    </xsl:if>
  </xsl:template>
    
  <!-- For any block that can appear as in list item content -->
  <xsl:template name="generate-block-style">
    <xsl:variable name="root" select="(ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' topic/fig ')][1], /*)[1]" as="element()?" />
    <xsl:variable name="ancestor-lis" select="ancestor::*[contains(@class, ' topic/li ')][. >> $root]" as="element()*"/>
    <xsl:variable name="intable" as="xs:boolean" select="exists(ancestor::*[contains(@class, ' topic/entry ') or contains(@class, ' topic/stentry ') or contains(@class, ' topic/dlentry ') ])"/>
    <xsl:variable name="ul" as="xs:boolean" select="contains(../../@class, 'topic/ul') and contains(../@class, 'topic/li')"/>
    <xsl:variable name="stepsection" as="xs:boolean" select="contains(../@class, 'task/stepsection')"/>
    <xsl:variable name="styles" as="node()*">
      <xsl:apply-templates select="." mode="block-style"/>
    </xsl:variable>
    <w:pPr>
      <xsl:copy-of select="$styles"/>
      <xsl:choose>
        <xsl:when test="exists($ancestor-lis)">
          <xsl:variable name="is-first" as="xs:boolean">
            <xsl:variable name="parent-li" select="$ancestor-lis[position() eq last()]/*[1]" as="element()?"/>
            <xsl:variable name="parents-until-li" select="ancestor-or-self::*[. >> $parent-li]" as="element()*"/>
            <xsl:sequence select="every $e in $parents-until-li satisfies empty($e/preceding-sibling::*)"/>
          </xsl:variable>
          <xsl:variable name="depth" as="xs:integer">
            <xsl:apply-templates select="." mode="block-depth"/>
          </xsl:variable>
          <xsl:comment>depth <xsl:value-of select="$depth"/>
          </xsl:comment>
          <xsl:if test="not($ul or $stepsection)">
            <xsl:choose>
              <xsl:when test="$is-first">
                <w:numPr>
                  <xsl:choose>
                    <xsl:when test="$intable">
                      <w:ilvl w:val="{$depth}"/>
                    </xsl:when>
                    <xsl:when test="exists(ancestor::*[contains(@class, ' task/step ')])">
                      <w:ilvl w:val="{$depth + 5}"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <w:ilvl w:val="{$depth + 6}"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <w:numId w:val="{ancestor::*[@x:list-number][1]/@x:list-number}"/>
                </w:numPr>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$intable">
                    <w:ind w:left="{x:get-indent($depth - 1)}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <w:ind w:left="{x:get-indent($depth)}"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </w:pPr>
  </xsl:template>
  
  <xsl:function name="x:get-indent" as="xs:integer">
    <xsl:param name="depth" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$depth lt 0">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="xs:integer($indent-base) + xs:integer($increment-base) * $depth"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:function>
  

  <xsl:template match="*" mode="block-depth" as="xs:integer">
    <!--xsl:choose>
      <xsl:when test="contains(@class, ' topic/tgroup ')">
        <xsl:variable name="root" select="/*[1]"  as="element()?" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="root" select="(ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' topic/fig ')][1], /*)[1]" as="element()?" />
      </xsl:otherwise>
    </xsl:choose-->
    <xsl:variable name="root" select="(ancestor::*[contains(@class, ' topic/tgroup ') or contains(@class, ' topic/simpletable ') or contains(@class, ' topic/fig ')][1], /*)[1]" as="element()?" />
    <xsl:variable name="ancestor-lis" select="ancestor::*[contains(@class, ' topic/li ')][. >> $root]" as="element()*"/>
    <xsl:variable name="ul-lists" select="ancestor-or-self::*[contains(@class, ' topic/ul ')][. >> $root]" as="element()*"/>
    <xsl:variable name="ol-lists" select="ancestor-or-self::*[contains(@class, ' topic/ol ')][. >> $root]" as="element()*"/>  
    <xsl:variable name="depth" select="count($ul-lists) + count($ol-lists)" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="count($ol-lists) gt 0">
        <xsl:sequence select="$depth - 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$depth"/>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/p ')]" name="p" priority="20">
    <!--OXYGEN PATCH FOR #58-->
    <xsl:param name="applyTemplates" select="true()"/>
    <xsl:param name="prefix" as="node()*" select="()"/>
    <xsl:param name="step" select="false()"/>
    <w:p>
      <!--xsl:call-template name="check-table-entry"/-->
      <!--tanxl PATCH-->
      <xsl:variable name="has_id" select="exists(@id)" as="xs:boolean"/>
      <xsl:variable name="is_cmd" select="(contains(@class, ' task/cmd ')) and (exists(../@id))" as="xs:boolean"/>
      <w:pPr><xsl:comment>has_id: <xsl:value-of select="@id"/></xsl:comment></w:pPr>
      <xsl:call-template name="generate-block-style"/>
      <xsl:choose>
        <xsl:when test="$is_cmd">
          <xsl:call-template name="start-bookmark">
            <xsl:with-param name="node" select=".." as="element()"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$has_id">
          <xsl:call-template name="start-bookmark">
            <xsl:with-param name="node" select="." as="element()"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="exists($prefix)">
        <xsl:copy-of select="$prefix"/>
      </xsl:if>
      <!--OXYGEN PATCH FOR #58-->
      <xsl:if test="$applyTemplates">
        <xsl:apply-templates/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$is_cmd">
          <xsl:call-template name="end-bookmark">
            <xsl:with-param name="node" select=".." as="element()"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$has_id">
          <xsl:call-template name="end-bookmark">
            <xsl:with-param name="node" select="." as="element()"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </w:p>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/pre ')]" name="pre">
    <xsl:param name="prefix" as="node()*" select="()"/>
    <w:p>
      <xsl:call-template name="generate-block-style"/>
      <xsl:apply-templates/>
    </w:p>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, 'topic/pre ')]" mode="block-style">
    <w:pStyle w:val="HTMLPreformatted"/>
    <xsl:variable name="depth" as="xs:integer">
      <xsl:apply-templates select="." mode="block-depth"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="exists(ancestor::*[contains(@class, ' topic/entry ') or contains(@class, ' topic/stentry ') or contains(@class, ' topic/dlentry ') ])">
        <w:ind w:left="{x:get-indent($depth - 1)}"/>
      </xsl:when>
      <xsl:otherwise>
        <w:ind w:left="{x:get-indent($depth)}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
   
  <xsl:template match="*[contains(@class, ' topic/lines ')]" name="lines">
    <w:p>
      <xsl:call-template name="generate-block-style"/>
      <xsl:apply-templates/>
    </w:p>
  </xsl:template>
      
  <xsl:template match="*[contains(@class, ' topic/image ')][@placement = 'inline' or empty(@placement)]" name="image.inline">
    <xsl:param name="styles" as="element()*" tunnel="yes">
      <xsl:apply-templates select="." mode="inline-style"/>
    </xsl:param>
    <xsl:variable name="image.url" select="concat($input.dir.url, @href)" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="exists(@dita-ot:image-height) or unparsed-text-available($image.url)">    
        <!-- Units are English metric units: 1 EMU = 1 div 914400 in = 1 div 360000 cm -->
        <xsl:variable name="width" as="xs:integer?">
          <xsl:if test="@dita-ot:image-width">
            <xsl:sequence select="x:to-emu(@dita-ot:image-width, @dita-ot:horizontal-dpi)"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="height" as="xs:integer?">
          <xsl:if test="@dita-ot:image-height">
            <xsl:sequence select="x:to-emu(@dita-ot:image-height, @dita-ot:vertical-dpi)"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="size" as="xs:integer*"
                      select="if (exists($width) and exists($height))
                               then x:scale-to-max-box($width, $height)
                              else ()"/>
        <xsl:variable name="nofig" select="not(exists(ancestor::*[contains(@class, ' topic/fig ')]))" as="xs:boolean"/>
        <xsl:if test="$nofig">
          <xsl:call-template name="start-bookmark">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </xsl:if>
        <w:r>
          <xsl:if test="exists($styles)">
            <w:rPr>
              <xsl:copy-of select="$styles"/>
            </w:rPr>
          </xsl:if>
          <w:drawing>
           <wp:inline distT="0" distB="0" distL="0" distR="0">
             <xsl:if test="exists($size[1]) and exists($size[2])">
               <wp:extent cx="{$size[1]}" cy="{$size[2]}"/>  
             </xsl:if>
             <wp:effectExtent l="0" t="0" r="0" b="0"/>
             <wp:docPr id="1" name="Picture 1"/>
             <wp:cNvGraphicFramePr>
               <a:graphicFrameLocks noChangeAspect="1"/>
             </wp:cNvGraphicFramePr>
             <a:graphic>
               <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                 <pic:pic>
                   <pic:nvPicPr>
                     <pic:cNvPr id="0">
                       <xsl:attribute name="name">
                         <xsl:text>media/</xsl:text>
                         <xsl:choose>
                           <xsl:when test="ends-with(@href, '.svg')">
                             <xsl:variable name="fileName">
                               <xsl:choose>
                               <!--EXM-44025 Use only last part of href path.-->
                                 <xsl:when test="contains(@href, '/')">
                                   <xsl:value-of select="tokenize(@href, '/')[last()]"/>                    
                                 </xsl:when>
                                 <xsl:otherwise>
                                   <xsl:value-of select="@href"/>
                                 </xsl:otherwise>
                               </xsl:choose>
                             </xsl:variable>
                             <xsl:value-of select="replace($fileName, '\.svg$', '.emf')"/>
                           </xsl:when>
                           <xsl:otherwise>
                             <xsl:value-of select="@href"/>
                           </xsl:otherwise>
                         </xsl:choose>
                       </xsl:attribute>
                     </pic:cNvPr>
                     <pic:cNvPicPr/>
                   </pic:nvPicPr>
                   <pic:blipFill>
                     <a:blip r:embed="rId{@x:image-number}">
                       <a:extLst>
                         <a:ext uri="{{28A0092B-C50C-407E-A947-70E740481C1C}}">
                           <a14:useLocalDpi val="0"/>
                         </a:ext>
                       </a:extLst>
                     </a:blip>
                     <a:stretch>
                       <a:fillRect/>
                     </a:stretch>
                   </pic:blipFill>
                   <pic:spPr>
                     <a:xfrm>
                       <a:off x="0" y="0"/>
                       <xsl:if test="exists($width) and exists($height)">
                         <a:ext cx="{$width}" cy="{$height}"/>  
                       </xsl:if>
                     </a:xfrm>
                     <a:prstGeom prst="rect">
                       <a:avLst/>
                     </a:prstGeom>
                   </pic:spPr>
                 </pic:pic>
               </a:graphicData>
             </a:graphic>
           </wp:inline>
         </w:drawing>
       </w:r>
       <xsl:if test="$nofig">
          <xsl:call-template name="end-bookmark">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:t>
            <xsl:text>Image </xsl:text>
            <xsl:value-of select="@href"/>
            <xsl:text> missing</xsl:text>
          </w:t>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="x:scale-to-max-box" as="xs:integer+">
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="height" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$width le $max-image-width and $height le $max-image-height">
        <xsl:sequence select="($width, $height)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="scale" select="min(($max-image-width div $width, $max-image-height div $height))" as="xs:double"/>
        <!--xsl:message>INFO: Scale graphic by <xsl:value-of select="$scale"/></xsl:message-->
        <xsl:sequence select="(xs:integer($width * $scale), xs:integer($height * $scale))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:variable name="max-image-width" select="17 * 360000" as="xs:integer"/>
  <xsl:variable name="max-image-height" select="22 * 360000" as="xs:integer"/>
  
  <xsl:template match="*[contains(@class, ' topic/image ')][@placement = 'break']" name="image.break">
    <w:p>
      <!--xsl:call-template name="check-table-entry"/-->
      <xsl:call-template name="generate-block-style"/>
      <xsl:call-template name="image.inline"/>
    </w:p>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/image ')][@placement = 'break']" mode="block-style">
    <xsl:if test="exists(@align)">
      <w:jc w:val="{@align}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/dl ')]" name="dl">
    <w:tbl>
      <xsl:variable name="styles" as="node()*">
        <xsl:apply-templates select="." mode="block-style"/>
      </xsl:variable>
      <xsl:if test="exists($styles)">
        <w:tblPr>
          <xsl:copy-of select="$styles"/>
        </w:tblPr>
      </xsl:if>
      <w:tblGrid>
        <w:gridCol/>
        <w:gridCol/>
      </w:tblGrid>
      <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]"/>
    </w:tbl>
  </xsl:template>

  <!--TANXL PATCHED-->
  <xsl:template match="*[contains(@class, ' topic/dl ')]" mode="block-style">
    <xsl:variable name="depth" as="xs:integer">
      <xsl:apply-templates select="." mode="block-depth"/>
    </xsl:variable>
    <w:tblLayout w:type="autofit"/>
    <w:tblStyle w:val="Tablenohead"/>
    <!--w:tblStyle w:val="TableGrid"/-->
    <w:tblW w:w="0" w:type="auto"/>
    <w:tblInd w:w="{x:get-indent($depth)}" w:type="dxa"/>
    <w:tblLook w:val="04A0"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/dlentry ')]">
    <w:tr>
      <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]"/>
      <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]"/>
    </w:tr>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/dt ')]">
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <w:p>
        <xsl:call-template name="start-bookmark"/>
        <xsl:apply-templates/>
        <xsl:call-template name="end-bookmark"/>
      </w:p>
    </w:tc>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/dd ')]">
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <xsl:apply-templates select="*"/>
    </w:tc>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/ul ')]">
    <xsl:call-template name="start-bookmark"/>
    <xsl:apply-templates select="*[contains(@class, ' topic/li ')]"/>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/ol ')]">
    <xsl:call-template name="start-bookmark"/>
    <xsl:apply-templates select="*[contains(@class, ' topic/li ')]"/>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sl ')]">
    <xsl:call-template name="start-bookmark"/>
    <xsl:apply-templates select="*[contains(@class, ' topic/sli ')]"/>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/ul ')]/*[contains(@class, ' topic/li ')]">
    <xsl:call-template name="start-bookmark"/>
    <xsl:apply-templates select="*"/>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/li ')]/*" mode="block-style">
    <w:pStyle w:val="ListParagraph"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/ul ')]/*[contains(@class, ' topic/li ')]/*[1]" priority="10" mode="block-style">
    <xsl:variable name="break" as="element()"
      select="ancestor::*[contains(@class, ' topic/topic ') or contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ')][1]"/>
    <!--xsl:variable name="depth" as="xs:integer"
      select="count(ancestor::*[contains(@class, ' topic/ul ') or contains(@class, ' topic/ol ')][. >> $break])"/-->
    <xsl:variable name="instep" as="xs:boolean" select="exists(ancestor::*[contains(@class, ' task/step ')])"/>
    <xsl:variable name="depth" as="xs:integer">
        <xsl:apply-templates select="." mode="block-depth"/>
      </xsl:variable>
    <!--xsl:variable name="depth" as="xs:integer" select="if ($instep) then $dp -1 else $dp"/-->
    <xsl:variable name="intable" as="xs:boolean" select="exists(ancestor::*[contains(@class, ' topic/entry ') or contains(@class, ' topic/stentry ') or contains(@class, ' topic/dlentry ')])"/>
    <w:pStyle w:val="ListParagraph">
      <xsl:attribute name="w:val">
        <xsl:choose>
          <xsl:when test="$intable">
            <xsl:text>ItemListinTable</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>ItemList</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!--xsl:if test="$depth gt 1"-->
        <xsl:if test="$depth gt 1">
          <xsl:value-of select="$depth"/>
        </xsl:if>
      </xsl:attribute>
    </w:pStyle>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/ol ')]/*[contains(@class, ' topic/li ')]">
    <xsl:call-template name="start-bookmark"/>
    <xsl:apply-templates select="*"/>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
    
  <xsl:template match="*[contains(@class, ' topic/ol ')]/*[contains(@class, ' topic/li ')]/*[1]" mode="block-style" priority="10">
    <xsl:variable name="break" as="element()"
      select="ancestor::*[contains(@class, ' topic/topic ') or contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ')][1]"/>
    <!--xsl:variable name="depth" as="xs:integer"
      select="count(ancestor::*[contains(@class, ' topic/ul ') or contains(@class, ' topic/ol ')][. >> $break])"/-->
    <!--xsl:variable name="depth" as="xs:integer">
      <xsl:apply-templates select="." mode="block-depth"/>
    </xsl:variable-->
    <xsl:variable name="depth" as="xs:integer"
      select="count(ancestor::*[contains(@class, ' topic/ol ')][. >> $break])"/>
    <xsl:variable name="stepsection" as="xs:boolean" select="contains(../@class, 'task/stepsection')"/>
    <xsl:variable name="intable" as="xs:boolean" select="exists(ancestor::*[contains(@class, ' topic/entry ') or contains(@class, ' topic/stentry ') or contains(@class, ' topic/dlentry ')])"/>
    <w:pStyle w:val="ListParagraph">
      <!--xsl:attribute name="w:val">
        <xsl:text>ListNumber</xsl:text>
        <xsl:if test="$depth gt 1">
          <xsl:value-of select="$depth"/>
        </xsl:if>
      </xsl:attribute-->
      <xsl:attribute name="w:val">
        <xsl:choose>
          <xsl:when test="$intable">
            <xsl:text>ItemStepinTable</xsl:text>
          </xsl:when>
          <xsl:when test="$stepsection">
            <xsl:text>Caption</xsl:text>
          </xsl:when>
          <xsl:when test="($instep = 'yes') and contains(@class, ' task/cmd ') and contains(../@class, ' task/step ')">
            <xsl:text>INStep</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>ItemStep</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$depth gt 1 and not($stepsection)">
          <xsl:value-of select="$depth"/>
        </xsl:if>
      </xsl:attribute>
    </w:pStyle>
  </xsl:template>
    
  <xsl:template match="*[contains(@class, ' topic/itemgroup ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sli ')]">
    <xsl:call-template name="start-bookmark"/>
    <xsl:apply-templates select="*"/>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/note ')]">
    <xsl:call-template name="start-bookmark"/>
    <xsl:variable name="prefix" as="node()*">
      <xsl:apply-templates select="." mode="prefix"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="*[1][contains(@class, ' topic/p ')]">
        <xsl:apply-templates select="*[1]">
          <xsl:with-param name="prefix" select="$prefix"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="*[position() gt 1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="p">
          <xsl:with-param name="prefix" select="$prefix"/>
          <!--OXYGEN PATCH FOR #58-->
          <xsl:with-param name="applyTemplates" select="false()"/>
        </xsl:call-template>
        <xsl:apply-templates select="*"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/note ')]" mode="prefix">
    <w:r>
      <w:rPr>
        <w:caps/>
        <w:b w:val="true"/>
      </w:rPr>
      <w:t>
        <xsl:variable name="type" select="x:note-type(.)" as="xs:string"/>
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="concat(upper-case(substring($type, 1, 1)),
                                                   substring($type, 2))"/>
        </xsl:call-template>
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'ColonSymbol'"/>
        </xsl:call-template>
        <!--xsl:text>:</xsl:text-->
      </w:t>
      <!--w:tab/-->
      <w:t>
        <xsl:attribute name="xml:space">preserve</xsl:attribute>
        <xsl:text> </xsl:text>
      </w:t>
    </w:r>
  </xsl:template>
  
  <xsl:function name="x:note-type" as="xs:string">
    <xsl:param name="note" as="element()"/>
    <xsl:choose>
      <xsl:when test="$note/@type = 'other' and $note/@othertype">
        <xsl:value-of select="$note/@othertype"/>
      </xsl:when>
      <xsl:when test="empty($note/@type)">
        <xsl:text>note</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$note/@type"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--xsl:template match="*[contains(@class, ' topic/note ')]" mode="block-style">
    <w:pStyle w:val="Note"/>
  </xsl:template-->
  
  <!--xsl:template match="*[contains(@class, ' topic/li ')]//*[contains(@class, ' topic/note ')]" mode="block-style" priority="10">
    <w:pStyle w:val="ListNote"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/note ')]//*[contains(@class, ' topic/li ')]//*" mode="block-style">
    <w:pStyle w:val="ListNote"/>
  </xsl:template-->
    
  <!-- Glossary -->
    
  <xsl:template match="*[contains(@class, ' glossgroup/glossgroup ')]" name="glossgroup">
    <xsl:variable name="depth" as="xs:integer">
      <xsl:apply-templates select="." mode="block-depth"/>
    </xsl:variable>
    <xsl:call-template name="start-bookmark"/>
    <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
    <w:tbl>
      <xsl:variable name="styles" as="node()*">
        <xsl:apply-templates select="." mode="block-style"/>
      </xsl:variable>
      <xsl:if test="exists($styles)">
        <w:tblPr>
          <xsl:copy-of select="$styles"/>
        </w:tblPr>
      </xsl:if>
      <w:tblGrid>
        <w:gridCol/>
        <w:gridCol/>
      </w:tblGrid>
      <xsl:apply-templates select="*[contains(@class, ' glossentry/glossentry ')]"/>
    </w:tbl>
    <xsl:call-template name="end-bookmark"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' glossgroup/glossgroup ')]" mode="block-style">
    <xsl:variable name="depth" as="xs:integer">
      <xsl:apply-templates select="." mode="block-depth"/>
    </xsl:variable>
    <w:tblLayout w:type="autofit"/>
    <w:tblStyle w:val="TableGrid"/>
    <w:tblW w:w="0" w:type="auto"/>
    <w:tblInd w:w="{x:get-indent($depth)}" w:type="dxa"/>
    <w:tblLook w:val="04A0"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' glossentry/glossentry ')]" name="glossentry">
    <w:tr>
      <!--xsl:apply-templates select="*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossAlt ')]/*[contains(@class, ' glossentry/glossAbbreviation ')]"/-->
      <xsl:apply-templates select="*[contains(@class, ' glossentry/glossterm ')]"/>
      <xsl:apply-templates select="*[contains(@class, ' glossentry/glossdef ')]"/>
    </w:tr>
  </xsl:template>
  
  <!-- Fallback for ungrouped glossary entries -->
  <xsl:template match="*[contains(@class, ' glossentry/glossentry ')][empty(parent::*[contains(@class, ' glossgroup/glossgroup ')])]" priority="10">
    <w:tbl>
      <xsl:variable name="styles" as="node()*">
        <xsl:apply-templates select="." mode="block-style"/>
      </xsl:variable>
      <xsl:if test="exists($styles)">
        <w:tblPr>
          <xsl:copy-of select="$styles"/>
        </w:tblPr>
      </xsl:if>
      <w:tblGrid>
        <w:gridCol/>
        <w:gridCol/>
      </w:tblGrid>
      <xsl:call-template name="glossentry"/>      
    </w:tbl>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' glossentry/glossterm ')]" priority="10">
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
        <xsl:apply-templates select="." mode="block-style"/>
      </w:tcPr>
      <w:p>
        <xsl:call-template name="start-bookmark">
          <xsl:with-param name="node" select=".."/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="end-bookmark">
          <xsl:with-param name="node" select=".."/>
        </xsl:call-template>
      </w:p>
    </w:tc>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' glossentry/glossAbbreviation ')]">
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <w:p>
        <xsl:call-template name="start-bookmark"/>
        <xsl:apply-templates/>
        <xsl:call-template name="end-bookmark"/>
      </w:p>
    </w:tc>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' glossentry/glossdef ')]" priority="10">
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
        <xsl:apply-templates select="." mode="block-style"/>
      </w:tcPr>
      <xsl:apply-templates select="*"/>
    </w:tc>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' glossentry/glossterm ')]" mode="block-style" priority="10">
    <w:b w:val="true"/>
  </xsl:template> 
  
  <!-- inline -->
  
  <xsl:template match="node()" mode="inline-style" priority="-10"/>
  
  <xsl:template match="text()">
    <xsl:param name="styles" as="element()*" tunnel="yes">
      <xsl:apply-templates select="ancestor::*" mode="inline-style"/>
    </xsl:param>
    <w:r>
      <xsl:if test="exists($styles)">
        <w:rPr>
          <xsl:copy-of select="$styles"/>
        </w:rPr>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="contains(., '&#x2011;')">
          <xsl:for-each select="tokenize(., '&#x2011;')">
            <xsl:if test="position() ne 1">
              <w:noBreakHyphen/>
            </xsl:if>
            <w:t>
              <xsl:value-of select="."/>
            </w:t>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <w:t>
            <xsl:value-of select="."/>
          </w:t>
        </xsl:otherwise>
      </xsl:choose>
    </w:r>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/pre ')]//text()">
    <xsl:variable name="styles" as="element()*">
      <xsl:apply-templates select="ancestor::*" mode="inline-style"/>
    </xsl:variable>
    <xsl:for-each select="tokenize(., '\n')">
      <xsl:if test="position() ne 1">
        <w:r>
          <w:br/>
        </w:r>
      </xsl:if>
      <w:r>
        <xsl:if test="exists($styles)">
          <w:rPr>
            <xsl:copy-of select="$styles"/>
          </w:rPr>
        </xsl:if>
        <w:t>
          <xsl:value-of select="replace(., ' ', '&#xA0;')"/>
        </w:t>
      </w:r>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/lines ')]//text()">
    <xsl:variable name="styles" as="element()*">
      <xsl:apply-templates select="ancestor::*" mode="inline-style"/>
    </xsl:variable>
    <xsl:for-each select="tokenize(., '\n')">
      <xsl:if test="position() ne 1">
        <w:r>
          <w:br/>
        </w:r>
      </xsl:if>
      <w:r>
        <xsl:if test="exists($styles)">
          <w:rPr>
            <xsl:copy-of select="$styles"/>
          </w:rPr>
        </xsl:if>
        <w:t>
          <xsl:value-of select="."/>
        </w:t>
      </w:r>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/fn ')]">
    <w:r>
      <w:rPr>
        <w:rStyle w:val="FootnoteReference"/>
      </w:rPr>
      <xsl:apply-templates select="." mode="x:get-footnote-reference"/>
    </w:r>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/fn ')]" mode="block-style">
    <w:pStyle w:val="FootnoteText"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/fn ')]" mode="x:get-footnote-reference">
    <w:bookmarkStart w:id="note_{x:generate-id(.)}" w:name="{x:bookmark-name($bookmark-prefix.note, .)}"/>
    <w:footnoteReference w:id="{@x:fn-number}"/>
    <w:bookmarkEnd w:id="note_{x:generate-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/draft-comment ')]">
    <xsl:choose>
      <xsl:when test="x:block-content(..)">
        <w:commentReference w:id="{@x:draft-comment-number}"/>
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="CommentReference"/>
          </w:rPr>
          <w:commentReference w:id="{@x:draft-comment-number}"/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/draft-comment ')]" mode="block-style">
    <w:pStyle w:val="CommentText"/>
  </xsl:template> 
  
  <xsl:template match="processing-instruction('oxy_comment_start')">
    <xsl:if test="$debug">
      <xsl:variable name="attributes" as="element()">
        <res>
          <xsl:apply-templates select="." mode="x:parse-pi"/>
        </res>
      </xsl:variable>
      <w:commentRangeStart w:id="{$attributes/@draft-comment-number}"/>
      <xsl:choose>
        <xsl:when test="x:block-content(..)">
          <w:commentReference w:id="{$attributes/@draft-comment-number}"/>
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <w:rPr>
              <w:rStyle w:val="CommentReference"/>
            </w:rPr>
            <w:commentReference w:id="{$attributes/@draft-comment-number}"/>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="processing-instruction('oxy_comment_end')">
    <xsl:if test="$debug">
      <xsl:variable name="start" select="preceding::processing-instruction('oxy_comment_start')[1]" as="processing-instruction()"/>
      <xsl:variable name="attributes" as="element()">
        <res>
          <xsl:apply-templates select="$start" mode="x:parse-pi"/>
        </res>
      </xsl:variable>
      <w:commentRangeEnd w:id="{$attributes/@draft-comment-number}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/draft-comment ')] |
                       processing-instruction('oxy_comment_start')"
                mode="block-style">
    <w:pStyle w:val="CommentText"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/indexterm ')]"/>
  
  <xsl:template match="*[contains(@class,' topic/term ')]" name="topic.term">
    <xsl:param name="keys" select="@keyref" as="attribute()?"/>
    <xsl:param name="contents" as="node()*">
      <xsl:variable name="target" select="key('id', substring(@href, 2), $root)" as="element()*"/>
      <xsl:choose>
        <xsl:when test="not(normalize-space(.)) and $keys and $target/self::*[contains(@class,' topic/topic ')]">
          <xsl:apply-templates select="$target/*[contains(@class, ' topic/title ')]/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- FIXME: create link because Word REF will pull link content from target -->
    <!--xsl:variable name="topicref" select="key('map-id', substring(@href, 2))"/>
    <xsl:choose>
      <xsl:when test="$keys and @href and not($topicref/ancestor-or-self::*[@linking][1]/@linking = ('none', 'sourceonly'))">
        <xsl:call-template name="topic.xref">
          <xsl:with-param name="contents" select="$contents"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise-->
        <xsl:copy-of select="$contents"/>
      <!--/xsl:otherwise>
    </xsl:choose-->
  </xsl:template>
  
  <xsl:template match="processing-instruction('br')">
    <w:r>
      <w:br/>
    </w:r>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/tm ')]" name="topic.tm">
    <xsl:apply-templates/>
    <w:r>
      <w:rPr>
        <xsl:apply-templates select="ancestor-or-self::*" mode="inline-style"/>
      </w:rPr>
      <w:t>
        <xsl:choose>
          <xsl:when test="@tmtype = 'tm'">&#x2122;</xsl:when>
          <xsl:when test="@tmtype = 'reg'">&#xAE;</xsl:when>
          <xsl:when test="@tmtype = 'service'">&#x2120;</xsl:when>
        </xsl:choose>
      </w:t>
    </w:r>
  </xsl:template>
  
</xsl:stylesheet>
