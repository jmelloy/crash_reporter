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
int status = Integer.parseInt(request.getParameter("status"));
String reason = request.getParameter("reason");

try {
    user_id = Integer.parseInt(request.getParameter("user_id"));
} catch (NumberFormatException e) {
    out.print("<h1>Get a user_id!</h1>");
}


PreparedStatement pstmt = null;
try {

pstmt = conn.prepareStatement("insert into crash.status_history " +
    "(user_id, crash_id, status_id, reason) values " +
    "(?,?,?,?)");

pstmt.setInt(1, user_id);
pstmt.setInt(2, crash_id);
pstmt.setInt(3, status);
pstmt.setString(4, reason);

pstmt.executeUpdate();

pstmt = conn.prepareStatement("update crash.crash_logs set status_id = ? where crash_id = ?");

pstmt.setInt(1, status);
pstmt.setInt(2, crash_id);

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
    out.print("Feedback not entered successfully!<br>");
    out.print(e.getMessage());
}

finally {
conn.close();
}

%>
</body>
</html>
