

#ifndef JANSSON_CONFIG_H
#define JANSSON_CONFIG_H

/* If your compiler supports the inline keyword in C, JSON_INLINE is
   defined to `inline', otherwise empty. In C++, the inline is always
   supported. */
#ifdef __cplusplus
#define JSON_INLINE inline
#else
#define JSON_INLINE inline
#endif

/* If your compiler supports the `long long` type and the strtoll()
   library function, JSON_INTEGER_IS_LONG_LONG is defined to 1,
   otherwise to 0. */
#define JSON_INTEGER_IS_LONG_LONG 1

/* If locale.h and localeconv() are available, define to 1,
   otherwise to 0. */
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    #define JSON_HAVE_LOCALECONV 0
#else
    #define JSON_HAVE_LOCALECONV 1
#endif

#endif
