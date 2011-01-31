/*
 * FormException.java
 *
 * Created on October 16, 2005, 10:42 AM
 *
 */

package org.visualdistortion.util;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

/**
 *
 * @author jmelloy
 */
public class FormException extends Exception {
    
    HashSet formElements = new HashSet();
    HashSet details = new HashSet();
    HashMap values = new HashMap();
    String alternateDetail;
    
    /** Creates a new instance of FormException */
    public FormException() {
        super("The following problems were found:");
    }
    
    public FormException(String text) {
        super(text);
    }
    
    public void appendDetail(String text) {
        details.add(text);
    }
    
    public void setDetail(String text) {
        alternateDetail = text;
    }
    
    public String getDetails() {
        String ret = "<ul>";
        
        Iterator it = details.iterator();
        
        while(it.hasNext()) {
            String a = (String) it.next();
            
            if(a != null) {
                ret += "<li>" + a + "</li>";
            }
        }
        
        ret += "</ul>";
        
        return ret;
    }
    
    public void addFormElement(String element) {
        formElements.add(element);
    }
    
    public boolean checkFormElement(String element) {
        return formElements.contains(element);
    }
    
    public void setValue(String element, String value) {
        values.put(element, value);
    }
    
    public String getValue(String element) {
        return (String) values.get(element);
    }
    
    public void addException(FormElementException fee) {
        addFormElement(fee.getElement());
        appendDetail(fee.getMessage());
    }
    
    public boolean hasExceptions() {
        return (alternateDetail != null) || (details.size() > 0);
    }
}
