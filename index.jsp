<%@ page import='java.sql.*' %>
<%@ page import='javax.sql.*' %>
<%@ page import='javax.naming.*' %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">
<!--$URL: http://svn.visualdistortion.org/repos/projects/old_crash/index.jsp $-->
<!--$Rev: 881 $ $Date: 2004-09-09 21:37:59 -0500 (Thu, 09 Sep 2004) $-->

<html>
  <head>
    <link rel="stylesheet" type="text/css" href="crash.css">
    <title>Adium Crash Reporter Home</title>
  </head>
<body bgcolor="#ebebeb">
  <div id="top" class="top">
    <span class="headTitle">Adium Crash Reporter Home</span>
    <table class="tabs" cellspacing="0" width="100%" >
      <tr>
	<td class="tabTopPadding"></td>
      </tr>
      <tr><td class="tabLeftPadding">&nbsp;</td>
	<td class="activeTab">Home</td>
	<td class="tab">
	  <a class="hidden" href="index.html">Submit</a>
	</td>
	<td class="tab">
	  <a class="hidden" href="search.jsp">Search</a>
	</td>
	<td class="tabPadding">&nbsp;
	</td>
      </tr>
    </table> 
  </div>

  <div id="doctor" class="doctor">
    <img src="images/doctor.png" alt="doctor">
  </div>

  <div id="content" class="content">
<h3>If the viewer looks fucked up, you may need to hit refresh.</h3>
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();

int currentPage, crashesPerPage, totalPages, status, view, hours;
crashesPerPage = 30;
totalPages = 0;

String urlString = new String("index.jsp?");

try {
    currentPage = Integer.parseInt(request.getParameter("page"));
}  catch (NumberFormatException e) {
    currentPage = 1;
}

try {
    view = Integer.parseInt(request.getParameter("view"));
    urlString += "&amp;view=" + view;
} catch (NumberFormatException e) {
    view = -1;
}

try {
    hours = Integer.parseInt(request.getParameter("hours"));
    urlString += "&amp;hours=" + hours;
} catch (NumberFormatException e) {
    hours = 36;
}

String orderBy = request.getParameter("orderBy");
String orderAscDesc = request.getParameter("ascDesc");
String oppAscDesc = new String("");

if(orderBy == null || orderBy.equals("")) {
    orderBy = "Build";
    orderAscDesc = "desc";
}

if(orderAscDesc == null || orderAscDesc.equals("")) {
    orderAscDesc = "asc";
}

if(orderAscDesc.equals("asc")) {
    oppAscDesc = "desc";
} else {
    oppAscDesc = "asc";
}

ResultSet rset = null;
PreparedStatement pstmt = null;
ResultSetMetaData   rsmd = null;

PreparedStatement stmt = null;
ResultSet results = null;

try {

    String queryString = new String("select count(*) as total from crash.crash_logs where ");
    if(view == -1) {
        queryString += " status_id <> 3";
    } else if (view ==0 ) {
        queryString += " status_id <> 0";
    }else {
        queryString += " status_id = " + view;
    }

    queryString += " and crash_time > 'now'::timestamp - \'1 hour\'::interval * " + hours;

    queryString += " and application = 'Adium' ";

    pstmt = conn.prepareStatement(queryString);

    rset = pstmt.executeQuery();

    while(rset.next()) {
        totalPages = rset.getInt("total") / crashesPerPage;
        if(rset.getInt("total") % crashesPerPage != 0) {
            totalPages++;
        }
    }

    queryString = "select '<img src=\"images/' || name  || "+
        " '.png\" alt=\"' || name || '\" />&nbsp;' || " +
        " '<a href=\"view.jsp?crash=' || crash_id || '\" title=\"'"+
        " || case when length(crash_log) > 500 then " +
        "   html_entity(substr(crash_log, 250, 700)) " +
        "   else html_entity(crash_log) end || '\">' || " +
        " coalesce(short_desc, 'empty') || '</a>' as \"Description\", "+
        " coalesce('<a href=\"mailto:' || email " +
        " || '\">' || email || '</a>', service_uid) as \"From\", " +
        " build as \"Build\", " +
        " to_char(crash_time, 'Mon DD, YYYY HH24:MI:SS') " +
        " as \"Date Submitted\""+
        " from crash.crash_logs, " +
        " crash.status_lookup "+
        " where status_lookup.status_id = crash_logs.status_id and " +
        " crash_logs.status_id ";

    if(view == -1) {
        queryString += "<> 3";
    } else if (view == 0) {
        queryString += " <> 0";
    } else {
        queryString += " = " + view;
    }

    queryString += " and crash_time > 'now'::timestamp - \'1 hour\'::interval * " + 
        hours;
    
    queryString += " and application = 'Adium'";

    queryString += " order by \"" + orderBy + "\" " + orderAscDesc;

    queryString += " offset " + ((currentPage - 1) * crashesPerPage) + 
        " limit " + crashesPerPage;

    pstmt = conn.prepareStatement(queryString);

    rset = pstmt.executeQuery();

    rsmd = rset.getMetaData();

    if(totalPages > 1) {
        out.println("<span style=\"text-align: right\" id=\"pages\">Pages:");
        if(currentPage != 1) {
            out.println("<a href=\"" + urlString + "&amp;page=" + 
            (currentPage -1 ) + "&amp;orderBy=" + orderBy +
            "\" class=\"lineless\">&nbsp;&lt;&lt;</a>");
        }

        for(int i = 1; i <= totalPages; i++) {
            if(i != currentPage) {
                out.println("&nbsp;<a href=\"" + urlString + "&amp;page=" + i +
                    "&amp;orderBy=" + orderBy +
                    "&amp;ascDesc=" + orderAscDesc +
                    "\" class=\"lineless\">" + i + "</a>");
            }
            else out.print("<span class=\"lineless\"><b>[" + i + "]</b></span>");

            if (i % 20 == 0) {
                out.print("<br>");
            }
        }

        if(currentPage != totalPages) {
            out.println("<a href=\"" + urlString + "&amp;page=" + 
                (currentPage + 1) + "&amp;orderBy=" + orderBy +
                "&amp;ascDesc=" + orderAscDesc +
                "\" class=\"lineless\">&gt;&gt;</a>");
        }

        out.println("</span>");
    }

    out.println(
        "<table cellspacing=\"0\" cellpadding=\"0\" class=\"contentTable\">");
    out.println("<tr>");

    out.println("<td class=\"header\">#</td>");
    for(int i = 1; i <= rsmd.getColumnCount(); i++) {
        out.println("<td class=\"header\"><a href=\"" + urlString +
        "&amp;orderBy=" +
        rsmd.getColumnName(i) + 
        "\">" + rsmd.getColumnName(i) + "</a>");
        if(orderBy.equals(rsmd.getColumnName(i))) {
            out.println("<a href=\"" + urlString + "&amp;orderBy=" +
                rsmd.getColumnName(i) + "&amp;ascDesc=" + oppAscDesc +
                "\">");
            out.println("<img src=\"images/sorted_by_" + orderAscDesc + 
                ".gif\" border=\"0\" alt=\"" + orderAscDesc + "\" />");
            out.println("</a>");
        }
        out.println("</td>");
    }
    out.println("</tr>");

    while(rset.next()) {
        out.print("<tr class=\"" + ((rset.getRow() % 2 == 0) ? "evenRow" : "oddRow") + "\">");

        out.println("<td>" + (rset.getRow() + 
        (currentPage - 1) * crashesPerPage) + 
        "</td>");
        for(int i = 1; i <= rsmd.getColumnCount(); i++) {
            out.println("<td>" + rset.getString(i) + "</td>");
        }
        out.println("</tr>");
    }

    out.println("</table>");

    out.println("<div align=\"right\">");
    stmt = conn.prepareStatement("select status_id, name from crash.status_lookup");

    results = stmt.executeQuery();

    out.println("<form action=\"index.jsp\" method=\"POST\">");
    out.println("View: <select name=\"view\">");
    out.println("<option value=\"\">Choose One ...</option>");
    while(results.next()) {
        out.println("<option value=\"" + results.getInt("status_id") +
            "\">" + results.getString("name") + "</option>");
    }
    out.println("<option value=\"0\">All</option>");
    out.println("</select>");

    out.println("View Logs from last:");
    out.println("<select name=\"hours\">");
    out.println("<option value=\"1\">1 hour</option>");
    out.println("<option value=\"24\">1 day</option>");
    out.println("<option value=\"36\">36 hours</option>");
    out.println("<option value=\"72\">3 days</option>");
    out.println("<option value=\"168\">1 week</option>");
    out.println("<option value=\"336\">2 weeks</option>");
    out.println("<option value=\"10000000\">All</option>");
    out.println("</select>");
    out.println("<input type=\"submit\"></form>");
    out.println("</div>");

    out.println("</div>");
} finally {
    if(pstmt != null) {
        pstmt.close();
    }
    conn.close();
}

%>
</body>
</html>
