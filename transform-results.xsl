<?xml version="1.0" encoding="UTF-8"?>
<html xsl:version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
    <body style="font-family:Arial;font-size:12pt;background-color:#EEEEEE">
        <xsl:for-each select="testsuite">
            <div style="background-color:blue;color:white;padding:4px">
                <span style="font-weight:bold">
                    <xsl:value-of select="@name"/>
                    <xsl/> Overall Results
                </span>
            </div>
            <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">
                <span>
                    <xsl/> tests:
                </span>
                <xsl:value-of select="@tests"/>
            </div>  
            <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">
                <span>
                    <xsl/> assertions:
                </span>
                <xsl:value-of select="@assertions"/>
            </div>
            <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">
                <span>
                    <xsl/> failures:
                </span>
                <xsl:value-of select="@failures"/>
            </div>  
            <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">
                <span>
                    <xsl/> errors:
                </span>
                <xsl:value-of select="@errors"/>
            </div>  
            <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">
                <span>
                    <xsl/> time (seconds):
                </span>
                <xsl:value-of select="@time"/>
            </div> 
        </xsl:for-each>
        <xsl:for-each select="testsuite/testcase">
            <div style="color:white;padding:4px">
                <xsl:attribute name="style">
                    <xsl:choose>
                        <xsl:when test="failure">background-color:red;color:white;padding:4px;font-weight:bold</xsl:when>
                        <xsl:when test="@assertions=0">background-color:gray;color:white;padding:4px;font-weight:bold</xsl:when>
                        <xsl:otherwise>background-color:green;color:white;padding:4px;font-weight:bold</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>  
                <span><xsl:value-of select="@name"/></span>
            </div>
            <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">
                <span>
                    <xsl/> assertions:
                </span>
                <xsl:value-of select="@assertions"/>
            </div>      
            <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">              
                <span>
                    <xsl/> time (seconds):
                </span>
                <xsl:value-of select="@time"/>
            </div>
            <xsl:for-each select="failure">
                <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">              
                    <span>
                        <xsl:value-of select="time"/> failure type:
                    </span>
                    <xsl:value-of select="@type"/>
                </div>
                <div style="margin-left:20px;margin-bottom:1em;font-size:10pt">              
                    <span>
                        <xsl/> failure message:
                    </span>
                    <xsl:value-of select="@message"/>
                </div>               
            </xsl:for-each>      
        </xsl:for-each>
        <div style="background-color:black;color:white;padding:4px">
            <span style="font-weight:bold">
                <xsl/> Console Output
            </span>
        </div>    
        <xsl:value-of
        select="." 
        disable-output-escaping="yes"/>       
    </body>
</html>
