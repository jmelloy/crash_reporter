package org.visualdistortion.util;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.ResultSetMetaData;
import java.util.HashMap;
import java.util.Map;
import org.visualdistortion.util.Util;

/**
 *
 * @author jmelloy
 */
public class SqlUtil {
    
    public static Map rsConvert(ResultSet rs) throws SQLException {
        Map m = new HashMap();
        
        ResultSetMetaData rsmd = null;

        rs.next();

        rsmd = rs.getMetaData();
        
        for(int i = 1; i <= rsmd.getColumnCount(); i++) {
            m.put(rsmd.getColumnName(i), rs.getString(i));
        }
        
        return m;
    }
    
    public static void safeRollback(Connection conn) {
        try {
            if(conn != null)
                conn.rollback();
        } catch (SQLException e) {
            // do nothing
        }
    }
    
    public static void safeClose(Connection conn) {
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            // do nothing
        }
    }
    
    public static String table(ResultSet rs) throws SQLException {
        return table(rs, true);
    }
    
    public static String table(ResultSet rset, boolean hide_similar) throws SQLException {
        String ret = new String();
        ResultSetMetaData rsmd = rset.getMetaData();
        
        ret += "<table cellspacing=\"0\" cellpadding=\"2\">";

        String prevFirst = new String();

        int numTotal[] = new int[rsmd.getColumnCount()];
        boolean isNumber[] = new boolean[rsmd.getColumnCount()];

        for (int i = 0; i < numTotal.length; i++) {
            numTotal[i] = 0;
            isNumber[i] = true;
        }

        if(rsmd.getColumnName(1).equals("QUERY PLAN")
                && rsmd.getColumnCount() == 1) {
            ret += "<pre>";
            while(rset.next()) {
                ret += rset.getString(1);
            }
            ret += "</pre>";
        }

        while(rset.next()) {
            if((rset.getRow() - 1) % 25 == 0) {
                ret += "<tr>";
                ret += "<th>#</th>";
                for(int i = 1; i <= rsmd.getColumnCount(); i++) {
                    ret += "<th>" +
                        Util.capitalize(rsmd.getColumnName(i), null) + "</th>";
                }
                ret += "</tr>";
            }

            ret += "<tr class=\"" + (rset.getRow() % 2 == 0 ? "odd" : "even") + "\">";
            ret += "<td>" + rset.getRow() + "</td>";

            for(int i = 1; i <= rsmd.getColumnCount(); i++) {
                if(i == 1 && rset.getString(1) != null && 
                        rset.getString(1).equals(prevFirst)
                        && hide_similar) {
                    ret += "<td></td>";
                } else {
                    if(rsmd.getColumnName(i).endsWith("id")) {
                        ret += "<td>" + rset.getString(i) + "</td>";
                        isNumber[i - 1] = false;
                    } else {
                        ret += "<td>" + rset.getString(i) + "</td>";
                    }
                }
                if(i == 1) {
                    prevFirst = rset.getString(1);
                }

                if(isNumber[i - 1]) {
                    try {
                        numTotal[i - 1] += Integer.parseInt(rset.getString(i));
                    } catch (NumberFormatException e) {
                        isNumber[i - 1] = false;
                    }
                }
            }
            ret += "</tr>";
        }
/*        
        ret += "<tr><td><b>Tot:</b></td>";

        for(int i = 1; i <= rsmd.getColumnCount(); i++) {
            if(isNumber[i - 1]) {
                ret += "<td><b>" + numTotal[i - 1] + "</b></td>";
            } else {
                ret += "<td></td>";
            }
        }

        ret += "</tr>";
*/        
        ret += "</table>";

        return ret;
    }
}
