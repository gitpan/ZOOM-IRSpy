%# $Id: upload.mc,v 1.1 2007/06/28 13:37:11 mike Exp $
<%args>
$filename => undef
</%args>
% if (!defined $filename) {
   <form method="post" action=""
	    enctype="multipart/form-data">
    <p>
     ZeeRex file to upload:
     <input type="file" name="filename" size="50"/>
     <br/>
     <input type="submit" name="_submit" value="Submit"/>
    </p>
   </form>
% return;
% }
<%perl>
my $fin = $r->upload()->fh();
if (!defined $fin) {
    $m->comp("/details/error.mc", msg => "Upload cancelled");
    return;
}

my $xml = join("", <$fin>);
my $xc = irspy_xpath_context($xml);
my $id = irspy_record2identifier($xc);
my $conn = new ZOOM::Connection("localhost:8018/IR-Explain---1", 0,
				user => "admin", password => "fruitbat",
				elementSetName => "zeerex");
ZOOM::IRSpy::_really_rewrite_record($conn, $xc->getContextNode());
</%perl>
     <p>
      Upload OK.
     </p>
     <p>
      Proceed to
      <a href="<% xml_encode("/full.html?id=" . uri_escape($id))
	%>">the new record</a>.
     </p>