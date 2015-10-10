/* Case-insensitive version of strstr() obtained from http://snippets.org */

#ifdef __ORCAC__
segment "bzip2";
#endif

/*
** Designation:  stristr
**
** Call syntax:  char *stristr(char *String, char *Pattern)
**
** Description:  This function is an ANSI version of strstr() with
**               case insensitivity.  (Functionally equivalent to
**               the strcasestr function in some C libraries.)
**
** Return item:  char *pointer if Pattern is found in String, else
**               null pointer
**
** Rev History:  07/06/03  Stephen Heumann  Used in bunzip2 for GNO
**               16/04/03  ?                ?
**               16/07/97  Greg Thayer      Optimized
**               07/04/95  Bob Stout        ANSI-fy
**               02/03/94  Fred Cole        Original
**
** Hereby donated to public domain.
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>

char *stristr(const char *String, const char *Pattern)
{
      char *pptr, *sptr, *start;

      for (start = (char *)String; *start != '\0'; start++)
      {
            /* find start of pattern in string */
            for ( ; ((*start!='\0') && (toupper(*start) != toupper(*Pattern)));
			start++)
                  ;

            pptr = (char *)Pattern;
            sptr = (char *)start;

            while (toupper(*sptr) == toupper(*pptr))
            {
                  sptr++;
                  pptr++;

                  /* if end of pattern then pattern was found */

                  if ('\0' == *pptr)
                        return (start);
            }
      }
      return NULL;
}
