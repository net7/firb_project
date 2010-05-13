<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes"/>


<xsl:param name="source_uri"/>

<!--
<xsl:template match="/">
<span line="1"><xsl:apply-templates select="*"/></span>
</xsl:template>


<xsl:template match="lb">
 <xsl:variable name="pos"><xsl:number level="any" count="lb"/></xsl:variable>
<xsl:text disable-output-escaping="yes">&lt;/span&gt;</xsl:text><br />
  <xsl:apply-templates/>
<xsl:text disable-output-escaping="yes">&lt;span</xsl:text> line="<xsl:value-of select="$pos + 1"/><xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
</xsl:template>
-->

<xsl:template match="/">
<div class="thctag" about="{$source_uri}"><xsl:apply-templates select="*"/></div>
</xsl:template>


<xsl:template match="p">
<p>
  <xsl:choose>
    <!-- Exclude existing paragraph nodes, or we'd generate nested paragraphs which is invalid XHTML -->
    <xsl:when test="count(span)=0">
      <!-- Add text nodes preceding a 'lb' node -->
      <xsl:apply-templates select="lb" />
      <!-- Add text node following the last 'lb' node -->
<!-- used when lb follows text 
      <xsl:variable name="pos"><xsl:number level="any" count="lb"/></xsl:variable>
  <span class="line"><span class="number"><xsl:value-of select="$pos"/></span><xsl:value-of select="lb[last()]/preceding::text()" /></span> <xsl:text>
    </xsl:text>
-->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="p" />
    </xsl:otherwise>
  </xsl:choose>
</p>
</xsl:template>

<xsl:template match="lb">
  <!-- Scoop up any text preceding the <lb /> from the previous node which could be a 'p' node or a 'lb' node -->
 <xsl:variable name="pos"><xsl:number level="any" count="lb"/></xsl:variable>
  <span class="line"><span class="number"><xsl:value-of select="$pos"/></span><xsl:value-of select="following::text()[1]"/></span><br/><xsl:text>
</xsl:text>
</xsl:template>

   
<xsl:template match="div">
  <div><xsl:apply-templates/></div>
</xsl:template>


<xsl:template match="figure">
 <xsl:variable name="pos"><xsl:number level="any" count="figure"/></xsl:variable>
  <figure about="{$source_uri}_img_{$pos}"/><xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>



