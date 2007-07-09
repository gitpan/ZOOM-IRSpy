%# $Id: delete.mc,v 1.7 2007/06/27 11:09:32 mike Exp $
<%args>
$id
$really => 0
</%args>
% if (!$really) {
     <h2>Warning</h2>
     <p class="error">
      Are you sure you want to delete the target
      <% xml_encode($id) %>?
     </p>
     <p>
      <a href="?really=1&amp;id=<% xml_encode(uri_escape($id)) %>">Yes</a><br/>
      <a href="/full.html?id=<% xml_encode(uri_escape($id)) %>">No</a><br/>
     </p>
% } else {
<%perl>
    my $conn = new ZOOM::Connection("localhost:8018/IR-Explain---1", 0,
				    user => "admin", password => "fruitbat",
				    elementSetName => "zeerex");
    ZOOM::IRSpy::_delete_record($conn, $id);
</%perl>
     <p>
      Deleted record
      <% xml_encode($id) %>
     </p>
% }