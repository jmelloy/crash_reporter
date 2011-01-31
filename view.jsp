<%@ page import='java.sql.*' %>
<%@ page import='javax.sql.*' %>
<%@ page import='javax.naming.*' %>
<%@ page import='java.util.ArrayList' %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/old_crash/view.jsp $-->
<!--$Rev: 770 $ $Date: 2004-05-20 23:45:56 -0500 (Thu, 20 May 2004) $-->
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();

int crash_id;
int group_id;

try {
    crash_id = Integer.parseInt(request.getParameter("crash"));
} catch (NumberFormatException e) {
    crash_id = 0;
}

try {
    group_id = Integer.parseInt(request.getParameter("group"));
} catch (NumberFormatException e) {
    group_id = 0;
}

Statement stmt = null;
ResultSet rset = null;
ResultSetMetaData rsmd = null;

PreparedStatement groupStmt = null;
ResultSet groupResult = null;

Statement fdbkStmt = null;
ResultSet feedSet = null;

PreparedStatement userStmt = null;
ResultSet userSet = null;

ArrayList statusList = new ArrayList();
ArrayList statusNums = new ArrayList();

try {
    stmt = conn.createStatement();
    fdbkStmt = conn.createStatement();

    rset = stmt.executeQuery("select status_id, name " +
        " from crash.status_lookup order by status_id");

    while(rset.next()) {
        statusList.add(rset.getString("name"));
        statusNums.add(rset.getString("status_id"));
    }

    String queryString = new String("select coalesce(email,'&nbsp;') as email, "+
    " coalesce(service_uid, '&nbsp;') as service_uid, " +
    " crash_time, build,"+
    " name as status, " +
    " coalesce(short_desc, '&nbsp;') as short_desc, "+
    " coalesce(crash_logs.description, '&nbsp;') as long_desc, " +
    " '<pre>' || crash_log || '</pre>' as crash_log, " +
    " crash_id, ip_address " +
    " from crash.crash_logs natural left join crash.crash_group, " +
    " crash.status_lookup,  " +
    " crash.groups " +
    " where crash_logs.status_id = status_lookup.status_id " +
    " and (groups.group_id = crash_group.group_id or " +
    " crash_group.group_id is null)");

    if(group_id != 0) {
        queryString += " and crash_group.group_id = " + group_id;
    } else {
        queryString += " and crash_logs.crash_id = " + crash_id;
    }

    queryString += " limit 1";
    
    rset = stmt.executeQuery(queryString);

    rsmd = rset.getMetaData();

    rset.next();
%>
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="crash.css">
<%
        out.println("<title>Adium Crash " + 
            crash_id + ": " + rset.getString("short_desc") + "</title>");
%>

</head>
<body bgcolor="#ebebeb">
<div id="top" class="top">
    <span class="headTitle">Crash: <%= rset.getString("short_desc") %></span>
    <table class="tabs" cellspacing="0" width="100%" >
      <tr>
	<td class="tabTopPadding"></td>
      </tr>
      <tr><td class="tabLeftPadding">&nbsp;</td>
	<td class="tab"><a class="hidden" href="index.jsp">Home</a></td>
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
  
  <div id="doctor" style="position:relative" class="doctor">
    <img src="images/doctor.png" alt="doctor">
  </div>

  <div class="content">
<%
    rset.beforeFirst();
    while(rset.next()) {

        crash_id = rset.getInt("crash_id");
%>
        <span class="buildDate">
        <%= rset.getString("build") %>
        </span>
          <span class="crashTitle">
        <%= rset.getString("short_desc") %>
        </span>

        <div class="crashHeader">
        <div class="crashInfo">
            <table>
                <tr>
                    <td class="valueTitle">Email:</td>
                    <td class="value"> 
                        <%= rset.getString("email") %></td>
                </tr>
                <tr>
                    <td class="valueTitle">IM Handle:</td>
                    <td class="value">
                        <%= rset.getString("service_uid") %>
                    </td>
                </tr>
                <tr>
                    <td class="valueTitle">Status:</td>
                    <td class="value">
                        <%= rset.getString("status") %>
                    </td>
                </tr>
                <tr>
                    <td class="valueTitle">Submitted:</td>
                    <td class="value">
                        <%= rset.getString("crash_time") %>
                    </td>
                </tr>
                <tr>
                <td class="valueTitle">IP Address:</td>
                <td class="value">
                    <%= rset.getString("ip_address") %>
                </td>
            </table>
        </div>
<%
        String description = rset.getString("long_desc");
        description = description.replaceAll("\n", "<br />");
        description = description.replaceAll("   ", " &nbsp; ");
        out.println(description);
        
        out.println("</div>");
        out.println("<div class=\"crashDump\">");
        out.println(rset.getString("crash_log"));

    feedSet = fdbkStmt.executeQuery("select email, name, "+
        "subject, message, date_added, 1 as type "+
        " from crash.comments, " + 
        " crash.users " +
        " where crash_id = " + crash_id + 
        " and comments.user_id = users.user_id " + 
        " union all " +
        " select email, users.name, " +
        " null as subject, status_lookup.name || " + 
        " case when reason is not null then ' (' || reason || ')' " +
        " else '' end " +
        " as message, " +
        " change_date as date_added, 2 as type " +
        " from crash.users, crash.status_history, " +
        " crash.status_lookup " +
        " where status_history.status_id = status_lookup.status_id " +
        " and users.user_id = status_history.user_id " +
        " and status_history.crash_id = " + crash_id + 
        " union all " +
        " select email, users.name, " + 
        " null as subject, " +
        " '<b>' || groups.description || '</b>' || " +
        " case when reason is not null then ' (' || reason || ')' " +
        " else '' end " +
        " as message, " + 
        " date_created as date_added, 3 as type " +
        " from crash.users, crash.group_history, crash.groups " +
        " where group_history.group_id = groups.group_id " +
        " and group_history.user_id = users.user_id " +
        " and group_history.crash_id  = " + crash_id +
        " order by date_added");

        if (feedSet.isBeforeFirst()) {
            boolean firstPass = true;
            while(feedSet.next()) {
                if(!firstPass)
                    out.println("<hr width=\"75%\" />");
                else
                    firstPass = false;

                String email = feedSet.getString("email");

                if(feedSet.getInt("type") == 1) {
                    out.println("<b>" + feedSet.getString("subject") + "</b><br>");
                } else if (feedSet.getInt("type") == 2) {
                    out.println("<i>Changed to ");
                } else if (feedSet.getInt("type") == 3) {
                    out.println("<i>Group changed to ");
                }

                out.println(feedSet.getString("message"));

                if(feedSet.getInt("type") == 1) {
                    out.println("<br>");
                } else if (feedSet.getInt("type") == 2) {
                    out.println(" by ");
                } else if (feedSet.getInt("type") == 3) {
                    out.println(" by ");
                }

                if (email != null) 
                    out.println("<a href=\"mailto:" + email + "\">");

                out.println(feedSet.getString("name"));

                if (email != null) 
                    out.println("</a>");

                out.println(" on " + feedSet.getDate("date_added") +
                    " at " + feedSet.getTime("date_added"));

                if(feedSet.getInt("type") == 2 ||
                    feedSet.getInt("type") == 3) {
                    out.println("</i>");
                }
            } 
        }
        out.println("<hr />");
    }

    userStmt = conn.prepareStatement("select name, user_id from crash.users where application = 'Adium' order by name");

    userSet = userStmt.executeQuery();
    
    if(group_id == 0) {
%>
        Add a comment to this crash log: <br />
        <form action="post-comments.jsp" method="POST">
            <input type="hidden" name="crash" value="<%= crash_id %>">
            <table border=0>
                <tr>
                    <td>
                        <label for="user">User:<br></label>
                        <select name="user_id" id="user">
                            <option value="0">Choose One</option>
<%
        while(userSet.next()) {
            out.println("<option value=\"" + userSet.getString("user_id") + 
                "\">" + userSet.getString("name") + "</option>");
        }
%>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="subject">Subject:<br></label>
                        <input type="text" name="subject" size="43" maxlength="100" id="subject">
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="feedback">Comment:<br></label>
                        <textarea name="message" cols="45"rows="3" id="feedback"></textarea>
                    </td>
                </tr>
            </table
            <input type="reset">
            <input type="submit">
        </form>
        <hr />
<%
        //Status
        if(group_id == 0) {
            out.println("<form action=\"update-status.jsp\" method=\"POST\">");
            out.println("<input type=\"hidden\" name=\"crash_id\" value=\"" + 
                crash_id + "\" />");


            out.println("User id:<br />");
%>
                <select name="user_id">
                    <option value="0">Choose One</option>
<%
            userSet.beforeFirst();
            while(userSet.next()) {
                out.println("<option value=\"" + userSet.getString("user_id") + 
                    "\">" + userSet.getString("name") + "</option>");
            }
%>
                        </select>
<%
            out.println("Change status to:");
            out.println("<select name=\"status\">");

            for(int i = 0; i < statusList.size(); i++) {
                out.println("<option value=\"" + 
                    statusNums.get(i).toString() + "\">" + 
                    statusList.get(i).toString() + "</option>");
            }
            out.println("</select>");

            out.println("Reason:<input type=\"text\" name=\"reason\" /><br />");

            out.println("<input type=\"reset\"><input type=\"submit\">");
            out.println("</form>");


            // Groups
            out.println("<form action=\"update-group.jsp\" method=\"GET\">");
            rset = stmt.executeQuery("select group_id, description from crash.groups order by date_created desc");

            out.println("<input type=\"hidden\" name=\"crash_id\" " +
                " value=\"" + crash_id + "\" />");

            out.println("User:<br />");
%>
<select name="user_id">
                            <option value="0">Choose One</option>
<%
        userSet.beforeFirst();
        while(userSet.next()) {
            out.println("<option value=\"" + userSet.getString("user_id") + 
                "\">" + userSet.getString("name") + "</option>");
        }
%>
                        </select>
<%
            out.println("Add this crash log to a group:");
            out.println("<select name=\"group\">");
            out.println("<option value=\"\">Choose One ...</option>");
            while(rset.next()) {
                out.println("<option value=\"" + rset.getString("group_id") +
                    "\">" + rset.getString("description") + "</option>");
            }
            out.println("</select>");

            out.println("Or add it to a new group entitled:");
            out.println("<input type=\"text\" name=\"group_name\" />");

            out.println("Reason: <input type=\"text\" name=\"reason\" />");

            out.println("<br /><input type=\"reset\" /><input type=\"submit\" />");
            out.println("</form>");
        }

        out.println("</div>");
        out.println("</div>");
    }
        } catch(SQLException e) {
            out.println("<h2>Error!</h2>");
            out.println(e.getMessage());

            out.println("<br><a href=\"index.jsp\">Return to index</a>");
        } finally {
            stmt.close();
            fdbkStmt.close();
            conn.close();
        }
%>
    </body>
</html>
