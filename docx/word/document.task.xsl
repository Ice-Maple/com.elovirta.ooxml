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
               xmlns:x="com.elovirta.ooxml"
               exclude-result-prefixes="x xs"
               version="2.0">

  <xsl:variable name="generate-task-labels" select="true()" as="xs:boolean"/>

  <xsl:template match="*[contains(@class, ' task/context ')]">
    <xsl:variable name="context" select="not(empty(text())) or exists(./p)"></xsl:variable>
    <xsl:if test="$generate-task-labels and $context">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>
              <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'task_context'"/>
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


  <xsl:template match="*[contains(@class, ' task/prereq ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>
              <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'task_prereq'"/>
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

  <xsl:template match="*[contains(@class, ' task/postreq ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>
              <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'task_postreq'"/>
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

  <xsl:template match="*[contains(@class, ' task/example ')]">
    <xsl:if test="$generate-task-labels">
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

  <xsl:template match="*[contains(@class, ' task/steps ')] |
                       *[contains(@class, ' task/steps-unordered ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>
              <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'task_procedure'"/>
              </xsl:call-template>
            </w:t>
          </w:r>
        </xsl:with-param>
        <xsl:with-param name="style">
          <xsl:call-template name="block-style-section.title"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="has_id" select="exists(@id)" as="xs:boolean"/>
    <xsl:if test="$has_id">
      <xsl:call-template name="start-bookmark">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*"/>
    <xsl:if test="$has_id">
      <xsl:call-template name="end-bookmark">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' task/result ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>
              <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'task_results'"/>
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
  
  <xsl:template match="*[contains(@class, ' task/steps ')]/*[contains(@class, ' task/step ')]">
	  <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' task/substeps ')]/*[contains(@class, ' task/substep ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <!--xsl:template match="*[contains(@class, ' task/choices ')]">
    <!- - FIXME - ->
  </xsl:template-->

  <xsl:template match="*[contains(@class, ' task/cmd ')]">
	  <!--tanxl PATCH-->
	<xsl:choose>
	  <xsl:when test="($instep = 'yes') and (contains(../../@class, ' topic/ol '))">
	  <xsl:call-template name="p">
		  <xsl:with-param name="step" select="true()"/>
	  </xsl:call-template>
  	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="p"/>
	</xsl:otherwise>
       </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' task/info ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>

</xsl:stylesheet>
