/*
 * Definitions etc. for regexp(3) routines.
 *
 * Caveat:  this is V8 regexp(3) [actually, a reimplementation thereof],
 * not the System V one.
 */
#define NSUBEXP  10
typedef struct regexp {
	char *startp[NSUBEXP];
	char *endp[NSUBEXP];
	char regstart;		/* Internal use only. */
	char *regmust;		/* Internal use only. */
	int regmlen;		/* Internal use only. */
	char program[1];	/* Unwarranted chumminess with compiler. */
} regexp;

struct mrb_state;
typedef struct regexp_info {
    struct mrb_state *mrb;
    unsigned char flag;
    const char *error_msg;
} regexp_info;

#define REGEXP_FLAG_IGNORECASE  (1 << 0)
#define REGEXP_FLAG_MULTILINE   (1 << 2)
#define REGEXP_FLAG_ALL (REGEXP_FLAG_IGNORECASE | REGEXP_FLAG_MULTILINE)

extern regexp *regcomp(regexp_info *ri, const char *re);
extern int regexec(regexp_info *ri, regexp *rp, const char *s);
extern void regsub(regexp_info *ri, const regexp *rp, const char *src, char *dst);
extern void regerror(regexp_info *ri, char *message);
