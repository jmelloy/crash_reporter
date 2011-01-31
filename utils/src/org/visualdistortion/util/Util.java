/*
 * $URL: http://svn.visualdistortion.org/repos/projects/utils/src/org/visualdistortion/util/Util.java $
 * $Id: Util.java 1114 2005-12-10 07:11:11Z jmelloy $
 *
 * Jeffrey Melloy
 */

package org.visualdistortion.util;

import java.util.Map;
import java.util.Set;
import java.util.Iterator;

import java.net.URLEncoder;
import java.io.UnsupportedEncodingException;

import java.io.StringWriter;
import java.io.PrintWriter;

/**
 * Utilities for checking if strings are null or empty, transforming to ints,
 * and comparing strings.
 *
 * @author      Jeffrey Melloy &lt;jmelloy@visualdistortion.org&gt;
 * @version     $Rev: 1114 $ $Date: 2005-12-10 01:11:11 -0600 (Sat, 10 Dec 2005) $
 **/

public class Util {
    public static String checkNull(String input, String output, boolean literal) {
        if(input == null ||
            input.trim().length() == 0 ||
            (literal && input.equals("null"))) return output;
        else return input;
    }

    public static String checkNull(String input) {
        return checkNull(input, null, true);
    }

    public static String checkNull(String in, String out) {
        return checkNull(in, out, true);
    }
    
    public static String safeString(String input) {
        if(input == null) return "";
        else return input;
    }

    public static String safeString(String input, String output) {
        if(input == null) return output;
        else return input;
    }

    public static int checkInt(String input) {
        return checkInt(input, 0);
    }

    public static int checkInt(String input, int out) {
        int retVal;
        try {
            retVal = Integer.parseInt(input);
        } catch (NumberFormatException e) {
            retVal = out;
        }

        return retVal;
    }

    public static String compare(String a, String b, String out) {
        if(a == null || b == null) {
            return "";
        }

        if(a.equals(b)) {
            return out;
        } else {
            return "";
        }
    }

    public static String makeLink(String text, String dest, String cssclass, Map params) {
        String ret = new String();
        
        if(text != null) {
            ret = "<a href=\"";
        }
        
        ret += dest + "?";
        
        if(params != null) {
            Iterator keys = (params.keySet()).iterator();

            while(keys.hasNext()) {
                Object key = keys.next();
                try {
                    if(text != null) {
                        ret += "&amp;";    
                    } else {
                        ret += "&";
                    }
                    
                    ret += URLEncoder.encode(key.toString(), "UTF-8") + "=" + URLEncoder.encode( (params.get(key)).toString(), "UTF-8" );
                } catch (UnsupportedEncodingException e) {
                    // I don't care
                }
            }

        }
        
        
        if(text != null) {
            ret += "\"";

            if(cssclass != null) 
                ret += " class=\"" + cssclass + "\" ";
            ret += ">" + text + "</a>";
        }
        return ret;
    }

    public static String makeLink(String text, String dest) {
        return makeLink(text, dest, null, null);
    }
    
    public static String makeLink(String text, String dest, Map params) {
        return makeLink(text, dest, null, params);
    }
    
    public static String makeUrl(String dest, Map params) {
        return makeLink(null, dest, null, params);
    }
    
    public static String prettyException(Exception e) {
       StringWriter sw = new StringWriter();
       PrintWriter pw = new PrintWriter(sw);
       
       e.printStackTrace(pw);
       
       String ret = new String();
        
       ret += "<div class=\"error\">";

       ret += "<p>" + e.getMessage() + "</p>";

       ret += "<div id=\"errordetails\">";
       ret += "<pre>";
       
       ret += sw.toString();
       
       ret += "</pre>";
       ret += "</div>";

       ret += "</div>";
       
       return ret;
    }
    
    public static String prettyExceptionNoStack(Exception e) {
       String ret = new String();
        
       ret += "<div class=\"error\">";

       ret += "<p>" + e.getMessage() + "</p>";
       
       if(e instanceof FormException) {
           FormException fe = (FormException) e;
           ret += fe.getDetails();
       }
        
       ret += "</div>";
       
       return ret;
    }
    
    public static String capitalize(String str, char[] delimiters) {
        
        str = str.replaceAll("_", " ");
        
        if (str == null || str.length() == 0) {
            return str;
        }
        
        int strLen = str.length();
        StringBuffer buffer = new StringBuffer(strLen);

        int delimitersLen = 0;
        if(delimiters != null) {
            delimitersLen = delimiters.length;
        }

        boolean capitalizeNext = true;
        for (int i = 0; i < strLen; i++) {
            char ch = str.charAt(i);

            boolean isDelimiter = false;
            if(delimiters == null) {
                isDelimiter = Character.isWhitespace(ch);
            } else {
                for(int j=0; j < delimitersLen; j++) {
                    if(ch == delimiters[j]) {
                        isDelimiter = true;
                        break;
                    }
                }
            }

            if (isDelimiter) {
                buffer.append(ch);
                capitalizeNext = true;
            } else if (capitalizeNext) {
                buffer.append(Character.toTitleCase(ch));
                capitalizeNext = false;
            } else {
                buffer.append(ch);
            }
        }
        return buffer.toString();
    }
    
    public static String paginate(int page, int perPage, int total, String url) {
        return paginate(page, perPage, total, 0, url);
    }
    
    public static String paginate(int page, int perPage, int total, int thisPage, String url) {
        String ret = new String();
        
        if (thisPage == 0)
            thisPage = perPage;
        
        int totalPages = total / perPage;
        
        if(total % perPage != 0) totalPages++;
        
        if(total == 0 && thisPage >= perPage) 
            totalPages = page + 1;
        else if (thisPage < perPage)
            totalPages = page;
        
        if(totalPages > 1) {
            if(page != 1) {
                ret += "<a href=\"" + url + "&page=" + (page - 1) + "\">&lt;&lt;</a>";
                ret += "<a href=\"" + url + "&page=1" + "\">1</a>&nbsp;";
            }
            
            if(page > 3) {
                ret += " ...&nbsp;";
            }
            
            for(int i = page - 2; i < page + 3 && i < totalPages; i++) {
                if(i <= 1) i = 2;
                
                if(page != i) {
                    ret += "<a href=\"" + url + "&page=" + i + "\">" + i + "</a>&nbsp;";
                } else {
                    ret += "<span class=\"current\">" + i + "<span>&nbsp;";
                }
            }
            
            if(page < totalPages - 3) {
                ret += " ...&nbsp;";
            }
            
            if(page != totalPages) {
                ret += "<a href=\"" + url + "&page=" + totalPages + "\">" + totalPages + "</a>&nbsp;";

                if(total == 0 && thisPage >= perPage) {
                    ret += " ...&nbsp;";
                }
                ret += "<a href=\"" + url + "&page=" + (page + 1) + "\">&gt;&gt;</a>";
            } else {
                ret += totalPages;
            }
            
        }
        
        return ret;
    }
}
