<%@ page import='java.sql.*' %>
<%@ page import='javax.sql.*' %>
<%@ page import='javax.naming.*' %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!--$URL: http://svn.visualdistortion.org/repos/projects/crash/index.jsp $-->
<!--$Rev: 520 $ $Date: 2003-12-25 15:14:39 -0600 (Thu, 25 Dec 2003) $-->
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();

String searchPhrase = request.getParameter("search");
String searchEntry = request.getParameter("search");
String searchType = request.getParameter("search_field");
String show_open = request.getParameter("show_open");
boolean allSearches = false, showFixed = false;

String inetSearch = searchPhrase;

if(show_open != null && show_open.equals("on") ) {
    showFixed = true;
}

if(searchType != null && searchType.equals("all")) {
    allSearches = true;
}

if(searchType == null) {
    searchType = "crash_log";
}

if(searchPhrase != null && searchPhrase.equals("")) {
    searchPhrase = null;
    searchEntry = "";
}

if(searchEntry == null) {
    searchEntry = "";
}

%>
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="crash.css">
    <title>
        Adium Crash Reporter Substring Search
    </title>
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
  </head>
	<body>
        <body bgcolor="#ebebeb">
  <div id="top" class="top">
    <span class="headTitle">Adium Crash Reporter Search</span>
    <table class="tabs" cellspacing="0" width="100%" >
      <tr>
	<td class="tabTopPadding"></td>
      </tr>
      <tr><td class="tabLeftPadding">&nbsp;</td>
	<td class="tab"><a class="hidden" href="index.jsp">Home</a></td>
	<td class="tab">
	  <a class="hidden" href="index.html">Submit</a>
	</td>
	<td class="activeTab">
	  Search
	</td>
	<td class="tabPadding">&nbsp;</td>
      </tr>
    </table> 
  </div>

  <div id="doctor" class="doctor">
    <img src="images/doctor.png">
  </div>

  <div class="content">
        <form action="search.jsp" method="GET">
            Search: <input type="text\" name="search" value="<%= searchEntry %>" />
            <select name="search_field">
                <option value="crash_log" <%if (searchType.equals("crash_log"))
                out.print("selected=\"true\""); %>>Crash Log</option>
                <option value="short_desc" <% if
                (searchType.equals("short_desc"))
                out.print("selected=\"true\"");%>>Short Description</option>
                <option value="description"
                <%if(searchType.equals("description"))
                out.print("selected=\"true\""); %>>Description</option>
                <option value="email" <% if(searchType.equals("email"))
                out.print("selected=\"true\""); %>>Email</option>
                <option value="service_uid"<%
                if(searchType.equals("service_uid"))
                    out.print("selected=\"true\"");%>>IM Handle</option>
                <option value="build" <%if(searchType.equals("build"))
                out.print("selected=\"true\"");%>>Build</option>
                <option value="ip_address" <%
                if(searchType.equals("ip_address"))
                    out.print("selected=\"true\"");%>>IP Address</option>
                <option value="all" <% if(allSearches)
                out.print("selected=\"true\"");%>>-- All --</option>
            </select>
            <input type="checkbox" name="show_open" checked="true" />Show
            Fixed
            <input type="submit" />
        </form>
<%
ResultSet rset = null;
PreparedStatement pstmt = null;
ResultSetMetaData   rsmd = null;

PreparedStatement stmt = null;
ResultSet results = null;

String crashes = new String("");

try {

    if(!allSearches) {
        String queryString = new String("select crash_id as \"ID\", " +
            " '<a href=\"view.jsp?crash=' || crash_id || '\" title=\"'"+
            " || substr(crash_log, 250, 700) || '\">' || " +
            " coalesce(short_desc, 'empty') || '</a>' "+
            " as \"Description\", email as \"Email\", " + 
            " crash_time::timestamp(0) as \"Crash Date & Time\", " +
            " name as \"Status\"" +
            " from crash.crash_logs, crash.status_lookup ");

        if(searchType.equals("ip_address")) {
            queryString += " where ip_address = ?::inet ";
        } else if (searchType.equals("crash_log") ||
            searchType.equals("short_desc") ||
            searchType.equals("long_description")) {
            queryString += " where " + searchType  + " ~* ? ";
        } else {
            queryString += " where " + searchType + " = ? ";
        }

        queryString += " and crash_logs.status_id = status_lookup.status_id ";

        if(!showFixed) {
            queryString += " and crash_logs.status_id <> 3 ";
        }

        queryString += " and application = 'Adium' ";

        queryString += " order by crash_time desc";

        pstmt = conn.prepareStatement(queryString);

        if(!searchType.equals("ip_address")) {
            pstmt.setString(1, searchPhrase);
        } else {
            pstmt.setString(1, inetSearch);
        }
    } else {
        String queryString = new String("select crash_id as \"ID\", " +
            " '<a href=\"view.jsp?crash=' || crash_id || '\" title=\"'"+
            " || substr(crash_log, 250, 700) || '\">' || " +
            " coalesce(short_desc, 'empty') || '</a>' "+
            " as \"Description\", email as \"Email\", " + 
            " crash_time::timestamp(0) as \"Crash Date & Time\", " +
            " name as \"Status\"" +
            " from crash.crash_logs, crash.status_lookup " +
            " where (crash_log ~* ? " +
            " or short_desc ~* ? " +
            " or description ~* ? " +
            " or email = ? " +
            " or service_uid = ? " +
            " or build ~* ? )" +
            " and crash_logs.status_id = status_lookup.status_id ");

        if(!showFixed) {
            queryString += " and crash_logs.status_id <> 3 ";
        }

        queryString += " order by crash_time desc";

        pstmt = conn.prepareStatement(queryString);

        for(int i = 1; i <= 6; i++) {
            pstmt.setString(i, searchPhrase);
        }
    }

    rset = pstmt.executeQuery();

    rsmd = rset.getMetaData();
    if(searchPhrase != null) {
        stmt = conn.prepareStatement("select user_id, name from crash.users where application = 'Adium' order by name");

        results = stmt.executeQuery();

        out.println("<form action=\"update-mass.jsp\" method=\"POST\">");
        out.println("User: <select name=\"user_id\">");
        out.println("<option value=\"0\">Choose</option>");
        while(results.next()) {
            out.println("<option value=\"" + results.getString("user_id") +
                "\">" + results.getString("name") + "</option>");
        }
        out.println("</select>");

        out.println("Status: <select name=\"status\">");
        stmt = conn.prepareStatement("select status_id, name from crash.status_lookup");
        results = stmt.executeQuery();
        out.println("<option value=\"\">Choose One ...</option>");
        while(results.next()) {
            out.println("<option value=\"" + results.getInt("status_id") +
                "\">" + results.getString("name") + "</option>");
        }
        out.println("</select><br />");

        stmt = conn.prepareStatement("select group_id, description from crash.groups");

        results = stmt.executeQuery();
        out.println("Group: <select name=\"group\">");
        out.println("<option value=\"\">Choose One ...</option>");
        while(results.next()) {
            out.println("<option value=\"" + results.getInt("group_id") +
                "\">" + results.getString("description") + "</option>");
        }
        out.println("</select>");

        out.println("New Group: <input type=\"text\" name=\"group_name\" />");
        out.println("<br />Reason: <input type=\"text\" name=\"reason\" />");
        out.println("<br /><input type=\"submit\">");

    /* Print out table headers.
     */

        out.println("<table class=\"contentTable\"><tr>");
        for(int i = 1; i <= rsmd.getColumnCount(); i++) {
            out.println("<td class=\"header\">" + rsmd.getColumnName(i) + "</td>");
        }
        out.println("</tr>");
    }
    
    /* Loop through all of the results and display in a table.
     */
     
    while(rset.next()) {
        out.println("<tr class=\"" + ((rset.getRow() % 2 == 0) ? "evenRow" : "oddRow") + "\">");
        for(int i = 1; i <= rsmd.getColumnCount(); i++) {
            out.println("<td>" + rset.getString(i) + "</td>");
        }
        out.println("</tr>");
        crashes += rset.getInt("ID") + " ";
    }
    out.println("</table>");

    out.println("<input type=\"hidden\" name=\"crashes\" value=\"" + 
        crashes + "\" />");

    out.println("</form>");
} catch(SQLException e) {
    out.println("<span style=\"color: red; font-size: 14pt\">Error:<br />");
    out.println(e.getMessage() + "</span>");
} finally {
    if(pstmt != null) {
        pstmt.close();
    }
    conn.close();
}

%>
</td></tr></table>
</div>
</div>
</body>
</html>
