ROOT=$(pwd)
XSL_DIR="${ROOT}/rhaptos.cnxmlutils/rhaptos/cnxmlutils/xsl"

# Check commandline arguments and environment before running
if [ -z $1 ]; then
  echo 'This file takes at least 2 arguments:'
  echo '1. A string representing the book title (usually "col11448@1.7")'
  echo '2. The path to an unzipped complete zip from http://cnx.org (ie http://cnx.org/content/col11448/latest/complete)'
  echo '3. An optional destination directory'
  echo ''
  echo 'It also requires a copy of http://github.com/Connexions/rhaptos.cnxmlutils/'
  echo 'to be checked out in the current directory.'
  exit 1
fi

# Make sure "rhaptos.cnxmlutils exists"
if [ ! -d ${XSL_DIR} ]; then
  echo "${XSL_DIR} does not exist!"
  echo 'Please obtain a copy from http://github.com/Connexions/rhaptos.cnxmlutils'
  exit 2
fi


if [ -z $3 ]; then
  DEST=${ROOT}
else
  mkdir -p $3
  DEST=$(cd $3 && pwd)
fi
# Make sure there is a content directory in the DEST directory
mkdir ${DEST}/content
mkdir ${DEST}/resources


COLLECTION=$1
cd $2




MODULES=$(ls|grep "^m")


# A little XSL file that extracts the title from a module
TITLES_XSL='''
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://cnx.rice.edu/cnxml"
    version="1.0">

  <xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

  <xsl:template match="/">
    <xsl:value-of select="c:document/c:title/text()"/>
  </xsl:template>

  </xsl:stylesheet>
'''

IMAGES_REWRITE_XSL='''
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://cnx.rice.edu/cnxml"
    version="1.0">

  <xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

  <xsl:template match="c:image/@src">
    <xsl:attribute name="src">
      <xsl:text>../resources/</xsl:text>
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  </xsl:stylesheet>
'''

IMAGE_MEDIATYPES_XSL='''
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://cnx.rice.edu/cnxml"
    version="1.0">

  <xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

  <xsl:template match="c:image">
    <xsl:value-of select="@mime-type"/><xsl:text>|</xsl:text><xsl:value-of select="@src"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  </xsl:stylesheet>
'''

ALT_TEXT_XSL='''
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://cnx.rice.edu/cnxml"
    version="1.0">

  <xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

  <xsl:template match="c:media">
    <xsl:text>#</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="translate(@alt, &quot;|&quot;, &quot;&quot;)"/>
    <xsl:text>|</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>


  </xsl:stylesheet>
'''

# mimetype file
echo 'application/epub+zip' > ${DEST}/mimetype

# META-INF/container.xml
mkdir -p ${DEST}/META-INF
echo '<?xml version="1.0" encoding="UTF-8"?>' > ${DEST}/META-INF/container.xml
echo '<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">' >> ${DEST}/META-INF/container.xml
echo '<rootfiles>' >> ${DEST}/META-INF/container.xml
echo "  <rootfile full-path=\"${COLLECTION}.opf\" media-type=\"application/oebps-package+xml\"/>" >> ${DEST}/META-INF/container.xml
echo '</rootfiles>' >> ${DEST}/META-INF/container.xml
echo '</container>' >> ${DEST}/META-INF/container.xml

# OPF File header
echo '<?xml version="1.0" encoding="UTF-8"?>' > ${DEST}/${COLLECTION}.opf
echo '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" xml:lang="en" unique-identifier="pub-id" prefix="cc: http://creativecommons.org/ns#">' >> ${DEST}/${COLLECTION}.opf
echo '  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">' >> ${DEST}/${COLLECTION}.opf
echo "    <dc:title id=\"title\">${COLLECTION}</dc:title>" >> ${DEST}/${COLLECTION}.opf
echo '    <meta refines="#title" property="title-type">main</meta>' >> ${DEST}/${COLLECTION}.opf
echo '    <dc:creator id="creator">Connexions</dc:creator>' >> ${DEST}/${COLLECTION}.opf
echo '    <meta refines="#creator" property="file-as">Connexions</meta>' >> ${DEST}/${COLLECTION}.opf
echo "    <dc:identifier id=\"pub-id\">org.cnx.${COLLECTION}</dc:identifier>" >> ${DEST}/${COLLECTION}.opf
echo '    <dc:language>en-US</dc:language>' >> ${DEST}/${COLLECTION}.opf
echo '    <meta property="dcterms:modified">2013-06-23T12:47:00Z</meta>' >> ${DEST}/${COLLECTION}.opf
echo '    <dc:publisher>Connexions</dc:publisher>' >> ${DEST}/${COLLECTION}.opf
echo '    <dc:rights>This work is shared with the public using the Attribution 3.0 Unported (CC BY 3.0) license.</dc:rights>' >> ${DEST}/${COLLECTION}.opf
echo '    <link rel="cc:license" href="http://creativecommons.org/licenses/by/3.0/"/>' >> ${DEST}/${COLLECTION}.opf
echo '    <meta property="cc:attributionURL">http://cnx.org/content</meta>' >> ${DEST}/${COLLECTION}.opf
echo '  </metadata>' >> ${DEST}/${COLLECTION}.opf
echo '  <manifest>' >> ${DEST}/${COLLECTION}.opf
echo "    <item id=\"toc\" properties=\"nav\" href=\"content/${COLLECTION}-toc.xhtml\" media-type=\"application/xhtml+xml\"/>" >> ${DEST}/${COLLECTION}.opf

# ToC Navigation doc
HTML=$(xsltproc ${XSL_DIR}/collxml-to-html5.xsl collection.xml)
echo '<?xml version="1.0" encoding="UTF-8"?>' > ${DEST}/content/${COLLECTION}-toc.xhtml
echo "<html xmlns=\"http://www.w3.org/1999/xhtml\"><body>" >> ${DEST}/content/${COLLECTION}-toc.xhtml
echo ${HTML} | xmllint --nsclean --pretty 2 - >> ${DEST}/content/${COLLECTION}-toc.xhtml
echo "</body></html>" >> ${DEST}/content/${COLLECTION}-toc.xhtml


for ID in ${MODULES}; do
  echo "Starting on ${ID}"
  CNXML_FILE=${ID}/index_auto_generated.cnxml
  TITLE=$(echo ${TITLES_XSL} | xsltproc - ${CNXML_FILE})
  MEDIA_TYPES=$(echo ${IMAGE_MEDIATYPES_XSL} | xsltproc - ${CNXML_FILE})
  CNXML_IMAGE_REWRITE=$(echo ${IMAGES_REWRITE_XSL} | xsltproc --stringparam "image-prefix" "../resources/${ID}@" - ${CNXML_FILE})
  HTML=$(echo ${CNXML_IMAGE_REWRITE} | xsltproc ${XSL_DIR}/cnxml-to-html5.xsl -)

  echo ${ALT_TEXT_XSL} | xsltproc - ${CNXML_FILE} | sed "s/#/${ID}#/g" >> ${ROOT}/phil.txt

  # XHTML File
  echo '<?xml version="1.0" encoding="UTF-8"?>' > ${DEST}/content/${ID}.xhtml
  echo "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title>${TITLE}</title></head>" >> ${DEST}/content/${ID}.xhtml
  echo ${HTML} | xmllint --nsclean --pretty 2 - >> ${DEST}/content/${ID}.xhtml
  echo '</html>' >> ${DEST}/content/${ID}.xhtml

  # OPF File manifest entry
  echo "    <item media-type=\"application/xhtml+xml\" id=\"${ID}\" href=\"content/${ID}.xhtml\"/>" >> ${DEST}/${COLLECTION}.opf

  # For each image in the HTML, add an entry
  for MEDIA_TYPE_IMAGE in ${MEDIA_TYPES}; do
    MEDIA_TYPE=${MEDIA_TYPE_IMAGE%|*}
    IMAGE=${MEDIA_TYPE_IMAGE#*|}

    echo "      <item media-type=\"${MEDIA_TYPE}\" href=\"resources/${IMAGE}\"/>" >> ${DEST}/${COLLECTION}.opf

  done

  # Copy files over (assume there are no conflicts)
  for FILENAME in $(ls ${ID}); do
    cp "${ID}/${FILENAME}" "${DEST}/resources/${FILENAME}"
  done

done


# OPF File spine start
echo '  </manifest>' >> ${DEST}/${COLLECTION}.opf
echo '  <spine>' >> ${DEST}/${COLLECTION}.opf
echo '    <itemref linear="no" idref="toc"/>' >> ${DEST}/${COLLECTION}.opf


for ID in ${MODULES}; do
  # OPF File spine entry
  echo "    <itemref linear=\"yes\" idref=\"${ID}\"/>" >> ${DEST}/${COLLECTION}.opf
done


# OPF File footer
echo '  </spine>' >> ${DEST}/${COLLECTION}.opf
echo '</package>' >> ${DEST}/${COLLECTION}.opf

cd ${XSL_DIR}

