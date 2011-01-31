<%@ page import='java.sql.*' %>
<%@ page import='javax.sql.*' %>
<%@ page import='javax.naming.*' %>
<%@ page import='java.util.Properties' %>

<!--$URL: http://svn.visualdistortion.org/repos/projects/old_crash/post-comments.jsp $-->
<!--$Rev: 749 $ $Date: 2004-05-11 13:53:55 -0500 (Tue, 11 May 2004) $-->
<html>
<body>
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();

int crash_id  = Integer.parseInt(request.getParameter("crash"));
int user_id = 0;
try {
    user_id = Integer.parseInt(request.getParameter("user_id"));
} catch (NumberFormatException e) {
    out.print("<h1>Get a user_id!</h1>");
}

String subject = request.getParameter("subject");
String message = request.getParameter("message");

PreparedStatement pstmt = null;
try {

pstmt = conn.prepareStatement("insert into crash.comments " +
    "(user_id, crash_id, subject, message) values " +
    "(?,?,?,?)");

pstmt.setInt(1, user_id);
pstmt.setInt(2, crash_id);
pstmt.setString(3, subject);
pstmt.setString(4, message);

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
