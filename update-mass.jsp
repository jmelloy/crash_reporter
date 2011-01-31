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

int user_id = 0;
int status = 0;
int group = 0;
String reason = request.getParameter("reason");
String group_name = request.getParameter("group");
String crashes = request.getParameter("crashes");
String crashArray[] = crashes.split(" ");

try {
    user_id = Integer.parseInt(request.getParameter("user_id"));
} catch (NumberFormatException e) {
    out.print("<h1>Get a user_id!</h1>");
}

try {
    status = Integer.parseInt(request.getParameter("status"));
} catch (NumberFormatException e) {
    status = 0;
}

try {
    group = Integer.parseInt(request.getParameter("group"));
} catch (NumberFormatException e) {
    group = 0;
}

if(group_name != null && group_name.equals("") ){
    group_name = null;
}

PreparedStatement pstmt = null;
ResultSet rset = null;

try {

if(status != 0) {
    pstmt = conn.prepareStatement("insert into crash.status_history " +
        "(user_id, crash_id, status_id, reason) values " +
        "(?,?,?,?)");

    for(int i = 0; i < crashArray.length; i++) {
        pstmt.setInt(1, user_id);
        pstmt.setInt(2, Integer.parseInt(crashArray[i]));
        pstmt.setInt(3, status);
        pstmt.setString(4, reason);

        pstmt.executeUpdate();
    }

    pstmt = conn.prepareStatement("update crash.crash_logs set status_id = ? where crash_id = ?");

    for(int i = 0; i < crashArray.length; i++) {
        pstmt.setInt(1, status);
        pstmt.setInt(2, Integer.parseInt(crashArray[i]));

        pstmt.executeUpdate();
    }
}

if(group != 0) {
    pstmt = conn.prepareStatement("insert into crash.group_history " +
        "(user_id, crash_id, group_id, reason) values " +
        "(?,?,?,?)");

    for(int i = 0; i < crashArray.length; i++) {
        pstmt.setInt(1, user_id);
        pstmt.setInt(2, Integer.parseInt(crashArray[i]));
        pstmt.setInt(3, group);
        pstmt.setString(4, reason);

        pstmt.executeUpdate();
    }
}

if(group_name != null) {
    pstmt = conn.prepareStatement("insert into crash.groups " +
        " (description, created_by)  values " +
        " (?, ?)");

    pstmt.setString(1, group_name);
    pstmt.setInt(2, user_id);

    pstmt.executeUpdate();

    pstmt = conn.prepareStatement("select group_id from crash.groups "+ 
        " where description = ? and created_by = ? " +
        " order by date_created desc limit 1");

    pstmt.setString(1, group_name);
    pstmt.setInt(2, user_id);
    
    rset = pstmt.executeQuery();

    while(rset.next()) {
        group = rset.getInt("group_id");
    }
    
    if(group != 0) {
        pstmt = conn.prepareStatement("insert into crash.group_history " +
            "(user_id, crash_id, group_id, reason) values " +
            "(?,?,?,?)");
    
        for(int i = 0; i < crashArray.length; i++) {
            pstmt.setInt(1, user_id);
            pstmt.setInt(2, Integer.parseInt(crashArray[i]));
            pstmt.setInt(3, group);
            pstmt.setString(4, reason);
    
            pstmt.executeUpdate();
        }
    }
    
}

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
response.sendRedirect("index.jsp");
} catch(SQLException e) {
    out.print("Feedback not entered successfully!<br>");
    out.print(e.getMessage());
}

finally {
conn.close();
}

%>
</body>
</html>
