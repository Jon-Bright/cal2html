<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:x="my:x" exclude-result-prefixes="x"
  >

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:variable name="year" select="number(substring(fotobook/@startdatecalendarium,7))"/>
  <xsl:variable name="daysInFeb" select="if (($year mod 4 = 0 and $year mod 100 !=0) or $year mod 400 = 0) then 29 else 28"/>
  <xsl:variable name="months">
    <months>
      <month key="1" name="Januar">31</month>
      <month key="2" name="Februar"><xsl:value-of select="$daysInFeb"/></month>
      <month key="3" name="März">31</month>
      <month key="4" name="April">30</month>
      <month key="5" name="Mai">31</month>
      <month key="6" name="Juni">30</month>
      <month key="7" name="Juli">31</month>
      <month key="8" name="August">31</month>
      <month key="9" name="September">30</month>
      <month key="10" name="Oktober">31</month>
      <month key="11" name="November">30</month>
      <month key="12" name="Dezember">31</month>
    </months>
  </xsl:variable>
  <xsl:key name="monthByNumber" match="month" use="string(@key)"/>

  <xsl:variable name="fonts">
    <fonts>
      <font key="FranklinGothic" css="Franklin Gothic Medium,Franklin Gothic,ITC Franklin Gothic,Arial,sans-serif"/>
    </fonts>
  </xsl:variable>
  <xsl:key name="fontCSSByCode" match="font" use="string(@key)"/>

  <xsl:variable name="pageWidth" select="number(*/page[@pagenr='0']/bundlesize/@width) div 10"/>
  <xsl:variable name="pageHeight" select="number(*/page[@pagenr='0']/bundlesize/@height) div 10"/>
  <xsl:variable name="imageDir" select="fotobook/@imagedir"/>

  <xsl:function name="x:dayOfWeek">
    <xsl:param name="y" />
    <xsl:param name="m" /> <!-- 1 <= m <= 12 -->
    <xsl:param name="d" /> <!-- Gregorian years only -->
    <xsl:variable name="ry" select="if ($m &lt; 3) then $y -1 else $y"/>
    <xsl:variable name="t">
      <xsl:choose>
	<xsl:when test="$m=1">0</xsl:when>
	<xsl:when test="$m=2">3</xsl:when>
	<xsl:when test="$m=3">2</xsl:when>
	<xsl:when test="$m=4">5</xsl:when>
	<xsl:when test="$m=5">0</xsl:when>
	<xsl:when test="$m=6">3</xsl:when>
	<xsl:when test="$m=7">5</xsl:when>
	<xsl:when test="$m=8">1</xsl:when>
	<xsl:when test="$m=9">4</xsl:when>
	<xsl:when test="$m=10">6</xsl:when>
	<xsl:when test="$m=11">2</xsl:when>
	<xsl:when test="$m=12">4</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="($ry + $ry div 4 - $ry div 100 + $ry div 400 + $t + $d) mod 7"/>
  </xsl:function>
  
  <xsl:template match="/fotobook">
    <html>
      <head>
	<title>Calendar</title>
	<style>
	  @page {
	    size: <xsl:value-of select="$pageWidth"/>mm <xsl:value-of select="$pageHeight"/>mm
	  }
	  div.page {
	    position:relative;
	    page-break-after: always;
	    height: 100%;
	  }
	  div.year {
	  }
	  span.year {
	    text-align:center;
	    position:absolute;
	    top:50%;
	    width:100%;
	    line-height:0;
	    font-size:48pt;
	  }
	  div.pic {
	    position:absolute;
	    display:block;
	  }
	  td.daybox {
	    border:1px solid black;
	    text-align:center;
	    height: 2em;
	  }
	</style>
      </head>
      <body>
	<xsl:apply-templates select="page[position() &lt; 3]" />
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="page">
    <div class="page">
      <xsl:apply-templates select="area">
	<xsl:sort select="round(@top * 100)" />
	<xsl:sort select="round(@left * 100)" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="area">
    <xsl:element name="div">
      <xsl:attribute name="class">pic</xsl:attribute>
      <xsl:attribute name="style">
	<xsl:text>left: </xsl:text><xsl:value-of select="((@left div 10) div $pageWidth)*100"/><xsl:text>%; </xsl:text>
	<xsl:text>top: </xsl:text><xsl:value-of select="((@top div 10) div $pageHeight)*100"/><xsl:text>%; </xsl:text>
	<xsl:text>width: </xsl:text><xsl:value-of select="((@width div 10) div $pageWidth)*100"/><xsl:text>%; </xsl:text>
	<xsl:text>height: </xsl:text><xsl:value-of select="((@height div 10) div $pageHeight)*100"/><xsl:text>%; </xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="image"/>
      <xsl:apply-templates select="calendararea"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="image">
    <xsl:element name="img">
      <!--
	  <xsl:attribute name="src" ><xsl:value-of select="concat($imageDir,'/','cal2019-20180630-0D5A7715.jpeg')"/></xsl:attribute>
      -->
      <xsl:attribute name="src" ><xsl:value-of select="concat($imageDir,'/',@filename)"/></xsl:attribute>
      <xsl:attribute name="title"><xsl:value-of select="concat(@filename,'')"/></xsl:attribute>
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="height">100%</xsl:attribute>
    </xsl:element>    
  </xsl:template>

  <xsl:template match="calendararea[@layoutschema='Year (Long-Name-Big)']">
    <xsl:variable name="font" select="key('fontCSSByCode', string(@font), $fonts)/@css"/>
    <div class="year">
    <xsl:element name="span">
      <xsl:attribute name="class">year</xsl:attribute>
      <xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size:48pt; font-weight:bold;</xsl:attribute>
      <xsl:value-of select="$year" />
    </xsl:element>
    </div>
  </xsl:template>
  
  <xsl:template match="calendararea[@layoutschema='OneRow (gerry_03)']">
    <xsl:variable name="month" select="../../@pagenr"/>
    <xsl:variable name="days" select="key('monthByNumber', string($month), $months)"/>
    <xsl:variable name="dayWidth" select="100 div number($days)"/>
    <xsl:variable name="font" select="key('fontCSSByCode', string(@font), $fonts)/@css"/>
    <br /><!-- Hack, calendar boxes start higher than their content starts -->
    <xsl:element name="div">
      <xsl:attribute name="class">mName</xsl:attribute>
      <xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size:24pt; font-weight:bold;</xsl:attribute>
      <xsl:value-of select="key('monthByNumber', string($month), $months)/@name"/>
    </xsl:element>
    <table width="100%">
      <tr>
	<xsl:for-each select="1 to $days">
	  <xsl:element name="td">
	    <xsl:attribute name="class">daybox</xsl:attribute>
	    <xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>;
	    <xsl:variable name="dow" select="x:dayOfWeek($year, $month, position())"/>
	    <xsl:if test="$dow &lt; 1 or $dow &gt; 6">font-weight: bold;</xsl:if>
	    </xsl:attribute>
	    <xsl:attribute name="width"><xsl:value-of select="$dayWidth"/>%</xsl:attribute>
	    <xsl:value-of select="position()"/>
	  </xsl:element>
	</xsl:for-each>
      </tr>
    </table>
  </xsl:template>
  
</xsl:stylesheet>