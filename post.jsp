<%@ page import='java.sql.*' %>
<%@ page import='javax.sql.*' %>
<%@ page import='javax.naming.*' %>
<%@ page import='java.util.Properties' %>

<!--$URL: http://svn.visualdistortion.org/repos/projects/old_crash/post.jsp $-->
<!--$Rev: 735 $ $Date: 2004-05-10 12:10:23 -0500 (Mon, 10 May 2004) $-->

<html>
<body>
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();

String time = request.getParameter("time");
String email = request.getParameter("email");
String service = request.getParameter("service_name");
String buildNo = request.getParameter("build");
String short_desc = request.getParameter("short_desc");
String description = request.getParameter("desc");
String crashLog = request.getParameter("log");
String address = request.getRemoteAddr();

if (time != null && time.equals("")) {
    time = null;
}
if (email != null && email.equals("")) {
    email = null;
}

if (service != null && service.equals("")) {
    service = null;
}

if (buildNo != null && buildNo.equals("")) {
    buildNo = null;
}

if (description != null && description.equals("") ){
    description = null;
}

if (crashLog != null && crashLog.equals("") ) {
    crashLog = null;
}

if(short_desc != null && short_desc.equals("") ){ 
    short_desc = null;
}

PreparedStatement pstmt = null;
try {

String query = "insert into crash.crash_logs " +
    "(build, email, service_uid, description, crash_log, status_id, short_desc, ip_address, application) values (?,?,?,?,?,?,?,?,?)";

pstmt = conn.prepareStatement(query);
    
pstmt.setString(1, buildNo);
pstmt.setString(2, email);
pstmt.setString(3, service);
pstmt.setString(4, description);
pstmt.setString(5, crashLog);
pstmt.setInt(6, 1);
pstmt.setString(7, short_desc);
pstmt.setString(8, address);
pstmt.setString(9, "Adium");

pstmt.executeUpdate();
/*
//send an email
Properties props = new Properties();
props.put("mail.smtp.host", "calvin.slamb.org");
Session s = Session.getInstance(props, null);
MimeMessage message = new MimeMessage(s);

InternetAddress from = new InternetAddress("jmelloy@visualdistortion.org");
message.setFrom(from);
InternetAddress to = new InternetAddress("jmelloy@visualdistortion.org");
message.setRecipient(Message.RecipientType.TO, to);

message.setSubject("Crash log");
message.setText(email + "\n" + 
    time + "\n" + 
    buildNo + "\n\n" +
    description + "\n\n" + 
    crashLog + "\n\n"); 

Transport.send(message);
*/
out.println("<h1>Thank you for posting.</h1>");
response.sendRedirect("index.html");

} catch(SQLException e) {
    out.print("Insert unsuccessful.");
    out.print(e.getMessage());
}
finally {
conn.close();
}

%>
</body>
</html>
