xquery version "3.1";

module namespace idx="http://teipublisher.com/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace dbk="http://docbook.org/ns/docbook";

declare variable $idx:app-root :=
    let $rawPath := system:get-module-load-path()
    return
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    ;

(:~
 : Helper function called from collection.xconf to create index fields and facets.
 : This module needs to be loaded before collection.xconf starts indexing documents
 : and therefore should reside in the root of the app.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    return
        switch ($field)
            case "title" return
                string-join((
                    $header//tei:msDesc/tei:head, $header//tei:titleStmt/tei:title[@type = 'main'],
                    $header//tei:titleStmt/tei:title,
                    $root/dbk:info/dbk:title,
                    root($root)//article-meta/title-group/article-title,
                    root($root)//article-meta/title-group/subtitle
                ), " - ")
            case "author" return (
                $header//tei:correspDesc/tei:correspAction/tei:persName,
                $header//tei:titleStmt/tei:author,
                $root/dbk:info/dbk:author,
                root($root)//article-meta/contrib-group/contrib/name
            )
            case "language" return
  distinct-values(
    (
      $root/@xml:lang/string(),
      $header/@xml:lang/string(),
      $header//tei:langUsage/tei:language/@ident/string()
    )
  )

            case "genre" return
  let $vals := distinct-values(
    for $t in $header//tei:textClass/tei:keywords[@scheme='#type']/tei:term
    return normalize-space(string($t))
  )
  return if (empty($vals)) then ("unknown") else $vals

case "keywords" return
  let $vals := distinct-values(
    for $k in $header//tei:textClass/tei:keywords[@scheme='#topic']/tei:term
    return normalize-space(string($k))
  )
  return if (empty($vals)) then ("none") else $vals

case "place" return
  let $refs := distinct-values($header//tei:profileDesc/tei:settingDesc//tei:placeName/@ref)
  let $places-reg := doc("/db/apps/wvh-schriften/resources/registers/places.xml")
  let $names := for $ref in $refs
                let $entry := $places-reg//place[@xml:id = $ref]  (: NO tei: prefix :)
                let $name := normalize-space($entry/placeName[@type='main'][1])
                return if ($name) then $name else $ref
  return if (empty($names)) then ("unknown") else $names


            default return
                ()
};
