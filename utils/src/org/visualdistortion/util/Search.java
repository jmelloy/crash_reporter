/*
 * $URL: http://svn.visualdistortion.org/repos/projects/utils/src/org/visualdistortion/util/Search.java $
 * $Id: Search.java 992 2005-01-15 20:38:14Z jmelloy $
 *
 * Jeffrey Melloy
 */

package org.visualdistortion.util;

import java.util.List;
import java.util.ArrayList;

/**
 * Methods for transforming strings into results capable of being used by
 * tsearch and tsearch2.
 *
 * Instantiating this object with a search string allows you to get the
 * original string, the transformed string, and a List of exact matches.
 *
 * @author      Jeffrey Melloy &lt;jmelloy@visualdistortion.org&gt;
 * @version     $Rev: 992 $ $Date: 2005-01-15 14:38:14 -0600 (Sat, 15 Jan 2005) $
 **/
public class Search {
    String inputString = new String();
    String searchKey = new String();
    List exactMatch = new ArrayList();

    public Search(String input) {
        inputString = input;
        searchKey = input.trim();

        int quoteMatch = 1;

        while(quoteMatch >= 0) {
            quoteMatch = searchKey.indexOf('"');
            if(quoteMatch >= 0) {
                int quoteTwo = searchKey.indexOf('"', quoteMatch + 1);
                exactMatch.add(searchKey.substring(
                            quoteMatch + 1,
                            quoteTwo));
                searchKey = searchKey.replaceFirst("\"", "(");
                searchKey = searchKey.replaceFirst("\"", ")");
            }
        }

        while(searchKey.indexOf("  ") >= 0) {
            searchKey = searchKey.replaceAll("  ", " ");
        }

        if(searchKey.indexOf("AND") > 0 ||
                searchKey.indexOf("OR") > 0 ||
                searchKey.indexOf("NOT") > 0) {
            searchKey = searchKey.replaceAll(" AND ", "&");
            searchKey = searchKey.replaceAll(" OR ", "|");
            searchKey = searchKey.replaceAll("NOT ", "!");
            searchKey = searchKey.replaceAll(" ", "&");
        } else if (searchKey.indexOf("|") > 0 ||
                searchKey.indexOf("&") > 0) {
            searchKey = searchKey.replaceAll(" ", "");
        } else {
            searchKey = searchKey.replaceAll(" ", "&");
        }
    }

    /**
     * Returns a list of exact matches.
     */
    public List getExactMatches() {
        return exactMatch;
    }

    /**
     * Returns the transformed string.
     */
    public String getSearch() {
        return searchKey;
    }

    /**
     * Returns the original string.
     */
    public String getInputString() {
        return inputString;
    }
}

