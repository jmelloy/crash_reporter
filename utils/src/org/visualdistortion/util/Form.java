package org.visualdistortion.util;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author jmelloy
 */
public class Form {
    
    public static String makeSelect(ResultSet rs, String name, String currentValue, boolean error, String javascript) 
            throws SQLException {
        
        if (currentValue == null) currentValue = "";
        
        rs.beforeFirst();
        
        String ret = new String();
        
        ret += "<select name=\"" + name + "\" id=\"" + name + "\"";
        if(javascript != null) {
            ret += " onChange=\"" + javascript + "\"";
        }
        ret += ">";
        ret += "<option value=\"\">Choose one ... </option>";

        while(rs.next()) {
            ret += "<option value=\"" + rs.getString(1) + "\"";
            if(currentValue.equals(rs.getString(1))) {
                ret += " selected=\"selected\"";
            }

            ret += ">" + rs.getString(2) + "</option>";
        }
        
        ret += "</select>";
        
        return ret;
    }
    
    public static String makeSelect(ResultSet rs, String name)
            throws SQLException {
        return makeSelect(rs, name, null, false, null);
    }
    
    public static String makeSelect(ResultSet rs, String name, boolean value, String javascript) 
            throws SQLException {
        return makeSelect(rs, name, null, value, javascript);
    }
    
    public static String makeSelect(ResultSet rs, String name, String value) 
            throws SQLException {
        return makeSelect(rs, name, value, false, null);
    }
    
    public static String makeSelect(ResultSet rs, String name, String value, boolean error) 
            throws SQLException {
        return makeSelect(rs, name, value, error, null);
    }
    
    public static String makeValue(String check) {
        if(check != null) 
            return " value=\"" + check + "\" ";
        
        return "";
    }
    
    public static String makeStateSelect(String id) {
        return makeStateSelect(id, null);
    }
    
    public static String makeStateSelect(String id, String value) {
        return makeStateSelect(id, value, false);
    }
    
    public static String makeStateSelect(String id, String value, boolean error) {
        String ret = new String();
        
        String stateNames[] = {"AL", "Alabama",
            "AK", "Alaska",
            "AZ", "Arizona",
            "AR", "Arkansas",
            "CA", "California",
            "CO", "Colorado",
            "CT", "Connecticut",
            "DE", "Delaware",
            "DC", "District of Columbia",
            "FL", "Florida",
            "GA", "Georgia",
            "HI", "Hawaii",
            "ID", "Idaho",
            "IL", "Illinois",
            "IN", "Indiana",
            "IA", "Iowa",
            "KS", "Kansas",
            "KY", "Kentucky",
            "LA", "Louisiana",
            "ME", "Maine",
            "MD", "Maryland",
            "MA", "Massachusetts",
            "MI", "Michigan",
            "MN", "Minnesota",
            "MS", "Mississippi",
            "MO", "Missouri",
            "MT", "Montana",
            "NE", "Nebraska",
            "NV", "Nevada",
            "NH", "New Hampshire",
            "NJ", "New Jersey",
            "NM", "New Mexico",
            "NY", "New York",
            "NC", "North Carolina",
            "ND", "North Dakota",
            "OH", "Ohio",
            "OK", "Oklahoma",
            "OR", "Oregon",
            "PA", "Pennsylvania",
            "RI", "Rhode Island",
            "SC", "South Carolina",
            "SD", "South Dakota",
            "TN", "Tennessee",
            "TX", "Texas",
            "UT", "Utah",
            "VT", "Vermont",
            "VA", "Virginia",
            "WA", "Washington",
            "WV", "West Virginia",
            "WI", "Wisconsin",
            "WY", "Wyoming"};
        
        if(error) {
            ret += "<div class=\"fieldWithErrors\">";
        }
            
        ret += "<select name=\"" + id + "\" id=\"" + id + "\">";
        ret += "<option value=\"\">Choose One ... </option>";

        for(int i = 0; i < stateNames.length; i++) {
            
            
            ret += "<option value=\"" + stateNames[i] + "\"";
            
            if(value != null && stateNames[i].equals(value)) {
                ret += " selected=\"selected\" ";
            }
            
            i++;
            
            ret += ">" + stateNames[i] + "</option>\n";
        }
        
        ret += "</select>";

        if(error) {
            ret += "</div>";
        }
        
        return ret;
    }

    public static String makeText(String name, String value, int size, boolean error) {
        String ret = new String();
        
        if(error) {
            ret += "<div class=\"fieldWithErrors\">";
        }
        
        ret += "<input type=\"text\" name=\"" + name + "\" id=\"" + name + "\"";
        
        if(size != 0) ret += " size=\"" + size + "\" ";
        
        ret += makeValue(value);
        
        ret += "/>";
        
        if(error) {
            ret += "</div>";
        }
        return ret;
    }
    
    public static String makeText(String name, String value, int size) {
        return makeText(name, value, size, false);
    }
    
    public static String makeText(String name) {
        return makeText(name, null, 0, false);
    }
    
    public static String makeText(String name, int size) {
        return makeText(name, null, 0, false);
    }
    
    public static String makeText(String name, boolean error) {
        return makeText(name, null, 0, error);
    }
    
    public static String makeText(String name, String value, boolean error) {
        return makeText(name, value, 0, error);
    }
    
    public static String makePassword(String name, int size, boolean error) {
        String ret = new String();
        
        if(error) {
            ret += "<div class=\"fieldWithErrors\">";
        }
        
        ret += "<input type=\"password\" name=\"" + name + "\" id=\"" + name + "\"";
        
        if(size != 0) ret += " size=\"" + size + "\" ";
        
        ret += "/>";
        
        if(error) {
            ret += "</div>";
        }
        return ret;
    }
    
    public static String makePassword(String name, boolean error) {
        return makePassword(name, 0, error);
    }
    
    public static String makeText(String name, String value) {
        return makeText(name, value, 0, false);
    }
}
