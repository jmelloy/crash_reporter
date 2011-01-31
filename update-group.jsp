<%@ page import='java.sql.*' %>
<%@ page import='javax.sql.*' %>
<%@ page import='javax.naming.*' %>
<%@ page import='java.util.Properties' %>

<!--$URL: http://svn.visualdistortion.org/repos/projects/crash/post-comments.jsp $-->
<!--$Rev: 504 $ $Date: 2003-12-16 19:57:26 -0600 (Tue, 16 Dec 2003) $-->
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();

int crash_id  = Integer.parseInt(request.getParameter("crash_id"));
int user_id = 0;
int group_id = 0;
String group_name = request.getParameter("group_name");
String reason = request.getParameter("reason");

try {
    group_id = Integer.parseInt(request.getParameter("group"));
} catch (NumberFormatException e) {
    group_id = 0;
}

try {
    user_id = Integer.parseInt(request.getParameter("user_id"));
} catch (NumberFormatException e) {
    out.print("<h1>Get a user_id!</h1>");
}

if(group_name != null && group_name.equals("") ){
    group_name = null;
}

PreparedStatement pstmt = null;
ResultSet rset = null;
try {

    if(group_id == 0 && group_name != null) {
        pstmt = conn.prepareStatement("insert into crash.groups " +
            "(created_by, description) values " +
            "(?,?)");

        pstmt.setInt(1, user_id);
        pstmt.setString(2, group_name);

        pstmt.executeUpdate();

        pstmt = conn.prepareStatement("select group_id from crash.groups " +
            " where description = ? ");

        pstmt.setString(1, group_name);

        rset = pstmt.executeQuery();

        while(rset.next()) {
            group_id = rset.getInt("group_id");
        }
    }

    pstmt = conn.prepareStatement("insert into crash.group_history " +
        "(user_id, crash_id, group_id, reason) values " +
        "(?,?,?,?)");

    pstmt.setInt(1, user_id);
    pstmt.setInt(2, crash_id);
    pstmt.setInt(3, group_id);
    pstmt.setString(4, reason);

    pstmt.executeUpdate();

    pstmt = conn.prepareStatement("insert into crash.crash_group " +
        " (crash_id, group_id) values " +
        " (?, ?)");

    pstmt.setInt(1, crash_id);
    pstmt.setInt(2, group_id);

    pstmt.executeUpdate();

    /*
    //send an email
    Properties props = new Properties();
    props.put("mail.smtp.host", "calvin.slamb.org");
    Session s = Session.getInstance(props, null);
    MimeMessage message = new MimeMessage(s);

    InternetAddress from;
    try {
        from = new InternetAddress(email);
        message.setFrom(from);
    } catch (AddressException ae) {
        from = new InternetAddress("jmelloy@visualdistortion.org");
        message.setFrom(from);
    } catch (MessagingException e) {
        from = new InternetAddress("jmelloy@visualdistortion.org");
        message.setFrom(from);
    }

    InternetAddress to = new InternetAddress("jmelloy@visualdistortion.org");
    message.setRecipient(Message.RecipientType.TO, to);

    message.setSubject("Feedback added to picture " + pic);
    message.setText(name + "\n" + 
        email + "\n" + 
        subject + "\n" + 
        body + "\n\n" + 
        "\n\nhttp://www.visualdistortion.org/pictures/viewcomments.jsp?pic=" + pic);

    try {
        Transport.send(message);
    } catch (SendFailedException e) {
        InternetAddress from2 = new InternetAddress("jmelloy@visualdistortion.org");
        message.setFrom(from2);
        Transport.send(message);
    }
    */
    response.sendRedirect("view.jsp?crash=" + crash_id);

} catch(SQLException e) {
    out.print("Group not entered successfully!<br>");
    out.print(e.getMessage());
}

finally {
conn.close();
}

%>
</body>
</html>
