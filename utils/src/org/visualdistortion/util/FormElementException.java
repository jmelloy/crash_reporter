/*
 * FormException.java
 *
 * Created on October 16, 2005, 10:42 AM
 *
 */

package org.visualdistortion.util;

/**
 *
 * @author jmelloy
 */
public class FormElementException extends Exception {
    
    String element;
    
    /** Creates a new instance of FormException */
    public FormElementException() {
        super();
    }
    
    public FormElementException(String text, String el) {
        super(text);
        element = el;
    }
    
    public String getElement() {
        return element;
    }
}
