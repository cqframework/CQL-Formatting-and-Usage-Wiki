Note that the VSCode plugin does support CQL authoring (but not execution) of QDM-based CQL, however it does not support it out of the box. You must include the QDM Model Info file in your CQL directory:

* [QDM 5.6 Model Info](https://github.com/cqframework/clinical_quality_language/blob/master/Src/java/qdm/src/main/resources/gov/healthit/qdm/qdm-modelinfo-5.6.xml)

Make sure you preserve the name of the XML file exactly as present in the above link. With this file present in your CQL directory, the plugin will be able to perform syntax highlighting and error checking on CQL files that use the QDM model.

Note that it will not be able to execute this CQL, as there is no data provider implementation for the QDM content, so this is only for the syntax checking capabilities.