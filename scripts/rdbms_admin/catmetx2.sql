Rem
Rem $Header: catmetx2.sql 20-jun-2008.14:38:32 lbarton Exp $
Rem
Rem catmetx2.sql
Rem
Rem Copyright (c) 2008, Oracle.  All rights reserved.  
Rem
Rem    NAME
Rem      catmetx2.sql - Metadata API: XMLSchema registration
Rem
Rem    DESCRIPTION
Rem      Registration of our XMLSchemas used to be in catmetx.sql,
Rem      but kusparse.xsd requires so much shared pool we have
Rem      moved schema registration out of database build to this file.
Rem
Rem    NOTES
Rem      Requires at least 220M shared pool
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     06/09/08 - Created
Rem

-- delete the schemas if they exist

exec dbms_metadata_util.delete_xmlschema('kuscnstr.xsd');
exec dbms_metadata_util.delete_xmlschema('kuscomm.xsd');
exec dbms_metadata_util.delete_xmlschema('kusindex.xsd');
exec dbms_metadata_util.delete_xmlschema('kusindxt.xsd');
exec dbms_metadata_util.delete_xmlschema('kustable.xsd');
exec dbms_metadata_util.delete_xmlschema('kustablt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusclus.xsd');
exec dbms_metadata_util.delete_xmlschema('kusclust.xsd');
exec dbms_metadata_util.delete_xmlschema('kusctx.xsd');
exec dbms_metadata_util.delete_xmlschema('kusctxt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusdblk.xsd');
exec dbms_metadata_util.delete_xmlschema('kusdblkt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusfga.xsd');
exec dbms_metadata_util.delete_xmlschema('kusfgat.xsd');
exec dbms_metadata_util.delete_xmlschema('kusmv.xsd');
exec dbms_metadata_util.delete_xmlschema('kusmvt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusmvl.xsd');
exec dbms_metadata_util.delete_xmlschema('kusmvlt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusparse.xsd');
exec dbms_metadata_util.delete_xmlschema('kusque.xsd');
exec dbms_metadata_util.delete_xmlschema('kusquet.xsd');
exec dbms_metadata_util.delete_xmlschema('kusquetb.xsd');
exec dbms_metadata_util.delete_xmlschema('kusquetbt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrlsc.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrlsct.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrlsg.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrlsgt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrlsp.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrlspt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrole.xsd');
exec dbms_metadata_util.delete_xmlschema('kusrolet.xsd');
exec dbms_metadata_util.delete_xmlschema('kusseq.xsd');
exec dbms_metadata_util.delete_xmlschema('kusseqt.xsd');
exec dbms_metadata_util.delete_xmlschema('kussyn.xsd');
exec dbms_metadata_util.delete_xmlschema('kussynt.xsd');
exec dbms_metadata_util.delete_xmlschema('kustbls.xsd');
exec dbms_metadata_util.delete_xmlschema('kustblst.xsd');
exec dbms_metadata_util.delete_xmlschema('kustrig.xsd');
exec dbms_metadata_util.delete_xmlschema('kustrigt.xsd');
exec dbms_metadata_util.delete_xmlschema('kusview.xsd');
exec dbms_metadata_util.delete_xmlschema('kusviewt.xsd');
exec dbms_metadata_util.delete_xmlschema('kususer.xsd');
exec dbms_metadata_util.delete_xmlschema('kususert.xsd');
exec dbms_metadata_util.delete_xmlschema('kustype.xsd');
exec dbms_metadata_util.delete_xmlschema('kustypt.xsd');
exec dbms_metadata_util.delete_xmlschema('kustypb.xsd');
exec dbms_metadata_util.delete_xmlschema('kustypbt.xsd');
exec dbms_metadata_util.delete_xmlschema('kuscomp.xsd');


-- Register the schemas in dependency order.

exec dbms_metadata_util.load_xsd('kuscomm.xsd');
exec dbms_metadata_util.load_xsd('kusparse.xsd');
exec dbms_metadata_util.load_xsd('kusindxt.xsd');
exec dbms_metadata_util.load_xsd('kusindex.xsd');
exec dbms_metadata_util.load_xsd('kuscnstr.xsd');
exec dbms_metadata_util.load_xsd('kustablt.xsd');
exec dbms_metadata_util.load_xsd('kustable.xsd');
exec dbms_metadata_util.load_xsd('kusclust.xsd');
exec dbms_metadata_util.load_xsd('kusclus.xsd');
exec dbms_metadata_util.load_xsd('kusctxt.xsd');
exec dbms_metadata_util.load_xsd('kusctx.xsd');
exec dbms_metadata_util.load_xsd('kusdblkt.xsd');
exec dbms_metadata_util.load_xsd('kusdblk.xsd');
exec dbms_metadata_util.load_xsd('kusfgat.xsd');
exec dbms_metadata_util.load_xsd('kusfga.xsd');
exec dbms_metadata_util.load_xsd('kusmvt.xsd');
exec dbms_metadata_util.load_xsd('kusmv.xsd');
exec dbms_metadata_util.load_xsd('kusmvlt.xsd');
exec dbms_metadata_util.load_xsd('kusmvl.xsd');
exec dbms_metadata_util.load_xsd('kusquet.xsd');
exec dbms_metadata_util.load_xsd('kusque.xsd');
exec dbms_metadata_util.load_xsd('kusquetbt.xsd');
exec dbms_metadata_util.load_xsd('kusquetb.xsd');
exec dbms_metadata_util.load_xsd('kusrlsct.xsd');
exec dbms_metadata_util.load_xsd('kusrlsc.xsd');
exec dbms_metadata_util.load_xsd('kusrlsgt.xsd');
exec dbms_metadata_util.load_xsd('kusrlsg.xsd');
exec dbms_metadata_util.load_xsd('kusrlspt.xsd');
exec dbms_metadata_util.load_xsd('kusrlsp.xsd');
exec dbms_metadata_util.load_xsd('kusrolet.xsd');
exec dbms_metadata_util.load_xsd('kusrole.xsd');
exec dbms_metadata_util.load_xsd('kusseqt.xsd');
exec dbms_metadata_util.load_xsd('kusseq.xsd');
exec dbms_metadata_util.load_xsd('kussynt.xsd');
exec dbms_metadata_util.load_xsd('kussyn.xsd');
exec dbms_metadata_util.load_xsd('kustblst.xsd');
exec dbms_metadata_util.load_xsd('kustbls.xsd');
exec dbms_metadata_util.load_xsd('kustrigt.xsd');
exec dbms_metadata_util.load_xsd('kustrig.xsd');
exec dbms_metadata_util.load_xsd('kusviewt.xsd');
exec dbms_metadata_util.load_xsd('kusview.xsd');
exec dbms_metadata_util.load_xsd('kususert.xsd');
exec dbms_metadata_util.load_xsd('kususer.xsd');
exec dbms_metadata_util.load_xsd('kustypt.xsd');
exec dbms_metadata_util.load_xsd('kustype.xsd');
exec dbms_metadata_util.load_xsd('kustypbt.xsd');
exec dbms_metadata_util.load_xsd('kustypb.xsd');
exec dbms_metadata_util.load_xsd('kuscomp.xsd');

